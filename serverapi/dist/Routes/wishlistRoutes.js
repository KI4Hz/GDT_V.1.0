"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const wishlistController_1 = require("../controllers/wishlistController");
const authMiddleware_1 = require("../middlewares/authMiddleware");
const router = (0, express_1.Router)();
// ทุก Endpoint ของ Wishlist ต้องผ่านการยืนยันตัวตนด้วย JWT Token
router.use(authMiddleware_1.verifyToken);
router.get('/', wishlistController_1.getWishlist);
router.get('/check/:gameId', wishlistController_1.checkInWishlist);
router.post('/', wishlistController_1.addToWishlist);
router.delete('/:gameId', wishlistController_1.removeFromWishlist);
exports.default = router;
