"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.down = exports.up = void 0;
function up(knex) {
    return __awaiter(this, void 0, void 0, function* () {
        // สร้างตาราง users
        yield knex.schema.createTable('users', (table) => {
            table.increments('id').primary();
            table.string('email', 255).notNullable().unique();
            table.string('password', 255).notNullable();
            table.timestamp('created_at').defaultTo(knex.fn.now());
        });
        // สร้างตาราง wishlists
        yield knex.schema.createTable('wishlists', (table) => {
            table.increments('id').primary();
            table.integer('user_id').unsigned().notNullable()
                .references('id').inTable('users')
                .onDelete('CASCADE');
            table.string('game_id', 100).notNullable();
            table.string('title', 255).notNullable();
            table.decimal('sale_price', 10, 2).notNullable();
            table.decimal('normal_price', 10, 2).notNullable();
            table.string('thumb', 500).nullable();
            table.timestamp('saved_at').defaultTo(knex.fn.now());
        });
    });
}
exports.up = up;
function down(knex) {
    return __awaiter(this, void 0, void 0, function* () {
        // คำสั่งย้อนกลับเมื่อต้องการ rollback
        yield knex.schema.dropTableIfExists('wishlists');
        yield knex.schema.dropTableIfExists('users');
    });
}
exports.down = down;
