import '../config/api_config.dart';
import 'store_model.dart';

class DealModel {
  final String dealID;
  final String title;
  final String storeID;
  final String gameID;
  final String salePrice;
  final String normalPrice;
  final String savings;
  final String thumb;
  final String? steamAppID;
  final String? metacriticScore;
  final String? steamRatingText;
  final String? steamRatingPercent;
  final String? steamRatingCount;
  final String? dealRating;
  final int? releaseDate;
  final bool isOnSale;

  DealModel({
    required this.dealID,
    required this.title,
    required this.storeID,
    required this.gameID,
    required this.salePrice,
    required this.normalPrice,
    required this.savings,
    required this.thumb,
    this.steamAppID,
    this.metacriticScore,
    this.steamRatingText,
    this.steamRatingPercent,
    this.steamRatingCount,
    this.dealRating,
    this.releaseDate,
    this.isOnSale = true,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      dealID: json['dealID']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Unknown Game',
      storeID: json['storeID']?.toString() ?? '1',
      gameID: json['gameID']?.toString() ?? '',
      salePrice: json['salePrice']?.toString() ?? '0.00',
      normalPrice: json['normalPrice']?.toString() ??
          json['retailPrice']?.toString() ??
          '0.00',
      savings: json['savings']?.toString() ?? '0.00',
      thumb: json['thumb'] ?? '',
      steamAppID: json['steamAppID']?.toString(),
      metacriticScore: json['metacriticScore']?.toString(),
      steamRatingText: json['steamRatingText']?.toString(),
      steamRatingPercent: json['steamRatingPercent']?.toString(),
      steamRatingCount: json['steamRatingCount']?.toString(),
      dealRating: json['dealRating']?.toString(),
      releaseDate: json['releaseDate'] is int
          ? json['releaseDate']
          : int.tryParse(json['releaseDate']?.toString() ?? ''),
      isOnSale: json['isOnSale'] == '1' || json['isOnSale'] == 1,
    );
  }

  // Rounded percentage, e.g. 75
  int get savingsPercentage {
    final double? val = double.tryParse(savings);
    return val != null ? val.round() : 0;
  }


  // Store name
  String get storeName => StoreModel.getStoreName(storeID);

  // Store logo / icon URL
  String get storeIconUrl => StoreModel.getStoreIcon(storeID);

  // High-res Steam banner if steamAppID exists, otherwise thumbnail
  String get bannerUrl {
    if (steamAppID != null && steamAppID!.isNotEmpty && steamAppID != '0') {
      return ApiConfig.getSteamHeaderBannerUrl(steamAppID!);
    }
    return thumb;
  }

  // Inferred genre tags
  List<String> get genreTags {
    final lower = title.toLowerCase();
    final List<String> tags = [];

    if (lower.contains('rpg') || lower.contains('fantasy') || lower.contains('witcher') || lower.contains('elder')) {
      tags.add('RPG');
    }
    if (lower.contains('action') || lower.contains('combat') || lower.contains('strike') || lower.contains('call')) {
      tags.add('Action');
    }
    if (lower.contains('strategy') || lower.contains('tactics') || lower.contains('civilization') || lower.contains('legend')) {
      tags.add('Strategy');
    }
    if (lower.contains('adventure') || lower.contains('quest') || lower.contains('tomb')) {
      tags.add('Adventure');
    }
    if (lower.contains('shooter') || lower.contains('fps') || lower.contains('war') || lower.contains('doom')) {
      tags.add('Shooter');
    }
    if (lower.contains('survival') || lower.contains('craft') || lower.contains('dead')) {
      tags.add('Survival');
    }
    if (lower.contains('racing') || lower.contains('forza') || lower.contains('speed')) {
      tags.add('Racing');
    }
    if (lower.contains('open world') || lower.contains('grand')) {
      tags.add('Open World');
    }

    // Defaults if none matched
    if (tags.isEmpty) {
      tags.addAll(['Action', 'Adventure', 'PC Game']);
    } else if (tags.length == 1) {
      tags.add('Single-player');
    }
    return tags;
  }
}
