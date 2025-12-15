import 'package:equatable/equatable.dart';

/// Favorite type enumeration
enum FavoriteType {
  restaurant,
  menuItem,
}

/// Domain entity for favorite item
class FavoriteItem extends Equatable {
  final String id;
  final String userId;
  final String itemId; // Restaurant or menu item ID
  final FavoriteType type;
  final DateTime createdAt;

  const FavoriteItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, userId, itemId, type, createdAt];
}
