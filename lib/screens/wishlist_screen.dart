import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deal_model.dart';
import '../models/wishlist_item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/wishlist/wishlist_item_tile.dart';
import 'auth_screen.dart';
import 'game_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  final AuthService? authService;

  const WishlistScreen({
    super.key,
    this.authService,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Future<void> _removeItem(
    WishlistItemModel item,
    WishlistProvider wishlistProvider,
  ) async {
    final success = await wishlistProvider.removeFromWishlist(item.gameId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceElevated,
          content: Text(
            'นำ "${item.title}" ออกจาก Wishlist แล้ว',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bookmark_rounded, color: AppTheme.neonCyan, size: 22),
            SizedBox(width: 8),
            Text(
              'MY WISHLIST',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        actions: [
          if (isAuthenticated)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => wishlistProvider.fetchWishlist(),
              tooltip: 'รีเฟรช',
            ),
        ],
      ),
      body: !isAuthenticated
          ? _buildNotLoggedInView()
          : _buildWishlistContent(wishlistProvider),
    );
  }

  // View when user is not logged in
  Widget _buildNotLoggedInView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.neonCyan.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonCyan.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                color: AppTheme.neonCyan,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'PLAYER SIGN IN REQUIRED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'เข้าสู่ระบบเพื่อบันทึกและจัดการ Personal Wishlist บน Cloud เชื่อมต่อกับระบบเกมเมอร์ของคุณ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text(
                'SIGN IN TO ACCESS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wishlist list view using WishlistProvider
  Widget _buildWishlistContent(WishlistProvider wishlistProvider) {
    if (wishlistProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.neonGreen),
      );
    }

    final items = wishlistProvider.items;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: const Icon(
                  Icons.bookmark_border_rounded,
                  color: AppTheme.textMuted,
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'WISHLIST IS EMPTY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'คุณยังไม่มีเกมในรายการโปรด แตะไอคอน Bookmark ในหน้ารายละเอียดเกมเพื่อบันทึก',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.neonGreen),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'BROWSE DEALS',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.neonGreen,
      backgroundColor: AppTheme.surfaceElevated,
      onRefresh: () => wishlistProvider.fetchWishlist(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return WishlistItemTile(
            item: item,
            onTap: () {
              final deal = DealModel(
                dealID: '',
                gameID: item.gameId,
                title: item.title,
                storeID: '1',
                salePrice: item.salePrice.toStringAsFixed(2),
                normalPrice: item.normalPrice.toStringAsFixed(2),
                savings: item.savingsPercentage.toString(),
                thumb: item.thumb,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GameDetailScreen(deal: deal),
                ),
              );
            },
            onRemove: () => _removeItem(item, wishlistProvider),
          );
        },
      ),
    );
  }
}
