import 'package:flutter_test/flutter_test.dart';
import 'package:game/providers/currency_provider.dart';
import 'package:game/providers/deals_provider.dart';
import 'package:game/providers/wishlist_provider.dart';

void main() {
  group('CurrencyProvider Tests', () {
    test('Currency toggling updates currencySymbol and currencyCode', () {
      final provider = CurrencyProvider();
      final initialUseThb = provider.useThb;

      provider.toggleCurrency();
      expect(provider.useThb, !initialUseThb);

      provider.toggleCurrency();
      expect(provider.useThb, initialUseThb);
    });

    test('formatPrice formats correctly', () {
      final provider = CurrencyProvider();
      provider.setUseThb(false); // USD mode

      expect(provider.formatPrice(0), 'FREE');
      expect(provider.formatPrice(19.99), '\$19.99');
      expect(provider.formatPrice(null), '\$0.00');
    });
  });

  group('DealsProvider Tests', () {
    test('Initial sort and filter defaults', () {
      final provider = DealsProvider();
      expect(provider.selectedStoreFilterIndex, 0);
      expect(provider.selectedSortIndex, 0);
      expect(provider.currentSort.label, 'Featured Deals');
      expect(provider.selectedStoreId, isNull);
    });

    test('Store filter and sort update correctly', () {
      final provider = DealsProvider();
      provider.setStoreFilter(1); // Steam
      expect(provider.selectedStoreFilterIndex, 1);
      expect(provider.selectedStoreId, '1');

      provider.setSortIndex(1); // Price: High to Low
      expect(provider.selectedSortIndex, 1);
      expect(provider.currentSort.sortBy, 'Price');
    });
  });

  group('WishlistProvider Tests', () {
    test('Wishlist isWishlisted checks correctly', () {
      final provider = WishlistProvider();
      expect(provider.isWishlisted('12345'), isFalse);
      expect(provider.items, isEmpty);

      // Clearing on null auth
      provider.updateAuth(null);
      expect(provider.items, isEmpty);
      expect(provider.isWishlisted('12345'), isFalse);
    });
  });
}
