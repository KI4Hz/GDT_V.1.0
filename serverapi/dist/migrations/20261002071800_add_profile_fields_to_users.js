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
        yield knex.schema.alterTable('users', (table) => {
            table.string('gamer_tag', 100).nullable().defaultTo('Gamer');
            table.integer('avatar_index').notNullable().defaultTo(0);
            table.string('bio', 255).nullable().defaultTo('PC Gamer & Deal Hunter 🎮');
            table.string('favorite_store', 50).notNullable().defaultTo('Steam');
            table.timestamp('updated_at').defaultTo(knex.fn.now());
        });
    });
}
exports.up = up;
function down(knex) {
    return __awaiter(this, void 0, void 0, function* () {
        yield knex.schema.alterTable('users', (table) => {
            table.dropColumn('gamer_tag');
            table.dropColumn('avatar_index');
            table.dropColumn('bio');
            table.dropColumn('favorite_store');
            table.dropColumn('updated_at');
        });
    });
}
exports.down = down;
