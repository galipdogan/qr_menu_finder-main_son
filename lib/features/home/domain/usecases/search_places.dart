import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/place_suggestion.dart';
import '../repositories/location_repository.dart';

class SearchPlaces implements UseCase<List<PlaceSuggestion>, SearchPlacesParams> {
  final LocationRepository repository;

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

class SearchPlacesParams {
  final String query;
  final double? latitude;
  final double? longitude;
  final int limit;

  SearchPlacesParams({
    required this.query,
    this.latitude,
    this.longitude,
    this.limit = 10,
  });
}