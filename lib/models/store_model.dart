import '../config/api_config.dart';

class StoreModel {
  final String storeID;
  final String storeName;
  final bool isActive;
  final String? banner;
  final String? logo;
  final String? icon;

  StoreModel({
    required this.storeID,
    required this.storeName,
    required this.isActive,
    this.banner,
    this.logo,
    this.icon,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    return StoreModel(
      storeID: json['storeID']?.toString() ?? '',
      storeName: json['storeName'] ?? 'Store',
      isActive: (json['isActive'] == 1 || json['isActive'] == '1'),
      banner: images?['banner'],
      logo: images?['logo'],
      icon: images?['icon'],
    );
  }

  String get iconUrl {
    if (icon != null && icon!.isNotEmpty) {
      return ApiConfig.getStoreAssetUrl(icon!);
    }
    // Fallback based on store ID
    final idInt = int.tryParse(storeID);
    if (idInt != null && idInt > 0) {
      return ApiConfig.getStoreIconUrl(idInt - 1);
    }
    return '';
  }

  // Predefined store names and helper
  static final Map<String, String> _knownStores = {
    '1': 'Steam',
    '2': 'GamersGate',
    '3': 'GreenManGaming',
    '4': 'Amazon',
    '5': 'GameStop',
    '6': 'Direct2Drive',
    '7': 'GOG',
    '8': 'Origin / EA',
    '11': 'Humble Store',
    '13': 'Uplay / Ubisoft',
    '15': 'Fanatical',
    '21': 'WinGameStore',
    '23': 'GameBillet',
    '24': 'Voidu',
    '25': 'Epic Games',
    '27': 'Gamesplanet',
    '30': 'IndieGala',
    '31': 'Blizzard',
    '32': 'AllYouPlay',
    '33': 'DLGamer',
    '35': 'DreamGame',
  };

  static String getStoreName(String storeID) {
    return _knownStores[storeID] ?? 'Store #$storeID';
  }

  static String getStoreIcon(String storeID) {
    final idInt = int.tryParse(storeID);
    if (idInt != null && idInt > 0) {
      return ApiConfig.getStoreIconUrl(idInt - 1);
    }
    return '';
  }
}
