import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_item.dart';
import '../repositories/favorites_repository.dart';

/// Use case for getting user's favorites
class GetUserFavorites implements UseCase<List<FavoriteItem>, GetUserFavoritesParams> {
  final FavoritesRepository repository;

  GetUserFavorites(this.repository);

  @override
  Future<Either<Failure, List<FavoriteItem>>> call(GetUserFavoritesParams params) async {
    return await repository.getUserFavorites(
      params.userId,
      type: params.type,
    );
  }
}

/// Parameters for getting user favorites
class GetUserFavoritesParams extends Equatable {
  final String userId;
  final FavoriteType? type;

  const GetUserFavoritesParams({
    required this.userId,
    this.type,
  });

  @override
  List<Object?> get props => [userId, type];
}
