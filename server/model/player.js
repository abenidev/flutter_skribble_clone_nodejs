module.exports = (sequelize, DataTypes) => {
    const Player = sequelize.define("player", {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
            // unique: true,
        },
        nickname: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        socketId: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        isPartyLeader: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        points: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 0,
        },
        // playerType: {
        //     type: DataTypes.STRING,
        //     allowNull: false,
        // },
        roomId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {         // User belongsTo Room 1:1
                model: 'rooms',
                key: 'id'
            }
        }
    });

    Player.associate = function (models) {
        Player.belongsTo(models.Player);
    };

    return Player;
}