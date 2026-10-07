import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

/// Provider สำหรับจัดการสถานะ Authentication และข้อมูลผู้ใช้
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _authService.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  AuthService get authService => _authService;
  UserModel? get currentUser => _authService.currentUser;
  String? get token => _authService.token;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isLoading => _authService.isLoading;

  Future<Map<String, dynamic>> login(String email, String password) {
    return _authService.login(email, password);
  }

  Future<Map<String, dynamic>> register(String email, String password) {
    return _authService.register(email, password);
  }

  Future<void> updateProfile({
    required String gamerTag,
    required int avatarIndex,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    required String bio,
    required String favoriteStore,
  }) {
    return _authService.updateProfile(
      gamerTag: gamerTag,
      avatarIndex: avatarIndex,
      avatarUrl: avatarUrl,
      clearAvatarUrl: clearAvatarUrl,
      bio: bio,
      favoriteStore: favoriteStore,
    );
  }

  Future<Map<String, dynamic>> uploadAvatar(XFile file) {
    return _authService.uploadAvatar(file);
  }

  Future<Map<String, dynamic>> deleteAccount() {
    return _authService.deleteAccount();
  }

  Future<void> logout() {
    return _authService.logout();
  }
}
