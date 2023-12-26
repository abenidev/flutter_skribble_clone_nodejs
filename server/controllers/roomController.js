const db = require('../model');

// create main Model
const Room = db.rooms;

//create room
const createRoom = async (roomInfo) => {
    const room = await Room.create(roomInfo);
    return room;
}

//get room by id
const getRoomById = async (roomId) => {
    let room = await Room.findOne({ where: { id: roomId } });
    return room;
}


//get room by name
const getRoomByName = async (name) => {
    let room = await Room.findOne({ where: { name } });
    return room;
}

//update room
const updateRoomIsJoinVal = async (roomId, isJoinVal) => {
    const updatedRoom = await Room.update({ isJoin: isJoinVal }, { where: { id: roomId } });
    return updatedRoom;
}

//update room turn 
const updateRoomTurn = async (roomId, turnVal) => {
    const updatedRoom = await Room.update({ turn: turnVal }, { where: { id: roomId } });
    return updatedRoom;
}

//update room turn index
const updateRoomTurnIndex = async (roomId, turnIndexVal) => {
    const updatedRoom = await Room.update({ turnIndex: turnIndexVal }, { where: { id: roomId } });
    return updatedRoom;
}

module.exports = {
    createRoom,
    getRoomById,
    updateRoomIsJoinVal,
    updateRoomTurn,
    updateRoomTurnIndex,
    getRoomByName,
}