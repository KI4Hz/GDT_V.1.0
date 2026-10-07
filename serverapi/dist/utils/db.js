"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const knex_1 = __importDefault(require("knex"));
const dotenv_1 = __importDefault(require("dotenv"));
const path_1 = __importDefault(require("path"));
// กำหนดพาร์ทไปที่ไฟล์ .env ให้ชัดเจน
dotenv_1.default.config({ path: path_1.default.resolve(__dirname, '../.env') });
const config = {
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
const db = (0, knex_1.default)(config);
exports.default = db;
