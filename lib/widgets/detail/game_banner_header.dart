import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// แบนเนอร์ด้านบนของหน้า Game Detail (รูปภาพแบนเนอร์, เกรเดียนต์เฟดสีดำ, ปุ่ม Back, ปุ่ม Wishlist)
class GameBannerHeader extends StatelessWidget {
  final String bannerUrl;
  final bool isWishlisted;
  final bool isWishlistLoading;
  final VoidCallback onToggleWishlist;
  final VoidCallback onBack;

  const GameBannerHeader({
    super.key,
    required this.bannerUrl,
    required this.isWishlisted,
    required this.isWishlistLoading,
    required this.onToggleWishlist,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Banner Image
        SizedBox(
          height: 270,
          width: double.infinity,
          child: bannerUrl.isNotEmpty
              ? Image.network(
                  bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.surfaceElevated,
                    child: const Center(
                      child: Icon(
                        Icons.sports_esports_rounded,
                        size: 64,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppTheme.surfaceElevated,
                  child: const Center(
                    child: Icon(
                      Icons.sports_esports_rounded,
                      size: 64,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
        ),

        // 2. Gradient Overlay (fades into dark background)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.background.withValues(alpha: 0.1),
                  AppTheme.background.withValues(alpha: 0.7),
                  AppTheme.background,
                ],
                stops: const [0.0, 0.45, 0.8, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // 3. Top Navigation Buttons (Back & Actions)
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surfaceBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                // Wishlist Button
                GestureDetector(
                  onTap: isWishlistLoading ? null : onToggleWishlist,
                  child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isWishlisted
                                ? AppTheme.neonGreen
                                : AppTheme.surfaceBorder,
                          ),
                          boxShadow: isWishlisted
                              ? [
                                  BoxShadow(
                                    color: AppTheme.neonGreen
                                        .withValues(alpha: 0.35),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: isWishlistLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.neonGreen,
                                ),
                              )
                            : Icon(
                                isWishlisted
                                    ? Icons.bookmark_added_rounded
                                    : Icons.bookmark_border_rounded,
                                color: isWishlisted
                                    ? AppTheme.neonGreen
                                    : Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
