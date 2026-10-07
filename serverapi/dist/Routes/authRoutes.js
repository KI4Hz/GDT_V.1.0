"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const multer_1 = __importDefault(require("multer"));
const authController_1 = require("../controllers/authController");
const authMiddleware_1 = require("../middlewares/authMiddleware");
const multer_config_1 = __importDefault(require("../utils/multer_config"));
const router = (0, express_1.Router)();
const upload = (0, multer_1.default)(multer_config_1.default.config);
router.post('/register', authController_1.register);
router.post('/login', authController_1.login);
router.get('/profile', authMiddleware_1.verifyToken, authController_1.getProfile);
router.put('/profile', authMiddleware_1.verifyToken, authController_1.updateProfile);
// อัปโหลดรูปโปรไฟล์ผู้ใช้ พร้อมดักจับ Error ให้ตอบเป็น JSON เสมอ
router.post('/upload-avatar', authMiddleware_1.verifyToken, (req, res, next) => {
    upload.single(multer_config_1.default.keyUpload)(req, res, (err) => {
        if (err instanceof multer_1.default.MulterError) {
            res.status(400).json({ message: `ข้อผิดพลาดในการอัปโหลดไฟล์: ${err.message}` });
            return;
        }
        else if (err) {
            res.status(400).json({ message: err.message || 'เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ' });
            return;
        }
        next();
    });
}, authController_1.uploadAvatar);
// ลบบัญชีผู้ใช้ (ลบข้อมูลและ Wishlist ทั้งหมด)
router.delete('/account', authMiddleware_1.verifyToken, authController_1.deleteAccount);
exports.default = router;
