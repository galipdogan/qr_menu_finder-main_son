import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_item.dart';
import '../repositories/favorites_repository.dart';

/// Use case for adding item to favorites
class AddFavorite implements UseCase<void, AddFavoriteParams> {
  final FavoritesRepository repository;

  AddFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(AddFavoriteParams params) async {
    return await repository.addFavorite(
      userId: params.userId,
      itemId: params.itemId,
      type: params.type,
    );
  }
}

/// Parameters for adding favorite
class AddFavoriteParams extends Equatable {
  final String userId;
  final String itemId;
  final FavoriteType type;

  const AddFavoriteParams({
    required this.userId,
    required this.itemId,
    required this.type,
  });

  @override
  List<Object> get props => [userId, itemId, type];
}
