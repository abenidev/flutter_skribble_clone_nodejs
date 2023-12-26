const db = require('../model');

// create main Model
const Player = db.players;

//create player
const createPlayer = async (playerInfo) => {
    const player = await Player.create(playerInfo);
    return player;
}

//get players by roomId
const getPlayersByRoomId = async (roomId) => {
    let players = await Player.findAll({ where: { roomId } });
    return players;
}

//get players by socketId
const getPlayersBySocketId = async (socketId) => {
    let player = await Player.findOne({ where: { socketId } });
    return player;
}

//get players by id
const getPlayersById = async (id) => {
    let player = await Player.findOne({ where: { id } });
    return player;
}

//update player point
const updatePlayerPoint = async (id, prevPoint) => {
    let player = await Player.update({ points: prevPoint + 1 }, { where: { id } });
    return player;
}


//!
// get all players
const getAllPlayers = async (req, res) => {
    let Players = await Player.findAll({})
    res.status(200).send(Players);
}

module.exports = {
    getAllPlayers,
    createPlayer,
    getPlayersByRoomId,
    getPlayersById,
    getPlayersBySocketId,
    updatePlayerPoint,
}