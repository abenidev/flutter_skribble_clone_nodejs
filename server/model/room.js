module.exports = (sequelize, DataTypes) => {
    const Room = sequelize.define("room", {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        word: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        name: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
        },
        occupancy: {
            type: DataTypes.INTEGER,
            defaultValue: 4,
            allowNull: false,
        },
        maxRounds: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        currentRound: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 1,
        },
        isJoin: {
            type: DataTypes.BOOLEAN,
            defaultValue: true,
            allowNull: false,
        },
        turn: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        turnIndex: {
            type: DataTypes.INTEGER,
            defaultValue: 0,
        }
    });

    Room.associate = function (models) {
        Room.hasMany(models.Player);
    };

    return Room;
}