import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/features/home/domain/entities/place_suggestion.dart'; // Reusing PlaceSuggestion

abstract class PlacesRepository {
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 10,
  });
  Future<Either<Failure, PlaceSuggestion>> reverseGeocode({
    required double latitude,
    required double longitude,
  });
  Future<Either<Failure, List<PlaceSuggestion>>> searchRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
  });
}
