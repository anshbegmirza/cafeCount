import type { Knex } from 'knex';
import dotenv from 'dotenv';

dotenv.config();

const useSsl = ['1', 'true', 'yes'].includes((process.env.DB_SSL || '').toLowerCase());

const shared = {
  client: 'mysql2',
  connection: {
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'cafecount',
    timezone: '+05:30',
    ...(useSsl ? { ssl: { rejectUnauthorized: false } } : {}),
  },
  migrations: {
    directory: './migrations',
    extension: 'ts',
  },
  seeds: {
    directory: './seeds',
    extension: 'ts',
  },
} satisfies Knex.Config;

export default {
  development: shared,
  production: shared,
};
