import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/wishlist_item_model.dart';

class WishlistService {
  final String _baseUrl = ApiConfig.wishlistEndpoint;

  // GET: ดึงรายการ wishlist ทั้งหมดของ user
  Future<List<WishlistItemModel>> getWishlist(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((item) => WishlistItemModel.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Wishlist get error: $e');
      return [];
    }
  }

  // GET: ตรวจสอบว่าเกมนี้อยู่ใน wishlist หรือไม่
  Future<bool> checkInWishlist(String token, String gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/check/$gameId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['inWishlist'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Wishlist check error: $e');
      return false;
    }
  }

  // POST: เพิ่มเกมเข้า wishlist
  Future<bool> addToWishlist(
    String token, {
    required String gameId,
    required String title,
    required String salePrice,
    required String normalPrice,
    required String thumb,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'game_id': gameId,
          'title': title,
          'sale_price': double.tryParse(salePrice) ?? 0.0,
          'normal_price': double.tryParse(normalPrice) ?? 0.0,
          'thumb': thumb,
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Wishlist add error: $e');
      return false;
    }
  }

  // DELETE: ลบเกมออกจาก wishlist
  Future<bool> removeFromWishlist(String token, String gameId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$gameId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Wishlist remove error: $e');
      return false;
    }
  }
}
