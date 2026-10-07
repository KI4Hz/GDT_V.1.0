import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deals_provider.dart';
import '../../theme/app_theme.dart';

/// เมนูดรอปดาวน์สำหรับเรียงลำดับราคาและคะแนนของดีลเกม
class SortDropdown extends StatelessWidget {
  const SortDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final dealsProvider = context.watch<DealsProvider>();
    const sortOptions = DealsProvider.sortOptions;
    final currentIndex = dealsProvider.selectedSortIndex;
    final currentSort = dealsProvider.currentSort;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: currentSort.sortBy == 'Price'
              ? AppTheme.neonGreen.withValues(alpha: 0.6)
              : AppTheme.surfaceBorder,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: currentIndex,
          dropdownColor: AppTheme.surfaceElevated,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.neonGreen,
            size: 18,
          ),
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          onChanged: (int? newIndex) {
            if (newIndex != null) {
              dealsProvider.setSortIndex(newIndex);
            }
          },
          items: List.generate(sortOptions.length, (index) {
            final opt = sortOptions[index];
            final isSelected = index == currentIndex;

            return DropdownMenuItem<int>(
              value: index,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    opt.icon,
                    size: 15,
                    color: isSelected
                        ? AppTheme.neonGreen
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    opt.label,
                    style: TextStyle(
                      color: isSelected ? AppTheme.neonGreen : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
