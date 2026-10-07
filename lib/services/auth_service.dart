import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// รายการอวตารของเกมเมอร์ที่สามารถเลือกปรับแต่งได้
class GamerAvatar {
  final String id;
  final String name;
  final IconData icon;
  final Color primaryColor;
  final Color glowColor;

  const GamerAvatar({
    required this.id,
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.glowColor,
  });

  static const List<GamerAvatar> list = [
    GamerAvatar(
      id: 'cyber_pad',
      name: 'Cyber Pad',
      icon: Icons.sports_esports_rounded,
      primaryColor: Color(0xFF00E676), // Neon Green
      glowColor: Color(0x6600E676),
    ),
    GamerAvatar(
      id: 'neon_bot',
      name: 'Neon Bot',
      icon: Icons.smart_toy_rounded,
      primaryColor: Color(0xFF00E5FF), // Neon Cyan
      glowColor: Color(0x6600E5FF),
    ),
    GamerAvatar(
      id: 'astro_star',
      name: 'Astro Star',
      icon: Icons.rocket_launch_rounded,
      primaryColor: Color(0xFFFF4081), // Neon Pink
      glowColor: Color(0x66FF4081),
    ),
    GamerAvatar(
      id: 'pro_streamer',
      name: 'Pro Streamer',
      icon: Icons.headset_mic_rounded,
      primaryColor: Color(0xFFB388FF), // Violet
      glowColor: Color(0x66B388FF),
    ),
    GamerAvatar(
      id: 'vanguard',
      name: 'Vanguard',
      icon: Icons.shield_rounded,
      primaryColor: Color(0xFFFFD600), // Electric Gold
      glowColor: Color(0x66FFD600),
    ),
    GamerAvatar(
      id: 'speed_runner',
      name: 'Speed Runner',
      icon: Icons.bolt_rounded,
      primaryColor: Color(0xFFFF6D00), // Neon Amber
      glowColor: Color(0x66FF6D00),
    ),
    GamerAvatar(
      id: 'shadow_op',
      name: 'Shadow Op',
      icon: Icons.visibility_rounded,
      primaryColor: Color(0xFF64FFDA), // Mint
      glowColor: Color(0x6664FFDA),
    ),
    GamerAvatar(
      id: 'overclocked',
      name: 'Overclocked',
      icon: Icons.local_fire_department_rounded,
      primaryColor: Color(0xFFFF1744), // Crimson
      glowColor: Color(0x66FF1744),
    ),
  ];

  static GamerAvatar getByIndex(int index) {
    if (index >= 0 && index < list.length) {
      return list[index];
    }
    return list[0];
  }
}

class UserModel {
  final int? id;
  final String email;
  final String gamerTag;
  final int avatarIndex;
  final String? avatarUrl;
  final String bio;
  final String favoriteStore;

  UserModel({
    this.id,
    required this.email,
    String? gamerTag,
    this.avatarIndex = 0,
    this.avatarUrl,
    String? bio,
    String? favoriteStore,
  })  : gamerTag = (gamerTag != null && gamerTag.trim().isNotEmpty)
            ? gamerTag.trim()
            : (email.contains('@') ? email.split('@').first : 'Gamer'),
        bio = (bio != null && bio.trim().isNotEmpty)
            ? bio.trim()
            : 'PC Gamer & Deal Hunter 🎮',
        favoriteStore = (favoriteStore != null && favoriteStore.isNotEmpty)
            ? favoriteStore
            : 'Steam';

  GamerAvatar get avatar => GamerAvatar.getByIndex(avatarIndex);

  /// ดึง URL เต็มของรูปโปรไฟล์ที่อัปโหลดไว้ (ถ้ามี)
  String? get fullAvatarUrl => (avatarUrl != null && avatarUrl!.isNotEmpty)
      ? ApiConfig.getAvatarImageUrl(avatarUrl!)
      : null;

  /// ตรวจสอบว่าผู้ใช้ตั้งรูปโปรไฟล์แบบอัปโหลดเองหรือไม่
  bool get hasCustomAvatar => fullAvatarUrl != null;

  UserModel copyWith({
    String? gamerTag,
    int? avatarIndex,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    String? bio,
    String? favoriteStore,
  }) {
    return UserModel(
      id: id,
      email: email,
      gamerTag: gamerTag ?? this.gamerTag,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      bio: bio ?? this.bio,
      favoriteStore: favoriteStore ?? this.favoriteStore,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      email: json['email'] ?? '',
      gamerTag: json['gamer_tag'] ?? json['gamerTag'],
      avatarIndex: json['avatar_index'] ?? json['avatarIndex'] ?? 0,
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      bio: json['bio'],
      favoriteStore: json['favorite_store'] ?? json['favoriteStore'],
    );
  }
}

class AuthService with ChangeNotifier {
  String _baseUrl = ApiConfig.authEndpoint;
  String? _token;
  UserModel? _currentUser;
  bool _isLoading = false;

  String? get token => _token;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  AuthService() {
    _loadStoredAuth();
  }

  void setBaseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }

  String _userKey({int? id, String? email}) {
    if (id != null) return 'user_$id';
    if (email != null && email.isNotEmpty) {
      return 'user_${email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    }
    return 'user_default';
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final email = prefs.getString('auth_email');
      final id = prefs.getInt('auth_user_id');

      if (_token != null && email != null) {
        final key = _userKey(id: id, email: email);
        final gamerTag = prefs.getString('${key}_gamer_tag');
        final avatarIndex = prefs.getInt('${key}_avatar_index') ?? 0;
        final avatarUrl = prefs.getString('${key}_avatar_url');
        final bio = prefs.getString('${key}_bio');
        final favoriteStore = prefs.getString('${key}_fav_store');

        _currentUser = UserModel(
          id: id,
          email: email,
          gamerTag: gamerTag,
          avatarIndex: avatarIndex,
          avatarUrl: avatarUrl,
          bio: bio,
          favoriteStore: favoriteStore,
        );
        notifyListeners();

        // Refresh profile from backend in background to stay in sync
        fetchProfile();
      }
    } catch (_) {}
  }

  // Register with Email and Password
  Future<Map<String, dynamic>> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'สมัครสมาชิกสำเร็จ'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'การสมัครสมาชิกล้มเหลว'};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e'};
    }
  }

  // Login with Email and Password
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      _isLoading = false;

      if (response.statusCode == 200 && data['token'] != null) {
        _token = data['token'];
        if (data['user'] != null) {
          _currentUser = UserModel.fromJson(data['user']);
        } else {
          _currentUser = UserModel(email: email.trim());
        }

        // Save session locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('auth_email', _currentUser!.email);
        if (_currentUser!.id != null) {
          await prefs.setInt('auth_user_id', _currentUser!.id!);
        }

        // Clean up legacy global keys if any
        await prefs.remove('auth_gamer_tag');
        await prefs.remove('auth_avatar_index');
        await prefs.remove('auth_avatar_url');
        await prefs.remove('auth_bio');
        await prefs.remove('auth_fav_store');

        // Persist profile to local cache
        final key = _userKey(id: _currentUser!.id, email: _currentUser!.email);
        await prefs.setString('${key}_gamer_tag', _currentUser!.gamerTag);
        await prefs.setInt('${key}_avatar_index', _currentUser!.avatarIndex);
        if (_currentUser!.avatarUrl != null) {
          await prefs.setString('${key}_avatar_url', _currentUser!.avatarUrl!);
        } else {
          await prefs.remove('${key}_avatar_url');
        }
        await prefs.setString('${key}_bio', _currentUser!.bio);
        await prefs.setString('${key}_fav_store', _currentUser!.favoriteStore);

        notifyListeners();
        return {'success': true, 'message': data['message'] ?? 'เข้าสู่ระบบสำเร็จ'};
      } else {
        notifyListeners();
        return {'success': false, 'message': data['message'] ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง'};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e'};
    }
  }

  // Fetch Profile from Server
  Future<void> fetchProfile() async {
    if (_token == null) return;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user'] != null) {
          _currentUser = UserModel.fromJson(data['user']);
          final prefs = await SharedPreferences.getInstance();
          final key = _userKey(id: _currentUser!.id, email: _currentUser!.email);
          await prefs.setString('${key}_gamer_tag', _currentUser!.gamerTag);
          await prefs.setInt('${key}_avatar_index', _currentUser!.avatarIndex);
          if (_currentUser!.avatarUrl != null) {
            await prefs.setString('${key}_avatar_url', _currentUser!.avatarUrl!);
          } else {
            await prefs.remove('${key}_avatar_url');
          }
          await prefs.setString('${key}_bio', _currentUser!.bio);
          await prefs.setString('${key}_fav_store', _currentUser!.favoriteStore);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch profile from server: $e');
    }
  }

  // Upload Custom Avatar Picture
  Future<Map<String, dynamic>> uploadAvatar(XFile file) async {
    if (_token == null) {
      return {'success': false, 'message': 'กรุณาเข้าสู่ระบบก่อนอัปโหลดรูปภาพ'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload-avatar'),
      );
      request.headers['Authorization'] = 'Bearer $_token';

      final fileName = file.name.isNotEmpty
          ? file.name
          : 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ext = fileName.split('.').last.toLowerCase();
      String subType = 'jpeg';
      if (ext == 'png') subType = 'png';
      if (ext == 'webp') subType = 'webp';
      if (ext == 'gif') subType = 'gif';

      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: fileName,
        contentType: MediaType('image', subType),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (HTTP ${response.statusCode})',
        };
      }

      _isLoading = false;

      if (response.statusCode == 200 && data['avatar_url'] != null) {
        final newAvatarUrl = data['avatar_url'] as String;
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(avatarUrl: newAvatarUrl);
          final prefs = await SharedPreferences.getInstance();
          final key = _userKey(id: _currentUser!.id, email: _currentUser!.email);
          await prefs.setString('${key}_avatar_url', newAvatarUrl);
        }
        notifyListeners();
        return {
          'success': true,
          'avatar_url': newAvatarUrl,
          'message': data['message'] ?? 'อัปโหลดรูปโปรไฟล์สำเร็จ',
        };
      } else {
        notifyListeners();
        return {
          'success': false,
          'message': data['message'] ?? 'อัปโหลดรูปภาพล้มเหลว (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการอัปโหลด: $e'};
    }
  }

  // Update Gamer Profile Customization
  Future<void> updateProfile({
    required String gamerTag,
    required int avatarIndex,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    required String bio,
    required String favoriteStore,
  }) async {
    if (_currentUser == null) return;

    final updatedAvatarUrl = clearAvatarUrl ? null : (avatarUrl ?? _currentUser!.avatarUrl);

    _currentUser = _currentUser!.copyWith(
      gamerTag: gamerTag,
      avatarIndex: avatarIndex,
      avatarUrl: updatedAvatarUrl,
      clearAvatarUrl: clearAvatarUrl,
      bio: bio,
      favoriteStore: favoriteStore,
    );

    final prefs = await SharedPreferences.getInstance();
    final key = _userKey(id: _currentUser!.id, email: _currentUser!.email);

    await prefs.setString('${key}_gamer_tag', gamerTag);
    await prefs.setInt('${key}_avatar_index', avatarIndex);
    if (updatedAvatarUrl != null) {
      await prefs.setString('${key}_avatar_url', updatedAvatarUrl);
    } else {
      await prefs.remove('${key}_avatar_url');
    }
    await prefs.setString('${key}_bio', bio);
    await prefs.setString('${key}_fav_store', favoriteStore);

    notifyListeners();

    // Sync changes to backend server
    if (_token != null) {
      try {
        await http.put(
          Uri.parse('$_baseUrl/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode({
            'gamer_tag': gamerTag,
            'avatar_index': avatarIndex,
            'avatar_url': updatedAvatarUrl,
            'bio': bio,
            'favorite_store': favoriteStore,
          }),
        );
      } catch (e) {
        debugPrint('Failed to sync profile to server: $e');
      }
    }
  }

  // Delete User Account (Irreversible)
  Future<Map<String, dynamic>> deleteAccount() async {
    if (_token == null) {
      return {'success': false, 'message': 'กรุณาเข้าสู่ระบบก่อนทำการลบบัญชี'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/account'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      final data = jsonDecode(response.body);
      _isLoading = false;

      if (response.statusCode == 200) {
        await logout();
        return {'success': true, 'message': data['message'] ?? 'ลบบัญชีผู้ใช้เรียบร้อยแล้ว'};
      } else {
        notifyListeners();
        return {'success': false, 'message': data['message'] ?? 'ไม่สามารถลบบัญชีได้'};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'เกิดข้อผิดพลาดในการลบบัญชี: $e'};
    }
  }

  // Logout
  Future<void> logout() async {
    final key = _currentUser != null
        ? _userKey(id: _currentUser!.id, email: _currentUser!.email)
        : null;

    _token = null;
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_email');
      await prefs.remove('auth_user_id');
      await prefs.remove('auth_gamer_tag');
      await prefs.remove('auth_avatar_index');
      await prefs.remove('auth_avatar_url');
      await prefs.remove('auth_bio');
      await prefs.remove('auth_fav_store');
      if (key != null) {
        await prefs.remove('${key}_avatar_url');
      }
    } catch (_) {}
    notifyListeners();
  }
}
