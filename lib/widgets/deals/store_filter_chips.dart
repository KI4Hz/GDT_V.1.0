import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deals_provider.dart';
import '../../theme/app_theme.dart';

/// แถบชิปกรองร้านค้าแนวนอน (All Stores, Steam, Epic Games, GOG ฯลฯ)
class StoreFilterChips extends StatelessWidget {
  const StoreFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final dealsProvider = context.watch<DealsProvider>();
    final options = DealsProvider.storeFilterOptions;
    final selectedIndex = dealsProvider.selectedStoreFilterIndex;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final option = options[index];

          return GestureDetector(
            onTap: () => dealsProvider.setStoreFilter(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.neonGreen.withValues(alpha: 0.18)
                    : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.neonGreen
                      : AppTheme.surfaceBorder,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.neonGreen.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  option['label'],
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.neonGreen
                        : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
