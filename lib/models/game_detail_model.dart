import '../config/api_config.dart';
import 'store_model.dart';

class StorePriceComparison {
  final String storeID;
  final String dealID;
  final String price;
  final String retailPrice;
  final String savings;

  StorePriceComparison({
    required this.storeID,
    required this.dealID,
    required this.price,
    required this.retailPrice,
    required this.savings,
  });

  factory StorePriceComparison.fromJson(Map<String, dynamic> json) {
    return StorePriceComparison(
      storeID: json['storeID']?.toString() ?? '1',
      dealID: json['dealID']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      retailPrice: json['retailPrice']?.toString() ??
          json['normalPrice']?.toString() ??
          '0.00',
      savings: json['savings']?.toString() ?? '0.00',
    );
  }

  String get storeName => StoreModel.getStoreName(storeID);
  String get storeIconUrl => StoreModel.getStoreIcon(storeID);

  int get savingsPercentage {
    final double? val = double.tryParse(savings);
    return val != null ? val.round() : 0;
  }


  String get dealRedirectUrl => ApiConfig.getDealRedirectUrl(dealID);
}

class GameDetailModel {
  final String gameID;
  final String title;
  final String thumb;
  final String? steamAppID;
  final String? publisher;
  final String? metacriticScore;
  final String? metacriticLink;
  final String? steamRatingText;
  final String? steamRatingPercent;
  final String? steamRatingCount;
  final String? releaseDate;
  final String? cheapestPriceEver;
  final int? cheapestPriceEverDate;
  final List<StorePriceComparison> storeComparisons;

  GameDetailModel({
    required this.gameID,
    required this.title,
    required this.thumb,
    this.steamAppID,
    this.publisher,
    this.metacriticScore,
    this.metacriticLink,
    this.steamRatingText,
    this.steamRatingPercent,
    this.steamRatingCount,
    this.releaseDate,
    this.cheapestPriceEver,
    this.cheapestPriceEverDate,
    required this.storeComparisons,
  });

  String get bannerUrl {
    if (steamAppID != null && steamAppID!.isNotEmpty && steamAppID != '0') {
      return ApiConfig.getSteamHeaderBannerUrl(steamAppID!);
    }
    return thumb;
  }

  List<String> get genreTags {
    final lower = title.toLowerCase();
    final List<String> tags = [];

    if (lower.contains('rpg') || lower.contains('witcher') || lower.contains('fantasy') || lower.contains('souls')) {
      tags.add('RPG');
    }
    if (lower.contains('action') || lower.contains('combat') || lower.contains('war') || lower.contains('legend')) {
      tags.add('Action');
    }
    if (lower.contains('strategy') || lower.contains('tactics') || lower.contains('civilization')) {
      tags.add('Strategy');
    }
    if (lower.contains('adventure') || lower.contains('story') || lower.contains('quest')) {
      tags.add('Adventure');
    }
    if (lower.contains('shooter') || lower.contains('fps') || lower.contains('strike') || lower.contains('sniper')) {
      tags.add('Shooter');
    }
    if (lower.contains('open world') || lower.contains('cyberpunk') || lower.contains('horizon')) {
      tags.add('Open World');
    }
    if (lower.contains('survival') || lower.contains('craft') || lower.contains('dead')) {
      tags.add('Survival');
    }

    if (tags.isEmpty) {
      tags.addAll(['Action', 'Adventure', 'PC Game']);
    } else if (tags.length < 2) {
      tags.add('Single-player');
    }
    return tags;
  }
}
