import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import fs from 'fs';
import path from 'path';
import db from '../utils/db';
import { UserRecord, UserPayload, AuthenticatedRequest, UpdateProfileBody } from '../types/auth';

const JWT_SECRET = process.env.JWT_SECRET || '113@secret';

const removeLocalAvatar = (avatarUrl?: string | null) => {
  if (!avatarUrl) return;
  try {
    const cleanUrl = avatarUrl.startsWith('/') ? avatarUrl.substring(1) : avatarUrl;
    const fullPath = path.resolve(__dirname, '..', cleanUrl);
    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath);
    }
  } catch (err) {
    console.error('Error removing local avatar file:', err);
  }
};

export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password, gamer_tag } = req.body;

    if (!email || !password) {
      res.status(400).json({ message: 'กรุณากรอก email และ password ให้ครบถ้วน' });
      return;
    }

    const existingUser = await db<UserRecord>('users').where({ email }).first();
    if (existingUser) {
      res.status(400).json({ message: 'อีเมลนี้ถูกใช้งานแล้ว' });
      return;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    const defaultTag = gamer_tag?.trim() || (email.includes('@') ? email.split('@')[0] : 'Gamer');

    const [newUserId] = await db<UserRecord>('users').insert({
      email,
      password: hashedPassword,
      gamer_tag: defaultTag,
      avatar_index: 0,
      avatar_url: null,
      bio: 'PC Gamer & Deal Hunter 🎮',
      favorite_store: 'Steam',
    });

    res.status(201).json({
      message: 'สมัครสมาชิกสำเร็จ',
      userId: newUserId,
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
  }
};

export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({ message: 'กรุณากรอก email และ password ให้ครบถ้วน' });
      return;
    }

    const user = await db<UserRecord>('users').where({ email }).first();
    if (!user) {
      res.status(401).json({ message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' });
      return;
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      res.status(401).json({ message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' });
      return;
    }

    const payload: UserPayload = {
      id: user.id,
      email: user.email,
    };

    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });

    res.status(200).json({
      message: 'เข้าสู่ระบบสำเร็จ',
      token,
      user: {
        id: user.id,
        email: user.email,
        gamer_tag: user.gamer_tag ?? (user.email.includes('@') ? user.email.split('@')[0] : 'Gamer'),
        avatar_index: user.avatar_index ?? 0,
        avatar_url: user.avatar_url ?? null,
        bio: user.bio ?? 'PC Gamer & Deal Hunter 🎮',
        favorite_store: user.favorite_store ?? 'Steam',
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
  }
};

export const getProfile = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(401).json({ message: 'ไม่พบข้อมูลผู้ใช้' });
      return;
    }

    const user = await db<UserRecord>('users').where({ id: userId }).first();
    if (!user) {
      res.status(404).json({ message: 'ไม่พบผู้ใช้นี้ในระบบ' });
      return;
    }

    res.status(200).json({
      message: 'ดึงข้อมูลโปรไฟล์สำเร็จ',
      user: {
        id: user.id,
        email: user.email,
        gamer_tag: user.gamer_tag ?? (user.email.includes('@') ? user.email.split('@')[0] : 'Gamer'),
        avatar_index: user.avatar_index ?? 0,
        avatar_url: user.avatar_url ?? null,
        bio: user.bio ?? 'PC Gamer & Deal Hunter 🎮',
        favorite_store: user.favorite_store ?? 'Steam',
      },
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
  }
};

export const updateProfile = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(401).json({ message: 'ไม่พบข้อมูลผู้ใช้' });
      return;
    }

    const currentUser = await db<UserRecord>('users').where({ id: userId }).first();
    if (!currentUser) {
      res.status(404).json({ message: 'ไม่พบผู้ใช้นี้ในระบบ' });
      return;
    }

    const { gamer_tag, avatar_index, avatar_url, bio, favorite_store } = req.body as UpdateProfileBody;

    const updateData: Partial<UserRecord> = {
      updated_at: new Date(),
    };

    if (gamer_tag !== undefined) updateData.gamer_tag = gamer_tag.trim();
    if (avatar_index !== undefined) updateData.avatar_index = Number(avatar_index);
    if (avatar_url !== undefined) {
      if (avatar_url === null || avatar_url === '') {
        removeLocalAvatar(currentUser.avatar_url);
        updateData.avatar_url = null;
      } else {
        updateData.avatar_url = avatar_url;
      }
    }
    if (bio !== undefined) updateData.bio = bio.trim();
    if (favorite_store !== undefined) updateData.favorite_store = favorite_store.trim();

    await db<UserRecord>('users').where({ id: userId }).update(updateData);

    const updatedUser = await db<UserRecord>('users').where({ id: userId }).first();

    res.status(200).json({
      message: 'อัปเดตโปรไฟล์สำเร็จ',
      user: {
        id: updatedUser?.id,
        email: updatedUser?.email,
        gamer_tag: updatedUser?.gamer_tag,
        avatar_index: updatedUser?.avatar_index,
        avatar_url: updatedUser?.avatar_url ?? null,
        bio: updatedUser?.bio,
        favorite_store: updatedUser?.favorite_store,
      },
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
  }
};

export const uploadAvatar = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(401).json({ message: 'ไม่พบข้อมูลผู้ใช้' });
      return;
    }

    if (!req.file) {
      res.status(400).json({ message: 'กรุณาเลือกไฟล์รูปภาพที่ต้องการอัปโหลด' });
      return;
    }

    const currentUser = await db<UserRecord>('users').where({ id: userId }).first();
    if (currentUser?.avatar_url) {
      removeLocalAvatar(currentUser.avatar_url);
    }

    const relativeUrl = `/uploads/images/${req.file.filename}`;

    await db<UserRecord>('users').where({ id: userId }).update({
      avatar_url: relativeUrl,
      updated_at: new Date(),
    });

    res.status(200).json({
      message: 'อัปโหลดรูปโปรไฟล์สำเร็จ',
      avatar_url: relativeUrl,
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ' });
  }
};

export const deleteAccount = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(401).json({ message: 'ไม่พบข้อมูลผู้ใช้' });
      return;
    }

    const user = await db<UserRecord>('users').where({ id: userId }).first();
    if (!user) {
      res.status(404).json({ message: 'ไม่พบผู้ใช้นี้ในระบบ' });
      return;
    }

    if (user.avatar_url) {
      removeLocalAvatar(user.avatar_url);
    }

    // Cascade delete wishlists will happen automatically due to foreign key
    await db<UserRecord>('users').where({ id: userId }).del();

    res.status(200).json({
      message: 'ลบบัญชีผู้ใช้และข้อมูลทั้งหมดเรียบร้อยแล้ว',
    });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดในการลบบัญชีผู้ใช้' });
  }
};