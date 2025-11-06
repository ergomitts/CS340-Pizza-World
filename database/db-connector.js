let mysql = require('mysql2')

const username = process.env.DB_USER;
const password = process.env.DB_PASS;

if (!username || !password) {
	process.exit(1);
}

const pool = mysql.createPool({
    waitForConnections: true,
    connectionLimit: 10,
    host: 'classmysql.engr.oregonstate.edu',
    user: username,
    password: password,
    database: username
}).promise();

module.exports = pool;
