import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/history_entry.dart';

/// History entry model for data layer - extends domain entity
class HistoryEntryModel extends HistoryEntry {
  const HistoryEntryModel({
    required super.id,
    required super.userId,
    required super.type,
    super.restaurantId,
    super.restaurantName,
    super.itemId,
    super.itemName,
    super.searchQuery,
    required super.timestamp,
  });

  /// Create from Firestore document
  factory HistoryEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryEntryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: _parseHistoryType(data['type'] as String?),
      restaurantId: data['restaurantId'] as String?,
      restaurantName: data['restaurantName'] as String?,
      itemId: data['itemId'] as String?,
      itemName: data['itemName'] as String?,
      searchQuery: data['searchQuery'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      if (restaurantId != null) 'restaurantId': restaurantId,
      if (restaurantName != null) 'restaurantName': restaurantName,
      if (itemId != null) 'itemId': itemId,
      if (itemName != null) 'itemName': itemName,
      if (searchQuery != null) 'searchQuery': searchQuery,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Parse history type from string
  static HistoryType _parseHistoryType(String? typeStr) {
    switch (typeStr) {
      case 'restaurantView':
        return HistoryType.restaurantView;
      case 'itemView':
        return HistoryType.itemView;
      case 'menuView':
        return HistoryType.menuView;
      case 'search':
        return HistoryType.search;
      default:
        return HistoryType.restaurantView;
    }
  }

  /// Convert to domain entity
  HistoryEntry toEntity() {
    return HistoryEntry(
      id: id,
      userId: userId,
      type: type,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      itemId: itemId,
      itemName: itemName,
      searchQuery: searchQuery,
      timestamp: timestamp,
    );
  }

  /// Convert from domain entity
  factory HistoryEntryModel.fromEntity(HistoryEntry entity) {
    return HistoryEntryModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      itemId: entity.itemId,
      itemName: entity.itemName,
      searchQuery: entity.searchQuery,
      timestamp: entity.timestamp,
    );
  }
}
