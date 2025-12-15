import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/places/domain/repositories/places_repository.dart';
import 'package:qr_menu_finder/features/home/domain/entities/place_suggestion.dart';

class SearchPlaces implements UseCase<List<PlaceSuggestion>, SearchPlacesParams> {
  final PlacesRepository repository;

  SearchPlaces(this.repository);

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> call(SearchPlacesParams params) async {
    return await repository.searchPlaces(
      query: params.query,
      latitude: params.latitude,
      longitude: params.longitude,
      limit: params.limit,
    );
  }
}

class SearchPlacesParams extends Equatable {
  final String query;
  final double? latitude;
  final double? longitude;
  final int limit;

  const SearchPlacesParams({
    required this.query,
    this.latitude,
    this.longitude,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [query, latitude, longitude, limit];
}
