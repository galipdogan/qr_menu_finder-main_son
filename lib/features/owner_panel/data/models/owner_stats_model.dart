import '../../domain/entities/owner_stats.dart';

/// Data model for owner statistics
class OwnerStatsModel extends OwnerStats {
  const OwnerStatsModel({
    required super.restaurantCount,
    required super.menuItemCount,
    required super.reviewCount,
    required super.viewCount,
    required super.lastUpdated,
  });

  /// Create from map
  factory OwnerStatsModel.fromMap(Map<String, dynamic> map) {
    return OwnerStatsModel(
      restaurantCount: map['restaurantCount'] as int? ?? 0,
      menuItemCount: map['menuItemCount'] as int? ?? 0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      viewCount: map['viewCount'] as int? ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'restaurantCount': restaurantCount,
      'menuItemCount': menuItemCount,
      'reviewCount': reviewCount,
      'viewCount': viewCount,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
