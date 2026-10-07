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
exports.deleteAccount = exports.uploadAvatar = exports.updateProfile = exports.getProfile = exports.login = exports.register = void 0;
const bcrypt_1 = __importDefault(require("bcrypt"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const db_1 = __importDefault(require("../utils/db"));
const JWT_SECRET = process.env.JWT_SECRET || '113@secret';
const removeLocalAvatar = (avatarUrl) => {
    if (!avatarUrl)
        return;
    try {
        const cleanUrl = avatarUrl.startsWith('/') ? avatarUrl.substring(1) : avatarUrl;
        const fullPath = path_1.default.resolve(__dirname, '..', cleanUrl);
        if (fs_1.default.existsSync(fullPath)) {
            fs_1.default.unlinkSync(fullPath);
        }
    }
    catch (err) {
        console.error('Error removing local avatar file:', err);
    }
};
const register = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { email, password, gamer_tag } = req.body;
        if (!email || !password) {
            res.status(400).json({ message: 'กรุณากรอก email และ password ให้ครบถ้วน' });
            return;
        }
        const existingUser = yield (0, db_1.default)('users').where({ email }).first();
        if (existingUser) {
            res.status(400).json({ message: 'อีเมลนี้ถูกใช้งานแล้ว' });
            return;
        }
        const salt = yield bcrypt_1.default.genSalt(10);
        const hashedPassword = yield bcrypt_1.default.hash(password, salt);
        const defaultTag = (gamer_tag === null || gamer_tag === void 0 ? void 0 : gamer_tag.trim()) || (email.includes('@') ? email.split('@')[0] : 'Gamer');
        const [newUserId] = yield (0, db_1.default)('users').insert({
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
    }
    catch (error) {
        console.error('Register error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
    }
});
exports.register = register;
const login = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c, _d, _e;
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            res.status(400).json({ message: 'กรุณากรอก email และ password ให้ครบถ้วน' });
            return;
        }
        const user = yield (0, db_1.default)('users').where({ email }).first();
        if (!user) {
            res.status(401).json({ message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' });
            return;
        }
        const isMatch = yield bcrypt_1.default.compare(password, user.password);
        if (!isMatch) {
            res.status(401).json({ message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' });
            return;
        }
        const payload = {
            id: user.id,
            email: user.email,
        };
        const token = jsonwebtoken_1.default.sign(payload, JWT_SECRET, { expiresIn: '7d' });
        res.status(200).json({
            message: 'เข้าสู่ระบบสำเร็จ',
            token,
            user: {
                id: user.id,
                email: user.email,
                gamer_tag: (_a = user.gamer_tag) !== null && _a !== void 0 ? _a : (user.email.includes('@') ? user.email.split('@')[0] : 'Gamer'),
                avatar_index: (_b = user.avatar_index) !== null && _b !== void 0 ? _b : 0,
                avatar_url: (_c = user.avatar_url) !== null && _c !== void 0 ? _c : null,
                bio: (_d = user.bio) !== null && _d !== void 0 ? _d : 'PC Gamer & Deal Hunter 🎮',
                favorite_store: (_e = user.favorite_store) !== null && _e !== void 0 ? _e : 'Steam',
            },
        });
    }
    catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
    }
});
exports.login = login;
const getProfile = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _f, _g, _h, _j, _k, _l;
    try {
        const userId = (_f = req.user) === null || _f === void 0 ? void 0 : _f.id;
        if (!userId) {
            res.status(401).json({ message: 'ไม่พบข้อมูลผู้ใช้' });
            return;
        }
        const user = yield (0, db_1.default)('users').where({ id: userId }).first();
        if (!user) {
            res.status(404).json({ message: 'ไม่พบผู้ใช้นี้ในระบบ' });
            return;
        }
        res.status(200).json({
            message: 'ดึงข้อมูลโปรไฟล์สำเร็จ',
            user: {
                id: user.id,
                email: user.email,
                gamer_tag: (_g = user.gamer_tag) !== null && _g !== void 0 ? _g : (user.email.includes('@') ? user.email.split('@')[0] : 'Gamer'),
                avatar_index: (_h = user.avatar_index) !== null && _h !== void 0 ? _h : 0,
                avatar_url: (_j = user.avatar_url) !== null && _j !== void 0 ? _j : null,
                bio: (_k = user.bio) !== null && _k !== void 0 ? _k : 'PC Gamer & Deal Hunter 🎮',
                favorite_store: (_l = user.favorite_store) !== null && _l !== void 0 ? _l : 'Steam',
            },
        });
    }
    catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
    }
});
exports.getProfile = getProfile;
const updateProfile = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _m, _o;
    try {
        const userId = (_m = req.user) === null || _m === void 0 ? void 0 : _m.id;
        if (!userId) {
            res.status(401).json({ message: 'ไม่พบข้อมูลผู้ใช้' });
            return;
        }
        const currentUser = yield (0, db_1.default)('users').where({ id: userId }).first();
        if (!currentUser) {
            res.status(404).json({ message: 'ไม่พบผู้ใช้นี้ในระบบ' });
            return;
        }
        const { gamer_tag, avatar_index, avatar_url, bio, favorite_store } = req.body;
        const updateData = {
            updated_at: new Date(),
        };
        if (gamer_tag !== undefined)
            updateData.gamer_tag = gamer_tag.trim();
        if (avatar_index !== undefined)
            updateData.avatar_index = Number(avatar_index);
        if (avatar_url !== undefined) {
            if (avatar_url === null || avatar_url === '') {
                removeLocalAvatar(currentUser.avatar_url);
                updateData.avatar_url = null;
            }
            else {
                updateData.avatar_url = avatar_url;
            }
        }
        if (bio !== undefined)
            updateData.bio = bio.trim();
        if (favorite_store !== undefined)
            updateData.favorite_store = favorite_store.trim();
        yield (0, db_1.default)('users').where({ id: userId }).update(updateData);
        const updatedUser = yield (0, db_1.default)('users').where({ id: userId }).first();
        res.status(200).json({
            message: 'อัปเดตโปรไฟล์สำเร็จ',
            user: {
                id: updatedUser === null || updatedUser === void 0 ? void 0 : updatedUser.id,
                email: updatedUser === null || updatedUser === void 0 ? void 0 : updatedUser.email,
                gamer_tag: updatedUser === null || updatedUser === void 0 ? void 0 : updatedUser.gamer_tag,
                avatar_index: updatedUser === null || updatedUser === void 0 ? void 0 : updatedUser.avatar_index,
                avatar_url: (_o = updatedUser === null || updatedUser === void 0 ? void 0 : updatedUser.avatar_url) !== null && _o !== void 0 ? _o : null,
                bio: updatedUser === null || updatedUser === void 0 ? void 0 : updatedUser.bio,
                favorite_store: updatedUser === null || updatedUser === void 0 ? void 0 : updatedUser.favorite_store,
            },
        });
    }
    catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์' });
    }
});
exports.updateProfile = updateProfile;
const uploadAvatar = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _p;
    try {
        const userId = (_p = req.user) === null || _p === void 0 ? void 0 : _p.id;
        if (!userId) {
            res.status(401).json({ message: 'ไม่พบข้อมูลผู้ใช้' });
            return;
        }
        if (!req.file) {
            res.status(400).json({ message: 'กรุณาเลือกไฟล์รูปภาพที่ต้องการอัปโหลด' });
            return;
        }
        const currentUser = yield (0, db_1.default)('users').where({ id: userId }).first();
        if (currentUser === null || currentUser === void 0 ? void 0 : currentUser.avatar_url) {
            removeLocalAvatar(currentUser.avatar_url);
        }
        const relativeUrl = `/uploads/images/${req.file.filename}`;
        yield (0, db_1.default)('users').where({ id: userId }).update({
            avatar_url: relativeUrl,
            updated_at: new Date(),
        });
        res.status(200).json({
            message: 'อัปโหลดรูปโปรไฟล์สำเร็จ',
            avatar_url: relativeUrl,
        });
    }
    catch (error) {
        console.error('Upload avatar error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ' });
    }
});
exports.uploadAvatar = uploadAvatar;
const deleteAccount = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _q;
    try {
        const userId = (_q = req.user) === null || _q === void 0 ? void 0 : _q.id;
        if (!userId) {
            res.status(401).json({ message: 'ไม่พบข้อมูลผู้ใช้' });
            return;
        }
        const user = yield (0, db_1.default)('users').where({ id: userId }).first();
        if (!user) {
            res.status(404).json({ message: 'ไม่พบผู้ใช้นี้ในระบบ' });
            return;
        }
        if (user.avatar_url) {
            removeLocalAvatar(user.avatar_url);
        }
        // Cascade delete wishlists will happen automatically due to foreign key
        yield (0, db_1.default)('users').where({ id: userId }).del();
        res.status(200).json({
            message: 'ลบบัญชีผู้ใช้และข้อมูลทั้งหมดเรียบร้อยแล้ว',
        });
    }
    catch (error) {
        console.error('Delete account error:', error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดในการลบบัญชีผู้ใช้' });
    }
});
exports.deleteAccount = deleteAccount;
