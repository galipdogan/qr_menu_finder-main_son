import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/places/domain/repositories/places_repository.dart';
import 'package:qr_menu_finder/features/home/domain/entities/place_suggestion.dart';

class SearchRestaurants implements UseCase<List<PlaceSuggestion>, SearchRestaurantsParams> {
  final PlacesRepository repository;

  SearchRestaurants(this.repository);

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> call(SearchRestaurantsParams params) async {
    return await repository.searchRestaurants(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: params.radiusKm,
      limit: params.limit,
    );
  }
}

class SearchRestaurantsParams extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final int limit;

  const SearchRestaurantsParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 5.0,
    this.limit = 20,
  });

  @override
  List<Object> get props => [latitude, longitude, radiusKm, limit];
}
