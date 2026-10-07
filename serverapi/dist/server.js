"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const path_1 = __importDefault(require("path"));
const authRoutes_1 = __importDefault(require("./Routes/authRoutes"));
const wishlistRoutes_1 = __importDefault(require("./Routes/wishlistRoutes"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// เสิร์ฟรูปภาพและไฟล์ Static Assets จากโฟลเดอร์ uploads
app.use('/uploads', express_1.default.static(path_1.default.join(__dirname, 'uploads')));
app.use('/api/auth', authRoutes_1.default);
app.use('/api/wishlist', wishlistRoutes_1.default);
// Global Error Handler ให้ตอบเป็น JSON เสมอ (ไม่พ่น HTML Error Page)
app.use((err, req, res, next) => {
    console.error('Unhandled server error:', err);
    res.status(err.status || 500).json({
        message: err.message || 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์',
    });
});
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
