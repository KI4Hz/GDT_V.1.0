import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/deal_model.dart';
import '../models/game_detail_model.dart';
import '../models/store_model.dart';

class CheapSharkService {
  List<StoreModel>? _cachedStores;

  // Fetch deals with optional search, store filter, and sorting
  Future<List<DealModel>> getDeals({
    String? title,
    String? storeID,
    String? sortBy,
    int? desc,
    int pageNumber = 0,
    int pageSize = 40,
  }) async {
    final queryParams = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };

    if (storeID != null && storeID.isNotEmpty && storeID != 'all') {
      queryParams['storeID'] = storeID;
    }

    if (title != null && title.trim().isNotEmpty) {
      queryParams['title'] = title.trim();
    }

    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }

    if (desc != null) {
      queryParams['desc'] = desc.toString();
    }

    final uri =
        Uri.parse(ApiConfig.dealsEndpoint).replace(queryParameters: queryParams);

    try {
      final response = await http
          .get(uri, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => DealModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load deals. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching deals: $e');
    }
  }

  // Fetch list of stores
  Future<List<StoreModel>> getStores() async {
    if (_cachedStores != null && _cachedStores!.isNotEmpty) {
      return _cachedStores!;
    }

    final uri = Uri.parse(ApiConfig.storesEndpoint);

    try {
      final response = await http
          .get(uri, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.timeoutDuration);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        _cachedStores = jsonList
            .map((json) => StoreModel.fromJson(json))
            .where((s) => s.isActive)
            .toList();
        return _cachedStores!;
      }
    } catch (_) {}
    return [];
  }

  // Fetch full game details and price comparison across stores
  Future<GameDetailModel> getGameDetail({
    required String gameID,
    String? dealID,
    DealModel? initialDeal,
  }) async {
    // 1. Fetch game deals comparison across all stores
    final gameUri = Uri.parse('${ApiConfig.gamesEndpoint}?id=$gameID');
    Map<String, dynamic>? gameJson;

    try {
      final response = await http
          .get(gameUri, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.timeoutDuration);
      if (response.statusCode == 200) {
        gameJson = jsonDecode(response.body);
      }
    } catch (_) {}

    // 2. Fetch specific deal details for publisher & extra metadata if dealID is available
    Map<String, dynamic>? dealJson;
    if (dealID != null && dealID.isNotEmpty) {
      try {
        final dealUri = Uri.parse('${ApiConfig.dealsEndpoint}?id=$dealID');
        final response = await http
            .get(dealUri, headers: ApiConfig.defaultHeaders)
            .timeout(ApiConfig.timeoutDuration);
        if (response.statusCode == 200) {
          dealJson = jsonDecode(response.body);
        }
      } catch (_) {}
    }

    final info = gameJson?['info'] as Map<String, dynamic>?;
    final cheapestEver =
        gameJson?['cheapestPriceEver'] as Map<String, dynamic>?;
    final dealsListRaw = gameJson?['deals'] as List<dynamic>?;
    final gameInfo = dealJson?['gameInfo'] as Map<String, dynamic>?;

    final title = info?['title'] ??
        gameInfo?['name'] ??
        initialDeal?.title ??
        'Game Detail';
    final thumb = info?['thumb'] ??
        gameInfo?['thumb'] ??
        initialDeal?.thumb ??
        '';
    final steamAppID = info?['steamAppID']?.toString() ??
        gameInfo?['steamAppID']?.toString() ??
        initialDeal?.steamAppID;

    final publisher = gameInfo?['publisher']?.toString();
    final metacriticScore = gameInfo?['metacriticScore']?.toString() ??
        initialDeal?.metacriticScore;
    final metacriticLink = gameInfo?['metacriticLink']?.toString();
    final steamRatingText = gameInfo?['steamRatingText']?.toString() ??
        initialDeal?.steamRatingText;
    final steamRatingPercent = gameInfo?['steamRatingPercent']?.toString() ??
        initialDeal?.steamRatingPercent;
    final steamRatingCount = gameInfo?['steamRatingCount']?.toString() ??
        initialDeal?.steamRatingCount;

    String? releaseDateStr;
    final rawRelDate = gameInfo?['releaseDate'] ?? initialDeal?.releaseDate;
    if (rawRelDate != null) {
      final intSec = rawRelDate is int ? rawRelDate : int.tryParse(rawRelDate.toString());
      if (intSec != null && intSec > 0) {
        final dt = DateTime.fromMillisecondsSinceEpoch(intSec * 1000);
        releaseDateStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    }

    // Build price comparisons across stores
    List<StorePriceComparison> comparisons = [];
    if (dealsListRaw != null && dealsListRaw.isNotEmpty) {
      comparisons = dealsListRaw
          .map((item) => StorePriceComparison.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (initialDeal != null) {
      // Fallback with initial store deal
      comparisons.add(StorePriceComparison(
        storeID: initialDeal.storeID,
        dealID: initialDeal.dealID,
        price: initialDeal.salePrice,
        retailPrice: initialDeal.normalPrice,
        savings: initialDeal.savings,
      ));
    }

    // Sort comparisons: lowest price first
    comparisons.sort((a, b) {
      final pA = double.tryParse(a.price) ?? double.infinity;
      final pB = double.tryParse(b.price) ?? double.infinity;
      return pA.compareTo(pB);
    });

    return GameDetailModel(
      gameID: gameID,
      title: title,
      thumb: thumb,
      steamAppID: steamAppID,
      publisher: publisher,
      metacriticScore: metacriticScore,
      metacriticLink: metacriticLink,
      steamRatingText: steamRatingText,
      steamRatingPercent: steamRatingPercent,
      steamRatingCount: steamRatingCount,
      releaseDate: releaseDateStr,
      cheapestPriceEver: cheapestEver?['price']?.toString(),
      cheapestPriceEverDate: cheapestEver?['date'] is int
          ? cheapestEver!['date']
          : int.tryParse(cheapestEver?['date']?.toString() ?? ''),
      storeComparisons: comparisons,
    );
  }
}
