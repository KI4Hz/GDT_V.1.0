import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_detail_model.dart';
import '../../providers/currency_provider.dart';
import '../../theme/app_theme.dart';

/// การ์ดสถิติของเกม (Metacritic, Steam Rating, Historical Lowest Price)
class MetaStatsCard extends StatelessWidget {
  final GameDetailModel? detail;
  final String fallbackSalePrice;
  final String? fallbackMetacritic;
  final String? fallbackSteamRating;

  const MetaStatsCard({
    super.key,
    required this.detail,
    required this.fallbackSalePrice,
    this.fallbackMetacritic,
    this.fallbackSteamRating,
  });

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    final metacritic = detail?.metacriticScore ?? fallbackMetacritic;
    final steamRating = detail?.steamRatingText ?? fallbackSteamRating;
    final lowestEver = detail?.cheapestPriceEver;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          // Metacritic
          Expanded(
            child: _buildStatItem(
              icon: Icons.speed_rounded,
              iconColor: Colors.amber,
              label: 'Metacritic',
              value:
                  (metacritic != null && metacritic != '0') ? metacritic : 'N/A',
            ),
          ),
          Container(width: 1, height: 32, color: AppTheme.surfaceBorder),

          // Steam Review
          Expanded(
            child: _buildStatItem(
              icon: Icons.thumb_up_alt_rounded,
              iconColor: AppTheme.neonCyan,
              label: 'Steam Rating',
              value: (steamRating != null && steamRating.isNotEmpty)
                  ? steamRating
                  : 'Positive',
            ),
          ),
          Container(width: 1, height: 32, color: AppTheme.surfaceBorder),

          // Historical Low
          Expanded(
            child: _buildStatItem(
              icon: Icons.trending_down_rounded,
              iconColor: AppTheme.neonGreen,
              label: 'Historical Low',
              value: currencyProvider.formatPrice(
                (lowestEver != null && lowestEver.isNotEmpty)
                    ? lowestEver
                    : fallbackSalePrice,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
