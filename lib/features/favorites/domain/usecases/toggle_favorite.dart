import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_item.dart';
import '../repositories/favorites_repository.dart';

/// Use case for toggling favorite (add or remove)
class ToggleFavorite implements UseCase<bool, ToggleFavoriteParams> {
  final FavoritesRepository repository;

  ToggleFavorite(this.repository);

  @override
  Future<Either<Failure, bool>> call(ToggleFavoriteParams params) async {
    try {
      // Check if already favorited
      final isFavoriteResult = await repository.isFavorite(
        userId: params.userId,
        itemId: params.itemId,
      );

      return await isFavoriteResult.fold(
        (failure) => Left(failure),
        (isFavorite) async {
          if (isFavorite) {
            // Remove from favorites
            // First get all favorites to find the ID
            final favorites = await repository.getUserFavorites(
              params.userId,
              type: params.type,
            );
            
            return await favorites.fold(
              (failure) => Left(failure),
              (favoritesList) async {
                // Find the favorite to remove
                final favorite = favoritesList.firstWhere(
                  (f) => f.itemId == params.itemId,
                  orElse: () => FavoriteItem(
                    id: '',
                    userId: params.userId,
                    itemId: params.itemId,
                    type: params.type,
                    createdAt: DateTime.now(),
                  ),
                );

                if (favorite.id.isEmpty) {
                  // Not found, return false
                  return const Right(false);
                }

                // Remove the favorite
                final removeResult = await repository.removeFavorite(favorite.id);
                return removeResult.fold(
                  (failure) => Left(failure),
                  (_) => const Right(false), // Returns false = not favorited anymore
                );
              },
            );
          } else {
            // Add to favorites
            final addResult = await repository.addFavorite(
              userId: params.userId,
              itemId: params.itemId,
              type: params.type,
            );
            return addResult.fold(
              (failure) => Left(failure),
              (_) => const Right(true), // Returns true = now favorited
            );
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure('Toggle favorite failed: ${e.toString()}'));
    }
  }
}

/// Parameters for toggling favorite
class ToggleFavoriteParams extends Equatable {
  final String userId;
  final String itemId;
  final FavoriteType type;

  const ToggleFavoriteParams({
    required this.userId,
    required this.itemId,
    required this.type,
  });

  @override
  List<Object> get props => [userId, itemId, type];
}
