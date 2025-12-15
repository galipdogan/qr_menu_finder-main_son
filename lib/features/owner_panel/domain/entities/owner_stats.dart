import 'package:equatable/equatable.dart';

/// Domain entity for owner panel statistics
class OwnerStats extends Equatable {
  final int restaurantCount;
  final int menuItemCount;
  final int reviewCount;
  final int viewCount;
  final DateTime lastUpdated;

  const OwnerStats({
    required this.restaurantCount,
    required this.menuItemCount,
    required this.reviewCount,
    required this.viewCount,
    required this.lastUpdated,
  });

  /// Empty stats
  factory OwnerStats.empty() {
    return OwnerStats(
      restaurantCount: 0,
      menuItemCount: 0,
      reviewCount: 0,
      viewCount: 0,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        restaurantCount,
        menuItemCount,
        reviewCount,
        viewCount,
        lastUpdated,
      ];
}
