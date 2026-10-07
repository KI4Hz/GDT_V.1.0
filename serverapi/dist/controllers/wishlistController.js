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
exports.removeFromWishlist = exports.addToWishlist = exports.checkInWishlist = exports.getWishlist = void 0;
const db_1 = __importDefault(require("../utils/db"));
// GET /api/wishlist - ดึงรายการ wishlist ของ user ที่ล็อกอินอยู่
const getWishlist = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
        if (!userId) {
            res.status(401).json({ message: 'กรุณาเข้าสู่ระบบก่อนใช้งาน' });
            return;
        }
        const items = yield (0, db_1.default)('wishlists')
            .where({ user_id: userId })
            .orderBy('saved_at', 'desc');
        res.status(200).json({
            success: true,
            data: items,
        });
    }
    catch (error) {
        console.error('getWishlist error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
    }
});
exports.getWishlist = getWishlist;
// GET /api/wishlist/check/:gameId - ตรวจสอบว่าเกมนี้อยู่ใน wishlist หรือไม่
const checkInWishlist = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _b;
    try {
        const userId = (_b = req.user) === null || _b === void 0 ? void 0 : _b.id;
        const { gameId } = req.params;
        if (!userId) {
            res.status(401).json({ message: 'กรุณาเข้าสู่ระบบก่อนใช้งาน' });
            return;
        }
        const item = yield (0, db_1.default)('wishlists')
            .where({ user_id: userId, game_id: gameId })
            .first();
        res.status(200).json({
            inWishlist: !!item,
            item: item || null,
        });
    }
    catch (error) {
        console.error('checkInWishlist error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
    }
});
exports.checkInWishlist = checkInWishlist;
// POST /api/wishlist - เพิ่มเกมเข้า wishlist
const addToWishlist = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _c;
    try {
        const userId = (_c = req.user) === null || _c === void 0 ? void 0 : _c.id;
        if (!userId) {
            res.status(401).json({ message: 'กรุณาเข้าสู่ระบบก่อนใช้งาน' });
            return;
        }
        const { game_id, title, sale_price, normal_price, thumb } = req.body;
        if (!game_id || !title) {
            res.status(400).json({ message: 'ข้อมูลเกมไม่ครบถ้วน (game_id, title เป็นค่าจำเป็น)' });
            return;
        }
        // ตรวจสอบว่ามีอยู่แล้วหรือยัง
        const existing = yield (0, db_1.default)('wishlists')
            .where({ user_id: userId, game_id })
            .first();
        if (existing) {
            res.status(200).json({
                message: 'เกมนี้อยู่ใน Wishlist แล้ว',
                id: existing.id,
            });
            return;
        }
        const [newId] = yield (0, db_1.default)('wishlists').insert({
            user_id: userId,
            game_id: game_id.toString(),
            title,
            sale_price: parseFloat(sale_price) || 0,
            normal_price: parseFloat(normal_price) || 0,
            thumb: thumb || '',
        });
        res.status(201).json({
            success: true,
            message: 'บันทึกเข้า Wishlist สำเร็จ',
            id: newId,
        });
    }
    catch (error) {
        console.error('addToWishlist error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
    }
});
exports.addToWishlist = addToWishlist;
// DELETE /api/wishlist/:gameId - ลบเกมออกจาก wishlist (รองรับทั้งส่ง id หรือ game_id)
const removeFromWishlist = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _d;
    try {
        const userId = (_d = req.user) === null || _d === void 0 ? void 0 : _d.id;
        if (!userId) {
            res.status(401).json({ message: 'กรุณาเข้าสู่ระบบก่อนใช้งาน' });
            return;
        }
        const { gameId } = req.params;
        // ลบโดยเช็คว่าตรงกับ game_id หรือ id ของตาราง
        const deletedCount = yield (0, db_1.default)('wishlists')
            .where({ user_id: userId })
            .andWhere(function () {
            this.where('game_id', gameId).orWhere('id', gameId);
        })
            .del();
        if (deletedCount === 0) {
            res.status(404).json({ message: 'ไม่พบเกมที่ต้องการลบใน Wishlist' });
            return;
        }
        res.status(200).json({
            success: true,
            message: 'นำออกจาก Wishlist สำเร็จ',
        });
    }
    catch (error) {
        console.error('removeFromWishlist error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
    }
});
exports.removeFromWishlist = removeFromWishlist;
