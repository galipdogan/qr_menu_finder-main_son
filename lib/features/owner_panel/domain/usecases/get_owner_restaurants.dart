import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/owner_restaurant.dart';
import '../repositories/owner_panel_repository.dart';

/// Use case for getting owner's restaurants
class GetOwnerRestaurants implements UseCase<List<OwnerRestaurant>, String> {
  final OwnerPanelRepository repository;

  GetOwnerRestaurants(this.repository);

  @override
  Future<Either<Failure, List<OwnerRestaurant>>> call(String params) async {
    return await repository.getOwnerRestaurants(params);
  }
}
