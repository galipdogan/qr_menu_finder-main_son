import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_item.dart';

/// Base class for all favorites events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when favorites need to be loaded
class FavoritesLoadRequested extends FavoritesEvent {
  final String userId;
  final FavoriteType? type;

  const FavoritesLoadRequested({
    required this.userId,
    this.type,
  });

  @override
  List<Object?> get props => [userId, type];
}

/// Triggered when user toggles favorite status
class FavoriteToggleRequested extends FavoritesEvent {
  final String userId;
  final String itemId;
  final FavoriteType type;

  const FavoriteToggleRequested({
    required this.userId,
    required this.itemId,
    required this.type,
  });

  @override
  List<Object> get props => [userId, itemId, type];
}

/// Triggered when user adds an item to favorites
class FavoriteAddRequested extends FavoritesEvent {
  final String userId;
  final String itemId;
  final FavoriteType type;

  const FavoriteAddRequested({
    required this.userId,
    required this.itemId,
    required this.type,
  });

  @override
  List<Object> get props => [userId, itemId, type];
}

/// Triggered when user removes an item from favorites
class FavoriteRemoveRequested extends FavoritesEvent {
  final String favoriteId;

  const FavoriteRemoveRequested({required this.favoriteId});

  @override
  List<Object> get props => [favoriteId];
}
