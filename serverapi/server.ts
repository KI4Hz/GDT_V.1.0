import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import authRoutes from './Routes/authRoutes';
import wishlistRoutes from './Routes/wishlistRoutes';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// เสิร์ฟรูปภาพและไฟล์ Static Assets จากโฟลเดอร์ uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/api/auth', authRoutes);
app.use('/api/wishlist', wishlistRoutes);

// Global Error Handler ให้ตอบเป็น JSON เสมอ (ไม่พ่น HTML Error Page)
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Unhandled server error:', err);
  res.status(err.status || 500).json({
    message: err.message || 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์',
  });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});