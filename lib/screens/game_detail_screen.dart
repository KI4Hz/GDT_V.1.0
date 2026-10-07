import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/deal_model.dart';
import '../models/game_detail_model.dart';
import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/auth_service.dart';
import '../services/cheapshark_service.dart';
import '../theme/app_theme.dart';
import '../widgets/detail/game_banner_header.dart';
import '../widgets/detail/meta_stats_card.dart';
import '../widgets/detail/store_comparison_tile.dart';
import 'auth_screen.dart';

class GameDetailScreen extends StatefulWidget {
  final DealModel deal;
  final AuthService? authService;

  const GameDetailScreen({
    super.key,
    required this.deal,
    this.authService,
  });

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final CheapSharkService _apiService = CheapSharkService();
  late Future<GameDetailModel> _detailFuture;
  bool _isWishlistLoading = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _apiService.getGameDetail(
      gameID: widget.deal.gameID,
      dealID: widget.deal.dealID,
      initialDeal: widget.deal,
    );
  }

  Future<void> _toggleWishlist(
    AuthProvider authProvider,
    WishlistProvider wishlistProvider,
  ) async {
    if (!authProvider.isAuthenticated) {
      // Prompt user to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceElevated,
          content: const Text(
            'กรุณาเข้าสู่ระบบเพื่อบันทึก Wishlist',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'เข้าสู่ระบบ',
            textColor: AppTheme.neonGreen,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              );
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isWishlistLoading = true);
    final inWishlist = wishlistProvider.isWishlisted(widget.deal.gameID);

    if (inWishlist) {
      final success =
          await wishlistProvider.removeFromWishlist(widget.deal.gameID);
      if (mounted) {
        setState(() => _isWishlistLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppTheme.surfaceElevated,
              content: Text(
                'นำออกจาก Wishlist แล้ว',
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } else {
      final success = await wishlistProvider.addToWishlist(
        gameId: widget.deal.gameID,
        title: widget.deal.title,
        salePrice: widget.deal.salePrice,
        normalPrice: widget.deal.normalPrice,
        thumb: widget.deal.thumb,
      );
      if (mounted) {
        setState(() => _isWishlistLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppTheme.surfaceElevated,
              content: Text(
                'บันทึกลง Wishlist บน Cloud สำเร็จ!',
                style: TextStyle(color: AppTheme.neonGreen),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _launchDeal(String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _copyAndNotify(url);
      }
    } catch (_) {
      if (mounted) _copyAndNotify(url);
    }
  }

  void _copyAndNotify(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.surfaceElevated,
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'คัดลอกลิงก์ดีลไปยังคลิปบอร์ดแล้ว',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isWishlisted = wishlistProvider.isWishlisted(widget.deal.gameID);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FutureBuilder<GameDetailModel>(
        future: _detailFuture,
        builder: (context, snapshot) {
          final detail = snapshot.data;
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting && detail == null;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header Banner Image with Fade-to-Dark Gradient
              SliverToBoxAdapter(
                child: GameBannerHeader(
                  bannerUrl: detail?.bannerUrl ?? widget.deal.bannerUrl,
                  isWishlisted: isWishlisted,
                  isWishlistLoading: _isWishlistLoading,
                  onToggleWishlist: () =>
                      _toggleWishlist(authProvider, wishlistProvider),
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),

              // 2. Title, Genre Tags, & Ratings
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildTitleSection(detail),
                      const SizedBox(height: 14),
                      _buildGenreTags(detail),
                      const SizedBox(height: 18),
                      MetaStatsCard(
                        detail: detail,
                        fallbackSalePrice: widget.deal.salePrice,
                        fallbackMetacritic: widget.deal.metacriticScore,
                        fallbackSteamRating: widget.deal.steamRatingText,
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppTheme.surfaceBorder, thickness: 1),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 3. Price Comparison Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.compare_arrows_rounded,
                          color: AppTheme.neonGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Price Comparison',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      if (detail != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Text(
                            '${detail.storeComparisons.length} stores',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 4. Price Comparison List
              if (isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.neonGreen),
                    ),
                  ),
                )
              else if (detail != null && detail.storeComparisons.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final storeDeal = detail.storeComparisons[index];
                        final isBestPrice = index == 0;
                        return StoreComparisonTile(
                          storeDeal: storeDeal,
                          isBestPrice: isBestPrice,
                          onGetDeal: _launchDeal,
                        );
                      },
                      childCount: detail.storeComparisons.length,
                    ),
                  ),
                )
              else
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'ไม่พบข้อมูลเปรียบเทียบราคาเพิ่มเติม',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ),

              // 5. Brief Text Description Section Below Prices
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildDescriptionSection(detail),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        },
      ),
    );
  }

  // Game Title
  Widget _buildTitleSection(GameDetailModel? detail) {
    final title = detail?.title ?? widget.deal.title;
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -0.3,
        height: 1.2,
      ),
    );
  }

  // Genre Tags
  Widget _buildGenreTags(GameDetailModel? detail) {
    final tags = detail?.genreTags ?? widget.deal.genreTags;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppTheme.neonCyan.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.neonCyan,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Description Section Below Prices
  Widget _buildDescriptionSection(GameDetailModel? detail) {
    final publisher = detail?.publisher ?? 'Official Publisher';
    final releaseDate = detail?.releaseDate ?? 'Recent Release';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the Game',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Track and compare the lowest digital PC game key prices across verified digital storefronts. This deal is updated automatically from Steam, Epic Games, GOG, Fanatical, and more.',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.surfaceBorder, height: 1),
          const SizedBox(height: 14),

          // Publisher & Release Date Specs
          Row(
            children: [
              Expanded(child: _buildSpecItem('Publisher', publisher)),
              const SizedBox(width: 8),
              Expanded(child: _buildSpecItem('Release Date', releaseDate)),
              const SizedBox(width: 8),
              Expanded(child: _buildSpecItem('Platform', 'Windows PC')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
