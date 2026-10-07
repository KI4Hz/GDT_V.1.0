import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/deal_model.dart';
import '../../providers/currency_provider.dart';
import '../../theme/app_theme.dart';

/// การ์ดดีลเกม 2 คอลัมน์ (รูปภาพ, ป้ายส่วนลดนีออน, ราคาคู่ขนาน, โลโก้ร้านค้า)
class GameCard extends StatelessWidget {
  final DealModel deal;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.deal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.surfaceBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image + Discount Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: deal.bannerUrl.isNotEmpty
                        ? Image.network(
                            deal.bannerUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.surfaceElevated,
                              child: const Center(
                                child: Icon(
                                  Icons.sports_esports_rounded,
                                  color: AppTheme.textMuted,
                                  size: 32,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: AppTheme.surfaceElevated,
                            child: const Center(
                              child: Icon(
                                Icons.sports_esports_rounded,
                                color: AppTheme.textMuted,
                                size: 32,
                              ),
                            ),
                          ),
                  ),
                ),

                // Neon Green Discount Badge
                if (deal.savingsPercentage > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonGreen.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '-${deal.savingsPercentage}%',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                // Metacritic Score Badge (Top Right)
                if (deal.metacriticScore != null &&
                    deal.metacriticScore != '0' &&
                    deal.metacriticScore!.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A22).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (int.tryParse(deal.metacriticScore!) ?? 0) >= 75
                              ? const Color(0xFF66CC33)
                              : ((int.tryParse(deal.metacriticScore!) ?? 0) >= 50
                                  ? const Color(0xFFFFCC33)
                                  : Colors.redAccent),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'META',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deal.metacriticScore!,
                            style: TextStyle(
                              color: (int.tryParse(deal.metacriticScore!) ?? 0) >= 75
                                  ? const Color(0xFF66CC33)
                                  : ((int.tryParse(deal.metacriticScore!) ?? 0) >= 50
                                      ? const Color(0xFFFFCC33)
                                      : Colors.redAccent),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (Fixed height for uniform grid alignment)
                    SizedBox(
                      height: 32,
                      child: Text(
                        deal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          height: 1.25,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Store Icon & Name + Steam Rating Tag
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            width: 14,
                            height: 14,
                            color: AppTheme.surfaceElevated,
                            child: deal.storeIconUrl.isNotEmpty
                                ? Image.network(
                                    deal.storeIconUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.storefront_rounded,
                                      size: 10,
                                      color: AppTheme.textSecondary,
                                    ),
                                  )
                                : const Icon(
                                    Icons.storefront_rounded,
                                    size: 10,
                                    color: AppTheme.textSecondary,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            deal.storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (deal.steamRatingPercent != null &&
                            deal.steamRatingPercent != '0') ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.thumb_up_alt_rounded,
                            size: 10,
                            color: AppTheme.neonCyan.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${deal.steamRatingPercent}%',
                            style: TextStyle(
                              color: AppTheme.neonCyan.withValues(alpha: 0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const Spacer(),

                    // Prices (Neon Green Sale Price & Strikethrough Normal Price)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(
                          currencyProvider.formatPrice(deal.salePrice),
                          style: const TextStyle(
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (deal.savingsPercentage > 0)
                          Text(
                            currencyProvider.formatPrice(deal.normalPrice),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: AppTheme.priceCrossed,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
