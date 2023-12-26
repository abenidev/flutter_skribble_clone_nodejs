const dbConfigData = require('../configs/dbConfig');

const { Sequelize, DataTypes } = require('sequelize');

const dbConfig = dbConfigData.dev;
const sequelize = new Sequelize(
    dbConfig.DB,
    dbConfig.USER,
    dbConfig.PASSWORD,
    {
        host: dbConfig.Host,
        dialect: dbConfig.dialect,
        operatorsAliases: false,
        pool: {
            max: dbConfig.pool.max,
            min: dbConfig.pool.min,
            acquire: dbConfig.pool.acquire,
            idle: dbConfig.pool.idle,
        }
    }
);

sequelize.authenticate().then(() => {
    console.log('connected to db.');
}).catch((err) => {
    console.log('Error: ', err);
});

const db = {}

db.Sequelize = Sequelize;
db.sequelize = sequelize;

//table name
// db.products = require('./productModel.js')(sequelize, DataTypes);
// db.reviews = require('./reviewModel.js')(sequelize, DataTypes);
db.rooms = require('./room.js')(sequelize, DataTypes);
db.players = require('./player.js')(sequelize, DataTypes);



//
db.sequelize.sync({ force: false, alter: true }).then(() => {
    // db.sequelize.sync({ force: false }).then(() => {
    console.log('re-sync done!');
});

module.exports = db;