import dotenv from 'dotenv';
import mysql from 'mysql2/promise';

dotenv.config();

const host = process.env.DB_HOST || '127.0.0.1';
const port = Number(process.env.DB_PORT || 3306);
const user = process.env.DB_USER || 'root';
const password = process.env.DB_PASSWORD || '';
const database = process.env.DB_NAME || 'cafecount';

console.log(`connecting ${host}:${port} user=${user} pwdLen=${password.length}`);

try {
  const c = await mysql.createConnection({
    host,
    port,
    user,
    password,
    connectTimeout: 5000,
  });
  console.log('connected');
  await c.query(`CREATE DATABASE IF NOT EXISTS \`${database.replace(/`/g, '')}\``);
  console.log('db ready:', database);
  await c.end();
} catch (e) {
  console.error('FAIL', e.message);
  process.exit(1);
}
