import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wishlist_item_model.dart';
import '../../providers/currency_provider.dart';
import '../../theme/app_theme.dart';

/// แถวแสดงผลเกมใน Wishlist พร้อมราคาและปุ่มลบ
class WishlistItemTile extends StatelessWidget {
  final WishlistItemModel item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const WishlistItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 90,
                  height: 56,
                  child: item.thumb.isNotEmpty
                      ? Image.network(
                          item.thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.surfaceElevated,
                            child: const Icon(
                              Icons.sports_esports_rounded,
                              color: AppTheme.textMuted,
                              size: 24,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.surfaceElevated,
                          child: const Icon(
                            Icons.sports_esports_rounded,
                            color: AppTheme.textMuted,
                            size: 24,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Price info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(
                          currencyProvider
                              .formatPrice(item.salePrice.toString()),
                          style: const TextStyle(
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        if (item.savingsPercentage > 0) ...[
                          Text(
                            currencyProvider
                                .formatPrice(item.normalPrice.toString()),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: AppTheme.priceCrossed,
                              fontSize: 11,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.neonGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${item.savingsPercentage}%',
                              style: const TextStyle(
                                color: AppTheme.neonGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Remove from Wishlist button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
                tooltip: 'ลบออกจาก Wishlist',
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
