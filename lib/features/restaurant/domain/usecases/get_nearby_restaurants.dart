import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

/// Get nearby restaurants use case
class GetNearbyRestaurants implements UseCase<List<Restaurant>, NearbyRestaurantsParams> {
  final RestaurantRepository repository;

  GetNearbyRestaurants(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(NearbyRestaurantsParams params) async {
    return await repository.getNearbyRestaurants(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusMeters: params.radiusMeters,
      limit: params.limit,
    );
  }
}

/// Parameters for nearby restaurants use case
class NearbyRestaurantsParams extends Equatable {
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final int limit;

  const NearbyRestaurantsParams({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 5000,
    this.limit = 20,
  });

  @override
  List<Object> get props => [latitude, longitude, radiusMeters, limit];
}