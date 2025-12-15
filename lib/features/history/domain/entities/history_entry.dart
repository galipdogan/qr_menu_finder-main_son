import 'package:equatable/equatable.dart';

/// History entry types
enum HistoryType {
  restaurantView,
  itemView,
  menuView,
  search,
}

/// History entry entity for clean architecture
class HistoryEntry extends Equatable {
  final String id;
  final String userId;
  final HistoryType type;
  final String? restaurantId;
  final String? restaurantName;
  final String? itemId;
  final String? itemName;
  final String? searchQuery;
  final DateTime timestamp;

  const HistoryEntry({
    required this.id,
    required this.userId,
    required this.type,
    this.restaurantId,
    this.restaurantName,
    this.itemId,
    this.itemName,
    this.searchQuery,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        restaurantId,
        restaurantName,
        itemId,
        itemName,
        searchQuery,
        timestamp,
      ];
}
