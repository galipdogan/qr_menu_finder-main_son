import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

/// Create restaurant use case
class CreateRestaurant implements UseCase<Restaurant, CreateRestaurantParams> {
  final RestaurantRepository repository;

  CreateRestaurant(this.repository);

  @override
  Future<Either<Failure, Restaurant>> call(CreateRestaurantParams params) async {
    return await repository.createRestaurant(params.restaurant);
  }
}

/// Parameters for create restaurant use case
class CreateRestaurantParams extends Equatable {
  final Restaurant restaurant;

  const CreateRestaurantParams({required this.restaurant});

  @override
  List<Object> get props => [restaurant];
}
