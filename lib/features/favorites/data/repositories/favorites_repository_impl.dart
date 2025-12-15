import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/favorite_item.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_data_source.dart';

/// Implementation of favorites repository
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FavoriteItem>>> getUserFavorites(
    String userId, {
    FavoriteType? type,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getUserFavorites(userId, type: type),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, void>> addFavorite({
    required String userId,
    required String itemId,
    required FavoriteType type,
  }) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.addFavorite(
        userId: userId,
        itemId: itemId,
        type: type,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String favoriteId) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.removeFavorite(favoriteId),
    );
  }

  @override
  Future<Either<Failure, bool>> isFavorite({
    required String userId,
    required String itemId,
  }) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.isFavorite(userId: userId, itemId: itemId),
      (result) => result as bool,
    );
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteIds(String userId) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getFavoriteIds(userId),
      (ids) => ids as List<String>,
    );
  }

  @override
  Future<Either<Failure, void>> clearUserFavorites(String userId) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.clearUserFavorites(userId),
    );
  }
}
