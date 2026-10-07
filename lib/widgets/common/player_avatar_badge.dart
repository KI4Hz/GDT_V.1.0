import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// ไอคอนโปรไฟล์ผู้เล่นบน AppBar แสดงสถานะการเชื่อมต่อ และอวตาร/รูปภาพที่ผู้เล่นปรับแต่งไว้
class PlayerAvatarBadge extends StatelessWidget {
  final bool isAuthenticated;
  final VoidCallback onTap;

  const PlayerAvatarBadge({
    super.key,
    required this.isAuthenticated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final avatar = user?.avatar ?? GamerAvatar.list[0];

    final primaryColor = isAuthenticated ? avatar.primaryColor : AppTheme.surfaceBorder;
    final iconColor = isAuthenticated ? avatar.primaryColor : AppTheme.textSecondary;
    final iconData = isAuthenticated ? avatar.icon : Icons.person_outline_rounded;
    final hasCustomAvatar = isAuthenticated && (user?.hasCustomAvatar ?? false);
    final customUrl = user?.fullAvatarUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(right: 10, left: 2),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryColor,
            width: 1.5,
          ),
          boxShadow: isAuthenticated
              ? [
                  BoxShadow(
                    color: avatar.glowColor,
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: hasCustomAvatar && customUrl != null
              ? Image.network(
                  customUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      avatar.icon,
                      color: iconColor,
                      size: 18,
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 18,
                  ),
                ),
        ),
      ),
    );
  }
}
