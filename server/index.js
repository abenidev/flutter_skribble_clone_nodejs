const express = require('express');
const http = require('http');
const socket = require('socket.io');
const { getRoomByName, createRoom, updateRoomIsJoinVal, updateRoomTurn, getRoomById, updateRoomCurrentRound, updateRoomTurnIndex, updateRoomWord } = require('./controllers/roomController');
const getWord = require('./api/getWord');
const { createPlayer, getPlayersByRoomId, getPlayersBySocketId, updatePlayerPoint } = require('./controllers/playerController');
const app = express();
const port = process.env.PORT || 3000;
let server = http.createServer(app);
let io = socket(server);

//middleware
app.use(express.json());

//
io.on('connection', (socket) => {
    const socketId = socket.id;
    console.log('connected: ', socketId);
    //*create game
    socket.on('create:game', async ({ nickname, name, occupancy, maxRounds }) => {
        try {
            const existingRoom = await getRoomByName(name);
            if (existingRoom) {
                socket.emit('room:exists', 'Room with name already exists');
                return;
            }
            const word = getWord();

            let roomInfo = {
                word,
                name,
                occupancy,
                maxRounds,
            }

            const createdRoom = await createRoom(roomInfo);
            console.log('createdRoom: ', createdRoom);

            let playerInfo = {
                socketId,
                nickname,
                isPartyLeader: true,
                roomId: createdRoom.id,
            }

            const createdPlayer = await createPlayer(playerInfo);
            console.log('createdPlayer: ', createdPlayer);
            socket.join(createdRoom.id);
            const players = await getPlayersByRoomId(createdRoom.id);
            io.to(createdRoom.id).emit('update:room', { updatedRoom: createdRoom, players });
        } catch (error) {
            console.log('error: ', error);
        }
    });
    //*join game
    socket.on('join:game', async ({ nickname, name }) => {
        try {
            const foundRoom = await getRoomByName(name);
            if (!foundRoom) {
                socket.emit('room:notFound', 'Room not found!');
                return;
            }

            //if room isJoin is true then allow player to join
            if (foundRoom.isJoin) {
                let playerInfo = {
                    socketId,
                    nickname,
                    roomId: foundRoom.id,
                }
                const createdPlayer = await createPlayer(playerInfo);
                socket.join(foundRoom.id);
                const players = await getPlayersByRoomId(foundRoom.id);
                if (players.length === foundRoom.occupancy) {
                    await updateRoomIsJoinVal(foundRoom.id, false);
                }
                await updateRoomTurn(foundRoom.id, players[foundRoom.turnIndex].id);
                const updatedRoom = await getRoomById(foundRoom.id);
                console.log('players: ', players);
                io.to(updatedRoom.id).emit('update:room', { updatedRoom, players });
            } else {
                //?update for spectate mode
                socket.emit('room:isJoinFalse', 'You are not allowed to join to room!');
            }
        } catch (error) {
            console.log('error: ', error);
        }
    });

    //white board sockets
    //paint
    socket.on('paint', ({ details, roomId }) => {
        io.to(roomId).emit('points', { details });
    });

    //Color change 
    socket.on('color:change', ({ color, roomId }) => {
        io.to(roomId).emit('color:change:server', color);
    });

    //stroke width
    socket.on('stroke:width', ({ width, roomId }) => {
        io.to(roomId).emit('stroke:width:server', width);
    });

    //clean:screen
    socket.on('clean:screen', (roomId) => {
        io.to(roomId).emit('clean:screen:server', '');
    });

    //guess:client
    socket.on('guess:client', async (guessData) => {
        try {
            if (guessData.guess == guessData.word) {
                const foundRoom = await getRoomById(guessData.roomId);
                const userPlayer = await getPlayersBySocketId(guessData.socketId);
                if (guessData.timeTaken !== 0) {
                    let newPoint = userPlayer.points + Math.round((200 / guessData.timeTaken) * 10);
                    await updatePlayerPoint(userPlayer.id, newPoint);
                }

                io.to(guessData.roomId).emit('guess:server', {
                    username: guessData.username,
                    msg: 'Guessed it!',
                    guessedUserCtr: guessData.guessedUserCtr + 1,
                });
            } else {
                io.to(guessData.roomId).emit('guess:server', {
                    username: guessData.username,
                    msg: guessData.guess,
                    guessedUserCtr: guessData.guessedUserCtr,
                });
            }

        } catch (error) {
            console.log('error: ', error);
        }
    });

    //change turn
    socket.on('change:turn', async (roomId) => {
        try {
            const foundRoom = await getRoomById(roomId);
            const players = await getPlayersByRoomId(roomId);
            let turnIndex = foundRoom.turnIndex;
            if (turnIndex + 1 === players.length) {
                await updateRoomCurrentRound(roomId, foundRoom.currentRound + 1);
            }

            if (foundRoom.currentRound <= foundRoom.maxRounds) {
                const word = getWord();
                await updateRoomWord(roomId, word);
                // await updateRoomTurnIndex(roomId, Math.floor(((turnIndex + 1) % players.length)));
                let turnIndexVal = (turnIndex + 1) % players.length;
                await updateRoomTurnIndex(roomId, turnIndexVal);
                await updateRoomTurn(roomId, players[turnIndexVal]);
                const updatedRoom = await getRoomById(foundRoom.id);
                io.to(foundRoom.id).emit('change:turn:server', updatedRoom);
            } else {
                //show leader board
            }
        } catch (error) {
            console.log('error: ', error);
        }
    });
});

//listen
server.listen(port, "0.0.0.0", () => {
    console.log('Server started!!!');
});