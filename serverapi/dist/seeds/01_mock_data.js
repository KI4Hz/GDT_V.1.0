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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.seed = void 0;
const bcrypt_1 = __importDefault(require("bcrypt"));
function seed(knex) {
    return __awaiter(this, void 0, void 0, function* () {
        // ลบข้อมูลเดิมออกเพื่อความสะอาด
        yield knex('wishlists').del();
        yield knex('users').del();
        const hashedPassword = yield bcrypt_1.default.hash('123456', 10);
        // เพิ่ม User จำลองพร้อม Profile
        const [userId] = yield knex('users').insert({
            email: 'gamer@test.com',
            password: hashedPassword,
            gamer_tag: 'CyberPro',
            avatar_index: 1,
            bio: 'Hunter of the steepest Steam discounts! 🎮🚀',
            favorite_store: 'Steam',
        });
        // เพิ่ม Wishlist จำลอง
        yield knex('wishlists').insert([
            {
                user_id: userId,
                game_id: '1447',
                title: 'Cyberpunk 2077',
                sale_price: 29.99,
                normal_price: 59.99,
                thumb: 'https://images.greenmangaming.com/c636f455e7144e13b302c38d6df72a15/b7aeef39a9c1417a80b6fc7096d26d84.jpg',
            },
            {
                user_id: userId,
                game_id: '154',
                title: 'The Witcher 3: Wild Hunt',
                sale_price: 9.99,
                normal_price: 39.99,
                thumb: 'https://images.greenmangaming.com/15291f09e8a74e5cb42a781b43343355/ca5957b44d3246ebbfbe2a13ee4cfbd0.jpg',
            },
        ]);
    });
}
exports.seed = seed;
