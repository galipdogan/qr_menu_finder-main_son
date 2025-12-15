import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

/// Search restaurants use case
class SearchRestaurants implements UseCase<List<Restaurant>, SearchRestaurantsParams> {
  final RestaurantRepository repository;

  SearchRestaurants(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(SearchRestaurantsParams params) async {
    return await repository.searchRestaurants(
      query: params.query,
      latitude: params.latitude,
      longitude: params.longitude,
      limit: params.limit,
    );
  }
}

/// Parameters for search restaurants use case
class SearchRestaurantsParams extends Equatable {
  final String query;
  final double? latitude;
  final double? longitude;
  final int limit;

  const SearchRestaurantsParams({
    required this.query,
    this.latitude,
    this.longitude,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, latitude, longitude, limit];
}