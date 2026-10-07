import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_detail_model.dart';
import '../../providers/currency_provider.dart';
import '../../theme/app_theme.dart';

/// แถวเปรียบเทียบราคาของแต่ละร้านค้า (Store Logo, Store Name, Best Price Badge, Prices, Get Deal Button)
class StoreComparisonTile extends StatelessWidget {
  final StorePriceComparison storeDeal;
  final bool isBestPrice;
  final ValueChanged<String> onGetDeal;

  const StoreComparisonTile({
    super.key,
    required this.storeDeal,
    required this.isBestPrice,
    required this.onGetDeal,
  });

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isBestPrice ? AppTheme.surfaceElevated : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBestPrice
              ? AppTheme.neonGreen.withValues(alpha: 0.5)
              : AppTheme.surfaceBorder,
          width: isBestPrice ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Store Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 34,
              height: 34,
              color: AppTheme.surfaceElevated,
              padding: const EdgeInsets.all(4),
              child: storeDeal.storeIconUrl.isNotEmpty
                  ? Image.network(
                      storeDeal.storeIconUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.store_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    )
                  : const Icon(
                      Icons.store_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Store Name and Prices
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        storeDeal.storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isBestPrice) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BEST',
                          style: TextStyle(
                            color: AppTheme.neonGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    if (storeDeal.savingsPercentage > 0)
                      Text(
                        currencyProvider.formatPrice(storeDeal.retailPrice),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppTheme.priceCrossed,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      currencyProvider.formatPrice(storeDeal.price),
                      style: TextStyle(
                        color: isBestPrice ? AppTheme.neonGreen : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    if (storeDeal.savingsPercentage > 0)
                      Text(
                        '-${storeDeal.savingsPercentage}%',
                        style: const TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Prominent 'Get Deal' Button
          ElevatedButton(
            onPressed: () => onGetDeal(storeDeal.dealRedirectUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isBestPrice ? AppTheme.neonGreen : AppTheme.surfaceElevated,
              foregroundColor: isBestPrice ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              elevation: isBestPrice ? 2 : 0,
              side: isBestPrice
                  ? null
                  : const BorderSide(color: AppTheme.surfaceBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get Deal',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
