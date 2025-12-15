import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../entities/location.dart';
import '../entities/place_suggestion.dart';
import '../entities/turkey_location.dart';

abstract class LocationRepository {
  Future<Either<Failure, Location>> getCurrentLocation();
  Future<Either<Failure, String>> getLocationName(Location location);
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 10,
  });
  Future<Either<Failure, List<TurkeyLocation>>> getTurkeyLocations();
}
