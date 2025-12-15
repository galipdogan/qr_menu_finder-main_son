import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

/// Get restaurant by ID use case
class GetRestaurantById implements UseCase<Restaurant, RestaurantByIdParams> {
  final RestaurantRepository repository;

  GetRestaurantById(this.repository);

  @override
  Future<Either<Failure, Restaurant>> call(RestaurantByIdParams params) async {
    return await repository.getRestaurantById(params.id);
  }
}

/// Parameters for get restaurant by ID use case
class RestaurantByIdParams extends Equatable {
  final String id;

  const RestaurantByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}