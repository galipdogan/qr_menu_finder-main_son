import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/favorite_item.dart';

/// Favorite item model for data layer - extends domain entity
class FavoriteItemModel extends FavoriteItem {
  const FavoriteItemModel({
    required super.id,
    required super.userId,
    required super.itemId,
    required super.type,
    required super.createdAt,
  });

  /// Create from Firestore document
  factory FavoriteItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteItemModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      itemId: data['itemId'] ?? '',
      type: _parseType(data['type'] as String?),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemId': itemId,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Parse favorite type from string
  static FavoriteType _parseType(String? typeStr) {
    switch (typeStr) {
      case 'restaurant':
        return FavoriteType.restaurant;
      case 'menuItem':
        return FavoriteType.menuItem;
      default:
        return FavoriteType.restaurant;
    }
  }

  /// Convert to domain entity
  FavoriteItem toEntity() {
    return FavoriteItem(
      id: id,
      userId: userId,
      itemId: itemId,
      type: type,
      createdAt: createdAt,
    );
  }

  /// Convert from domain entity
  factory FavoriteItemModel.fromEntity(FavoriteItem entity) {
    return FavoriteItemModel(
      id: entity.id,
      userId: entity.userId,
      itemId: entity.itemId,
      type: entity.type,
      createdAt: entity.createdAt,
    );
  }
}
