import { Request } from "express";
import multer, { FileFilterCallback } from "multer";
import fs from "fs";
import path from "path";

const storage = multer.diskStorage({
  destination: (
    req: Request,
    file: Express.Multer.File,
    callback: (error: Error | null, destination: string) => void
  ) => {
    const folder = path.resolve(__dirname, "../uploads/images");
    if (!fs.existsSync(folder)) {
      fs.mkdirSync(folder, { recursive: true });
    }
    callback(null, folder);
  },
  filename: (
    req: Request,
    file: Express.Multer.File,
    callback: (error: Error | null, filename: string) => void
  ) => {
    const ext = path.extname(file.originalname) || ".jpg";
    callback(null, `avatar-${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  },
});

const fileFilter = (
  req: Request,
  file: Express.Multer.File,
  callback: FileFilterCallback
) => {
  const isImageMime = file.mimetype.startsWith("image/");
  const isImageExt = /\.(jpe?g|png|gif|webp|bmp|svg)$/i.test(file.originalname);
  if (isImageMime || isImageExt) {
    callback(null, true);
  } else {
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

export default multerConfig;