import knex, { Knex } from 'knex';
import { config } from './config';

export const db: Knex = knex({
  client: 'mysql2',
  connection: {
    host: config.db.host,
    port: config.db.port,
    user: config.db.user,
    password: config.db.password,
    database: config.db.database,
    timezone: '+05:30',
    ...(config.db.ssl ? { ssl: { rejectUnauthorized: false } } : {}),
  },
  pool: { min: 0, max: 10 },
});
