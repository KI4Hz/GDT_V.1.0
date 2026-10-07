import { Router } from 'express';
import multer from 'multer';
import {
  register,
  login,
  getProfile,
  updateProfile,
  uploadAvatar,
  deleteAccount,
} from '../controllers/authController';
import { verifyToken } from '../middlewares/authMiddleware';
import multerConfig from '../utils/multer_config';

const router = Router();
const upload = multer(multerConfig.config);

router.post('/register', register);
router.post('/login', login);

router.get('/profile', verifyToken, getProfile);
router.put('/profile', verifyToken, updateProfile);

// อัปโหลดรูปโปรไฟล์ผู้ใช้ พร้อมดักจับ Error ให้ตอบเป็น JSON เสมอ
router.post(
  '/upload-avatar',
  verifyToken,
  (req, res, next) => {
    upload.single(multerConfig.keyUpload)(req, res, (err) => {
      if (err instanceof multer.MulterError) {
        res.status(400).json({ message: `ข้อผิดพลาดในการอัปโหลดไฟล์: ${err.message}` });
        return;
      } else if (err) {
        res.status(400).json({ message: err.message || 'เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ' });
        return;
      }
      next();
    });
  },
  uploadAvatar
);

// ลบบัญชีผู้ใช้ (ลบข้อมูลและ Wishlist ทั้งหมด)
router.delete('/account', verifyToken, deleteAccount);

export default router;