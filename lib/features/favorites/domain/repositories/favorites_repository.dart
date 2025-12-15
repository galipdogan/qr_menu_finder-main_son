import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/favorite_item.dart';

/// Abstract repository for favorites operations
abstract class FavoritesRepository {
  /// Get all favorites for a user
  Future<Either<Failure, List<FavoriteItem>>> getUserFavorites(
    String userId, {
    FavoriteType? type,
  });

  /// Add item to favorites
  Future<Either<Failure, void>> addFavorite({
    required String userId,
    required String itemId,
    required FavoriteType type,
  });

  /// Remove item from favorites
  Future<Either<Failure, void>> removeFavorite(String favoriteId);

  /// Check if item is favorited
  Future<Either<Failure, bool>> isFavorite({
    required String userId,
    required String itemId,
  });

  /// Get favorite IDs for a user (legacy support)
  Future<Either<Failure, List<String>>> getFavoriteIds(String userId);

  /// Clear all favorites for a user
  Future<Either<Failure, void>> clearUserFavorites(String userId);
}
