module.exports = {
    dev: {
        Host: "localhost",
        USER: "root",
        PASSWORD: "",
        DB: "skribble_db",
        dialect: 'mysql',
        pool: {
            max: 5,
            min: 0,
            acquire: 30000,
            idle: 10000,
        }
    },
    // prod: {
    //     Host: "localhost",
    //     USER: "abenidev_tiktaktoe_db_user",
    //     PASSWORD: "6D.RqKePO+x)",
    //     DB: "abenidev_tiktaktoe_db",
    //     dialect: 'mysql',
    //     pool: {
    //         max: 5,
    //         min: 0,
    //         acquire: 30000,
    //         idle: 10000,
    //     }
    // }
}