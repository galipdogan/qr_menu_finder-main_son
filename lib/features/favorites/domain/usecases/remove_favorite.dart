import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

/// Use case for removing item from favorites
class RemoveFavorite implements UseCase<void, RemoveFavoriteParams> {
  final FavoritesRepository repository;

  RemoveFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFavoriteParams params) async {
    return await repository.removeFavorite(params.favoriteId);
  }
}

/// Parameters for removing favorite
class RemoveFavoriteParams extends Equatable {
  final String favoriteId;

  const RemoveFavoriteParams({required this.favoriteId});

  @override
  List<Object> get props => [favoriteId];
}
