import 'package:flutter_test/flutter_test.dart';
import 'package:game/config/api_config.dart';

void main() {
  group('ApiConfig Tests', () {
    test('Default base URLs and endpoints are properly formatted', () {
      expect(ApiConfig.cheapSharkBaseUrl, 'https://www.cheapshark.com/api/1.0');
      expect(ApiConfig.dealsEndpoint, 'https://www.cheapshark.com/api/1.0/deals');
      expect(ApiConfig.gamesEndpoint, 'https://www.cheapshark.com/api/1.0/games');
      expect(ApiConfig.storesEndpoint, 'https://www.cheapshark.com/api/1.0/stores');
      expect(ApiConfig.currencyExchangeEndpoint, 'https://open.er-api.com/v6/latest/USD');
    });

    test('URL builders create correct URLs', () {
      expect(
        ApiConfig.getDealRedirectUrl('deal_12345'),
        'https://www.cheapshark.com/redirect?dealID=deal_12345',
      );

      expect(
        ApiConfig.getStoreIconUrl(0),
        'https://www.cheapshark.com/img/stores/icons/0.png',
      );

      expect(
        ApiConfig.getStoreAssetUrl('/img/logo.png'),
        'https://www.cheapshark.com/img/logo.png',
      );

      expect(
        ApiConfig.getStoreAssetUrl('https://custom.com/image.png'),
        'https://custom.com/image.png',
      );

      expect(
        ApiConfig.getSteamHeaderBannerUrl('1091500'),
        'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg',
      );
    });

    test('Default headers contain required User-Agent', () {
      expect(ApiConfig.defaultHeaders['User-Agent'], isNotNull);
      expect(ApiConfig.defaultHeaders['Accept'], 'application/json');
    });

    test('Backend endpoints are non-empty and well-formed', () {
      expect(ApiConfig.backendBaseUrl, isNotEmpty);
      expect(ApiConfig.authEndpoint, endsWith('/auth'));
      expect(ApiConfig.wishlistEndpoint, endsWith('/wishlist'));
    });
  });
}
