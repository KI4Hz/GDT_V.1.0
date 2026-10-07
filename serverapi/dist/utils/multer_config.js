"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const multer_1 = __importDefault(require("multer"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const storage = multer_1.default.diskStorage({
    destination: (req, file, callback) => {
        const folder = path_1.default.resolve(__dirname, "../uploads/images");
        if (!fs_1.default.existsSync(folder)) {
            fs_1.default.mkdirSync(folder, { recursive: true });
        }
        callback(null, folder);
    },
    filename: (req, file, callback) => {
        const ext = path_1.default.extname(file.originalname) || ".jpg";
        callback(null, `avatar-${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
    },
});
const fileFilter = (req, file, callback) => {
    const isImageMime = file.mimetype.startsWith("image/");
    const isImageExt = /\.(jpe?g|png|gif|webp|bmp|svg)$/i.test(file.originalname);
    if (isImageMime || isImageExt) {
        callback(null, true);
    }
    else {
        callback(new Error("ไฟล์ที่อัปโหลดต้องเป็นรูปภาพเท่านั้น (JPG, PNG, WEBP)"));
    }
};
const multerConfig = {
    config: {
        storage,
        limits: { fileSize: 1024 * 1024 * 5 },
        fileFilter,
    },
    keyUpload: "photo",
};
exports.default = multerConfig;
