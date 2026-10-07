import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth/terminal_input_field.dart';
import 'wishlist_screen.dart';

class AuthScreen extends StatefulWidget {
  final AuthService? authService;
  final bool initialIsRegister;

  const AuthScreen({
    super.key,
    this.authService,
    this.initialIsRegister = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late bool _isRegister;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode(bool isRegister) {
    if (_isRegister == isRegister) return;
    setState(() {
      _isRegister = isRegister;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit(AuthProvider authProvider) async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isRegister) {
      final res = await authProvider.register(email, password);
      if (!mounted) return;

      if (res['success'] == true) {
        // Auto-login after successful register
        final loginRes = await authProvider.login(email, password);
        if (!mounted) return;

        if (loginRes['success'] == true) {
          _showFeedback('สมัครสมาชิกและเข้าสู่ระบบสำเร็จ!', isError: false);
          Navigator.of(context).pop();
        } else {
          _showFeedback('สมัครสมาชิกสำเร็จ กรุณาเข้าสู่ระบบ', isError: false);
          setState(() => _isRegister = false);
        }
      } else {
        setState(() => _errorMessage = res['message']);
      }
    } else {
      final res = await authProvider.login(email, password);
      if (!mounted) return;

      if (res['success'] == true) {
        _showFeedback('เข้าสู่ระบบสำเร็จ ยินดีต้อนรับกลับ!', isError: false);
        Navigator.of(context).pop();
      } else {
        setState(() => _errorMessage = res['message']);
      }
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surfaceElevated,
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_rounded,
              color: isError ? Colors.redAccent : AppTheme.neonGreen,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isAuth = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: isAuth
                ? _buildLoggedInProfile(user!, authProvider)
                : _buildAuthForm(authProvider),
          ),
        ),
      ),
    );
  }

  // View when user is already logged in
  Widget _buildLoggedInProfile(UserModel user, AuthProvider authProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Glowing Gamer Avatar with Edit Badge
        InkWell(
          onTap: () => _showEditProfileModal(context, user, authProvider),
          borderRadius: BorderRadius.circular(55),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceElevated,
                  border: Border.all(
                    color: user.avatar.primaryColor,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: user.avatar.glowColor,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: user.hasCustomAvatar
                      ? Image.network(
                          user.fullAvatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              user.avatar.icon,
                              color: user.avatar.primaryColor,
                              size: 46,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            user.avatar.icon,
                            color: user.avatar.primaryColor,
                            size: 46,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: user.avatar.primaryColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: user.avatar.glowColor,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 13,
                    color: user.avatar.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Gamer Tag
        Text(
          user.gamerTag,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),

        // User Email
        Text(
          user.email,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),

        // Badges Row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: user.avatar.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: user.avatar.primaryColor.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.avatar.icon,
                    size: 12,
                    color: user.avatar.primaryColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    user.avatar.name.toUpperCase(),
                    style: TextStyle(
                      color: user.avatar.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            if (user.id != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Text(
                  'ID: #${user.id.toString().padLeft(4, '0')}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),

        // Bio Quote Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.format_quote_rounded,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  user.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Gamer Quick Stats
        Builder(
          builder: (context) {
            final wishlistCount =
                context.watch<WishlistProvider>().items.length;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    icon: Icons.bookmark_rounded,
                    iconColor: AppTheme.neonCyan,
                    value: '$wishlistCount',
                    label: 'Wishlisted',
                  ),
                  Container(
                    height: 34,
                    width: 1,
                    color: AppTheme.surfaceBorder,
                  ),
                  _buildStatColumn(
                    icon: Icons.storefront_rounded,
                    iconColor: AppTheme.neonGreen,
                    value: user.favoriteStore,
                    label: 'Fav Store',
                  ),
                  Container(
                    height: 34,
                    width: 1,
                    color: AppTheme.surfaceBorder,
                  ),
                  _buildStatColumn(
                    icon: Icons.cloud_done_rounded,
                    iconColor: const Color(0xFF64FFDA),
                    value: 'Synced',
                    label: 'Cloud Save',
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Gamer Feature Options (Fake notifications removed)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Column(
            children: [
              _buildProfileOption(
                icon: Icons.tune_rounded,
                iconColor: user.avatar.primaryColor,
                title: 'Customize Profile',
                subtitle: 'Change avatar, gamer tag, bio & favorite store',
                onTap: () => _showEditProfileModal(context, user, authProvider),
              ),
              const Divider(color: AppTheme.surfaceBorder, height: 24),
              Builder(
                builder: (context) {
                  final wishlistCount =
                      context.watch<WishlistProvider>().items.length;
                  return _buildProfileOption(
                    icon: Icons.bookmark_added_rounded,
                    iconColor: AppTheme.neonCyan,
                    title: 'My Wishlist & Price Alerts',
                    subtitle: '$wishlistCount games tracked in cloud',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WishlistScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Logout Button
        OutlinedButton.icon(
          onPressed: () => _showLogoutConfirmation(context, user, authProvider),
          icon: const Icon(
            Icons.logout_rounded,
            color: Colors.redAccent,
            size: 18,
          ),
          label: const Text(
            'LOGOUT',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  // Confirmation dialog before logging out
  Future<void> _showLogoutConfirmation(
    BuildContext context,
    UserModel user,
    AuthProvider authProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.redAccent.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ยืนยันออกจากระบบ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Text(
            'คุณต้องการออกจากระบบบัญชี "${user.gamerTag}" ใช่หรือไม่?\nรายการ Wishlist จะยังคงถูกบันทึกไว้ใน Cloud',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(
                Icons.logout_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await authProvider.logout();
      if (context.mounted) {
        _showFeedback('ออกจากระบบเรียบร้อย');
      }
    }
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Interactive Bottom Sheet to customize Gamer Profile
  void _showEditProfileModal(
    BuildContext context,
    UserModel user,
    AuthProvider authProvider,
  ) {
    int selectedAvatarIndex = user.avatarIndex;
    final tagController = TextEditingController(text: user.gamerTag);
    final bioController = TextEditingController(text: user.bio);
    String selectedStore = user.favoriteStore;
    XFile? pickedImageFile;
    bool removeCustomImage = false;
    bool isSaving = false;

    const availableStores = [
      'Steam',
      'Epic Games',
      'GOG',
      'Ubisoft',
      'Origin',
      'All Stores',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final activeAvatar = GamerAvatar.getByIndex(selectedAvatarIndex);
            final hasCustomPhoto = pickedImageFile != null ||
                (user.hasCustomAvatar && !removeCustomImage);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: activeAvatar.primaryColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeAvatar.glowColor,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dragger pill
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sheet Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              color: activeAvatar.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'CUSTOMIZE PROFILE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.surfaceBorder, height: 16),
                    const SizedBox(height: 8),

                    // Section: Custom Profile Photo
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasCustomPhoto
                              ? activeAvatar.primaryColor
                              : AppTheme.surfaceBorder,
                          width: hasCustomPhoto ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceElevated,
                              border: Border.all(
                                color: activeAvatar.primaryColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activeAvatar.glowColor,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: pickedImageFile != null
                                  ? (kIsWeb
                                      ? Image.network(
                                          pickedImageFile!.path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(pickedImageFile!.path),
                                          fit: BoxFit.cover,
                                        ))
                                  : (user.hasCustomAvatar && !removeCustomImage
                                      ? Image.network(
                                          user.fullAvatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.person_rounded,
                                            color: activeAvatar.primaryColor,
                                            size: 28,
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            activeAvatar.icon,
                                            color: activeAvatar.primaryColor,
                                            size: 26,
                                          ),
                                        )),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasCustomPhoto
                                      ? 'CUSTOM PHOTO ACTIVE'
                                      : 'UPLOAD PROFILE PICTURE',
                                  style: TextStyle(
                                    color: activeAvatar.primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  pickedImageFile != null
                                      ? 'รูปใหม่พร้อมบันทึก'
                                      : (user.hasCustomAvatar && !removeCustomImage
                                          ? 'ใช้รูปที่คุณอัปโหลดไว้'
                                          : 'ใส่รูปตัวเองได้จากคลังภาพ'),
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        try {
                                          final picker = ImagePicker();
                                          final picked = await picker.pickImage(
                                            source: ImageSource.gallery,
                                            maxWidth: 1024,
                                            maxHeight: 1024,
                                            imageQuality: 85,
                                          );
                                          if (picked != null) {
                                            setModalState(() {
                                              pickedImageFile = picked;
                                              removeCustomImage = false;
                                            });
                                          }
                                        } catch (e) {
                                          debugPrint('Error picking image: $e');
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: activeAvatar.primaryColor
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: activeAvatar.primaryColor
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.photo_library_rounded,
                                              size: 13,
                                              color: activeAvatar.primaryColor,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              hasCustomPhoto ? 'เปลี่ยนรูป' : 'เลือกรูปภาพ',
                                              style: TextStyle(
                                                color: activeAvatar.primaryColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (hasCustomPhoto) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          setModalState(() {
                                            pickedImageFile = null;
                                            removeCustomImage = true;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.redAccent
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.delete_outline_rounded,
                                                size: 13,
                                                color: Colors.redAccent,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'ลบรูป',
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Section 1: Choose Avatar
                    Text(
                      'OR SELECT CYBER AVATAR (${activeAvatar.name})',
                      style: TextStyle(
                        color: activeAvatar.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.84,
                      ),
                      itemCount: GamerAvatar.list.length,
                      itemBuilder: (context, index) {
                        final avatar = GamerAvatar.list[index];
                        final isSelected = selectedAvatarIndex == index;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedAvatarIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? avatar.primaryColor.withValues(alpha: 0.15)
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? avatar.primaryColor
                                    : AppTheme.surfaceBorder,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: avatar.glowColor,
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      avatar.icon,
                                      color: avatar.primaryColor,
                                      size: 28,
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        right: -6,
                                        bottom: -6,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: avatar.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 10,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  avatar.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Gamer Tag
                    const Text(
                      'GAMER TAG',
                      style: TextStyle(
                        color: AppTheme.neonCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tagController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLength: 24,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surface,
                        counterStyle: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                        prefixIcon: const Icon(
                          Icons.videogame_asset_rounded,
                          color: AppTheme.neonCyan,
                          size: 20,
                        ),
                        hintText: 'Enter your gamer tag',
                        hintStyle: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppTheme.surfaceBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppTheme.neonCyan,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Section 3: Bio / Status
                    const Text(
                      'BIO / STATUS',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bioController,
                      maxLength: 60,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surface,
                        counterStyle: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                        prefixIcon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: AppTheme.neonGreen,
                          size: 18,
                        ),
                        hintText: 'e.g. PC Gamer & Deal Hunter 🎮',
                        hintStyle: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppTheme.surfaceBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppTheme.neonGreen,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Section 4: Favorite Store
                    const Text(
                      'FAVORITE STORE',
                      style: TextStyle(
                        color: Color(0xFFFFD600),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableStores.map((store) {
                        final isSelected = selectedStore == store;
                        return ChoiceChip(
                          label: Text(store),
                          selected: isSelected,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.normal,
                          ),
                          selectedColor: AppTheme.neonGreen,
                          backgroundColor: AppTheme.surface,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.neonGreen
                                : AppTheme.surfaceBorder,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                selectedStore = store;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Save Changes Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSaving
                            ? null
                            : () async {
                                setModalState(() {
                                  isSaving = true;
                                });

                                // 1. Upload custom avatar if newly picked
                                if (pickedImageFile != null) {
                                  final uploadResult = await authProvider.uploadAvatar(pickedImageFile!);
                                  if (!uploadResult['success']) {
                                    setModalState(() {
                                      isSaving = false;
                                    });
                                    if (sheetContext.mounted) {
                                      _showFeedback(
                                        uploadResult['message'] ?? 'อัปโหลดรูปภาพล้มเหลว',
                                        isError: true,
                                      );
                                    }
                                    return;
                                  }
                                }

                                // 2. Update profile data
                                final newTag = tagController.text.trim();
                                final newBio = bioController.text.trim();
                                await authProvider.updateProfile(
                                  gamerTag: newTag.isNotEmpty ? newTag : user.gamerTag,
                                  avatarIndex: selectedAvatarIndex,
                                  clearAvatarUrl: removeCustomImage,
                                  bio: newBio.isNotEmpty ? newBio : user.bio,
                                  favoriteStore: selectedStore,
                                );

                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                                if (context.mounted) {
                                  _showFeedback(
                                    'บันทึกข้อมูลโปรไฟล์เรียบร้อย!',
                                    isError: false,
                                  );
                                }
                              },
                        icon: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(
                                Icons.check_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                        label: Text(
                          isSaving ? 'SAVING...' : 'SAVE CHANGES',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          shadowColor: AppTheme.neonGreen.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Danger Zone (Delete Account)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'DANGER ZONE',
                                style: TextStyle(
                                  color: Colors.redAccent.shade100,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'การลบบัญชีจะทำให้เกมใน Wishlist และการตั้งค่าโปรไฟล์ทั้งหมดถูกลบถาวร',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showDeleteAccountConfirmation(sheetContext, authProvider),
                              icon: const Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                              label: const Text(
                                'DELETE ACCOUNT',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  fontSize: 12,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.redAccent.withValues(alpha: 0.6),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Confirmation Dialog before deleting account
  void _showDeleteAccountConfirmation(
    BuildContext sheetContext,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: sheetContext,
      builder: (dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.redAccent.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ยืนยันการลบบัญชี?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'การลบบัญชีนี้เป็นการกระทำที่ไม่สามารถย้อนกลับได้:',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• บัญชีและรหัสผ่านจะถูกลบออกจากฐานข้อมูลถาวร\n'
                    '• รายการเกมใน Wishlist ทั้งหมดจะถูกลบ\n'
                    '• หากต้องการใช้งานอีกครั้ง จะต้องสมัครสมาชิกใหม่',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() {
                            isDeleting = true;
                          });
                          final result = await authProvider.deleteAccount();
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                          if (this.context.mounted) {
                            _showFeedback(
                              result['message'] ?? 'ลบบัญชีผู้ใช้เรียบร้อยแล้ว',
                              isError: !result['success'],
                            );
                          }
                        },
                  icon: isDeleting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.delete_forever_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                  label: Text(
                    isDeleting ? 'กำลังลบ...' : 'ลบบัญชีถาวร',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  // Auth Form (Sci-fi Terminal Theme - Login & Register separated)
  Widget _buildAuthForm(AuthProvider authProvider) {
    final isLoading = authProvider.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cyber System Header Tag
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'GDT_SYSTEM_v1.0',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Screen Title
          Text(
            _isRegister ? 'New Registration' : 'Authentication Required',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // 3. Subtitle
          Text(
            _isRegister
                ? 'Create your credentials to track deals and sync wishlists.'
                : 'Access your personalized gaming deal tracker and wishlist.',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Error Message Banner (if any)
          if (_errorMessage != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Main Bordered Terminal Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10141D).withValues(alpha: 0.7),
              //border: Border.all(color: const Color(0xFFE76F51), width: 0),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Terminal Sequence Heading
                Text(
                  _isRegister ? '> REGISTER' : '> LOGIN',
                  style: TextStyle(
                    color: _isRegister
                        ? const Color(0xFF00E5FF)
                        : const Color(0xFF00FF87),
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  color: Colors.white.withValues(alpha: 0.12),
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: 20),

                // Identifier (Email)
                TerminalInputField(
                  controller: _emailController,
                  label: 'EMAIL',
                  hint: 'user@matrix.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'กรุณากรอกรูปแบบอีเมลให้ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Access Key (Password)
                TerminalInputField(
                  controller: _passwordController,
                  label: 'PASSWORD',
                  hint: '••••••••••••',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    if (value.length < 6) {
                      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                    }
                    return null;
                  },
                ),

                // Confirm Access Key (Register Mode Only)
                if (_isRegister) ...[
                  const SizedBox(height: 18),
                  TerminalInputField(
                    controller: _confirmPasswordController,
                    label: 'CONFIRM PASSWORD',
                    hint: '••••••••••••',
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกยืนยันรหัสผ่าน';
                      }
                      if (value != _passwordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _submit(authProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.black,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '→] ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                _isRegister ? 'REGISTER' : 'LOGIN',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Mode Switch Link
                Center(
                  child: InkWell(
                    onTap: () => _toggleAuthMode(!_isRegister),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        _isRegister
                            ? 'Already registered? Sign In'
                            : 'Register here',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Cyber Horizontal Accent Dividers
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.15),
                  thickness: 1,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.15),
                  thickness: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
