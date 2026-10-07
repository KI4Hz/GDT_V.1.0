import knex, { Knex } from 'knex';
import dotenv from 'dotenv';
import path from 'path';

// กำหนดพาร์ทไปที่ไฟล์ .env ให้ชัดเจน
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const config: Knex.Config = {
  client: 'mysql2',
  connection: {
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'game_tracker_db',
  },
  pool: {
    min: 2,
    max: 10,
  },
};

const db: Knex = knex(config);

export default db;