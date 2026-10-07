import 'package:flutter/foundation.dart';
import '../models/wishlist_item_model.dart';
import '../services/wishlist_service.dart';

/// Provider สำหรับจัดการรายการ Wishlist ของผู้ใช้ทั่วทั้งแอป
class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService;
  String? _token;

  WishlistProvider({WishlistService? wishlistService, String? token})
      : _wishlistService = wishlistService ?? WishlistService() {
    if (token != null) {
      _token = token;
      fetchWishlist();
    }
  }

  List<WishlistItemModel> _items = [];
  final Set<String> _wishlistedGameIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<WishlistItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // อัปเดต Token เมื่อสถานะการล็อกอินเปลี่ยน (ผ่าน ProxyProvider หรือ Auth Listener)
  void updateAuth(String? token) {
    if (_token != token) {
      _token = token;
      if (_token == null) {
        _items = [];
        _wishlistedGameIds.clear();
        notifyListeners();
      } else {
        fetchWishlist();
      }
    }
  }

  // ตรวจสอบว่า gameId นี้อยู่ใน Wishlist หรือไม่
  bool isWishlisted(String gameId) {
    return _wishlistedGameIds.contains(gameId);
  }

  // ดึงรายการ Wishlist ทั้งหมด
  Future<void> fetchWishlist() async {
    if (_token == null) {
      _items = [];
      _wishlistedGameIds.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _wishlistService.getWishlist(_token!);
      _items = results;
      _wishlistedGameIds.clear();
      for (final item in results) {
        _wishlistedGameIds.add(item.gameId);
      }
    } catch (e) {
      _errorMessage = 'ไม่สามารถโหลด Wishlist ได้';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // เพิ่มเกมเข้า Wishlist
  Future<bool> addToWishlist({
    required String gameId,
    required String title,
    required String salePrice,
    required String normalPrice,
    required String thumb,
  }) async {
    if (_token == null) return false;

    // Optimistic UI update
    _wishlistedGameIds.add(gameId);
    notifyListeners();

    final success = await _wishlistService.addToWishlist(
      _token!,
      gameId: gameId,
      title: title,
      salePrice: salePrice,
      normalPrice: normalPrice,
      thumb: thumb,
    );

    if (success) {
      await fetchWishlist();
      return true;
    } else {
      // Revert if failed
      _wishlistedGameIds.remove(gameId);
      notifyListeners();
      return false;
    }
  }

  // ลบเกมออกจาก Wishlist
  Future<bool> removeFromWishlist(String gameId) async {
    if (_token == null) return false;

    // Optimistic UI update
    _wishlistedGameIds.remove(gameId);
    _items.removeWhere((item) => item.gameId == gameId);
    notifyListeners();

    final success = await _wishlistService.removeFromWishlist(_token!, gameId);
    if (!success) {
      // Re-sync if failed
      await fetchWishlist();
      return false;
    }
    return true;
  }
}
