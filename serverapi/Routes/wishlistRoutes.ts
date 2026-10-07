import { Router } from 'express';
import {
  getWishlist,
  checkInWishlist,
  addToWishlist,
  removeFromWishlist,
} from '../controllers/wishlistController';
import { verifyToken } from '../middlewares/authMiddleware';

const router = Router();

// ทุก Endpoint ของ Wishlist ต้องผ่านการยืนยันตัวตนด้วย JWT Token
router.use(verifyToken);

router.get('/', getWishlist);
router.get('/check/:gameId', checkInWishlist);
router.post('/', addToWishlist);
router.delete('/:gameId', removeFromWishlist);

export default router;
