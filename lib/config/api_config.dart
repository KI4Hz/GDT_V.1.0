import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// ศูนย์กลางการตั้งค่า Endpoint และ Connection APIs ทั้งหมดของแอปพลิเคชัน
/// หากต้องการเปลี่ยน URL หรือเปลี่ยน Domain ของ API ในอนาคต ให้แก้ไขที่ไฟล์นี้จุดเดียว
class ApiConfig {
  ApiConfig._(); // ป้องกันการสร้าง Instance

  // ==========================================
  // CheapShark API & Assets Config
  // ==========================================

  /// Base URL สำหรับเรียก CheapShark REST API
  static const String cheapSharkBaseUrl = 'https://www.cheapshark.com/api/1.0';

  /// Base Web URL สำหรับลิงก์ Redirect และ Static Assets (เช่น Icons)
  static const String cheapSharkWebUrl = 'https://www.cheapshark.com';

  /// Base CDN สำหรับดึงรูป Header Banner คุณภาพสูงของเกมจาก Steam
  static const String steamCdnBaseUrl =
      'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps';

  /// Endpoint สำหรับดึงรายการดีลเกม (รองรับการกรองตามร้านค้า, คำค้นหา, เรียงลำดับ)
  static const String dealsEndpoint = '$cheapSharkBaseUrl/deals';

  /// Endpoint สำหรับดึงข้อมูลรายละเอียดเกมและราคาเปรียบเทียบทุกร้านค้า
  static const String gamesEndpoint = '$cheapSharkBaseUrl/games';

  /// Endpoint สำหรับดึงรายชื่อและสถานะของร้านค้าทั้งหมด
  static const String storesEndpoint = '$cheapSharkBaseUrl/stores';

  /// สร้าง URL สำหรับ Redirect ผู้ใช้ไปยังหน้าข้อเสนอของร้านค้าตาม dealID
  static String getDealRedirectUrl(String dealID) {
    return '$cheapSharkWebUrl/redirect?dealID=$dealID';
  }

  /// สร้าง URL สำหรับดึงรูป Icon ร้านค้าตามดัชนี (storeID - 1)
  static String getStoreIconUrl(int storeIndex) {
    return '$cheapSharkWebUrl/img/stores/icons/$storeIndex.png';
  }

  /// สร้าง URL สำหรับ Asset ที่ขึ้นต้นด้วย Relative path จาก CheapShark
  static String getStoreAssetUrl(String relativePath) {
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }
    final cleanPath = relativePath.startsWith('/')
        ? relativePath
        : '/$relativePath';
    return '$cheapSharkWebUrl$cleanPath';
  }

  /// สร้าง URL สำหรับดึงรูปภาพ Header ของเกมจาก Steam CDN
  static String getSteamHeaderBannerUrl(String steamAppID) {
    return '$steamCdnBaseUrl/$steamAppID/header.jpg';
  }

  // ==========================================
  // Currency Exchange API Config
  // ==========================================

  /// Endpoint สำหรับดึงอัตราแลกเปลี่ยนเงินตราต่างประเทศแบบ Real-time
  static const String currencyExchangeEndpoint =
      'https://open.er-api.com/v6/latest/USD';

  /// Timeout สำหรับการดึงอัตราแลกเปลี่ยนเงินตรา
  static const Duration currencyFetchTimeout = Duration(seconds: 4);

  // ==========================================
  // Custom Backend Server Config (Auth & Wishlist)
  // ==========================================

  /// Base URL ของเซิร์ฟเวอร์ Backend ประจำตัวผู้ใช้
  /// (รองรับ localhost สำหรับ Web/Desktop และ 10.0.2.2 สำหรับ Android Emulator)
  static String get backendBaseUrl {
    const customUrl = String.fromEnvironment('BACKEND_URL');
    if (customUrl.isNotEmpty) return customUrl;

    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://192.168.3.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  /// Endpoint สำหรับ Authentication (Login, Register, Profile)
  static String get authEndpoint => '$backendBaseUrl/auth';

  /// Endpoint สำหรับ Wishlist (Sync, Check, Add, Delete)
  static String get wishlistEndpoint => '$backendBaseUrl/wishlist';

  /// ดึง Host หลักของเซิร์ฟเวอร์ Backend (ตัด /api ออก) สำหรับเสิร์ฟไฟล์ Static
  static String get serverRootUrl {
    final base = backendBaseUrl;
    if (base.endsWith('/api')) {
      return base.substring(0, base.length - 4);
    }
    return base;
  }

  /// สร้าง Full URL สำหรับรูปภาพที่อัปโหลดไว้บนเซิร์ฟเวอร์
  static String getAvatarImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$serverRootUrl$cleanPath';
  }

  // ==========================================
  // Network Settings & Headers
  // ==========================================

  /// Timeout เริ่มต้นสำหรับการส่ง HTTP Request ทั่วไป
  static const Duration timeoutDuration = Duration(seconds: 15);

  /// Header พื้นฐานสำหรับการยิง API (CheapShark กำหนดให้มี User-Agent ที่ถูกต้อง)
  static const Map<String, String> defaultHeaders = {
    'User-Agent': 'GameDealTracker/1.0 (contact@example.com)',
    'Accept': 'application/json',
  };
}
