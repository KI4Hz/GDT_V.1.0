class WishlistItemModel {
  final int id;
  final int? userId;
  final String gameId;
  final String title;
  final double salePrice;
  final double normalPrice;
  final String thumb;
  final DateTime? savedAt;

  WishlistItemModel({
    required this.id,
    this.userId,
    required this.gameId,
    required this.title,
    required this.salePrice,
    required this.normalPrice,
    required this.thumb,
    this.savedAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['saved_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['saved_at'].toString());
      } catch (_) {}
    }

    return WishlistItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      gameId: json['game_id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Game',
      salePrice: (json['sale_price'] is num)
          ? (json['sale_price'] as num).toDouble()
          : double.tryParse(json['sale_price']?.toString() ?? '0') ?? 0.0,
      normalPrice: (json['normal_price'] is num)
          ? (json['normal_price'] as num).toDouble()
          : double.tryParse(json['normal_price']?.toString() ?? '0') ?? 0.0,
      thumb: json['thumb'] ?? '',
      savedAt: parsedDate,
    );
  }

  int get savingsPercentage {
    if (normalPrice <= 0 || salePrice >= normalPrice) return 0;
    return (((normalPrice - salePrice) / normalPrice) * 100).round();
  }
}

