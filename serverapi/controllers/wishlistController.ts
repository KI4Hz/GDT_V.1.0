import { Response } from 'express';
import db from '../utils/db';
import { AuthenticatedRequest } from '../types/auth';
import { WishlistRecord } from '../types/wishlist';

// GET /api/wishlist - ดึงรายการ wishlist ของ user ที่ล็อกอินอยู่
export const getWishlist = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(401).json({ message: 'กรุณาเข้าสู่ระบบก่อนใช้งาน' });
      return;
    }

    const items = await db<WishlistRecord>('wishlists')
      .where({ user_id: userId })
      .orderBy('saved_at', 'desc');

    res.status(200).json({
      success: true,
      data: items,
    });
  } catch (error) {
    console.error('getWishlist error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
  }
};

// GET /api/wishlist/check/:gameId - ตรวจสอบว่าเกมนี้อยู่ใน wishlist หรือไม่
export const checkInWishlist = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
    const { gameId } = req.params;

    if (!userId) {
      res.status(401).json({ message: 'กรุณาเข้าสู่ระบบก่อนใช้งาน' });
      return;
    }

    const item = await db<WishlistRecord>('wishlists')
      .where({ user_id: userId, game_id: gameId })
      .first();

    res.status(200).json({
      inWishlist: !!item,
      item: item || null,
    });
  } catch (error) {
    console.error('checkInWishlist error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
  }
};

// POST /api/wishlist - เพิ่มเกมเข้า wishlist
export const addToWishlist = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
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
    const existing = await db<WishlistRecord>('wishlists')
      .where({ user_id: userId, game_id })
      .first();

    if (existing) {
      res.status(200).json({
        message: 'เกมนี้อยู่ใน Wishlist แล้ว',
        id: existing.id,
      });
      return;
    }

    const [newId] = await db<WishlistRecord>('wishlists').insert({
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
  } catch (error) {
    console.error('addToWishlist error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
  }
};

// DELETE /api/wishlist/:gameId - ลบเกมออกจาก wishlist (รองรับทั้งส่ง id หรือ game_id)
export const removeFromWishlist = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(401).json({ message: 'กรุณาเข้าสู่ระบบก่อนใช้งาน' });
      return;
    }

    const { gameId } = req.params;

    // ลบโดยเช็คว่าตรงกับ game_id หรือ id ของตาราง
    const deletedCount = await db<WishlistRecord>('wishlists')
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
  } catch (error) {
    console.error('removeFromWishlist error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
  }
};
