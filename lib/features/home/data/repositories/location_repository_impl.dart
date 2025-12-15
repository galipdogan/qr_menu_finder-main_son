import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/entities/turkey_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Location>> getCurrentLocation() async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getCurrentLocation(),
      (location) => location as Location,
    );
  }

  @override
  Future<Either<Failure, String>> getLocationName(Location location) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getLocationName(location),
      (name) => name as String,
    );
  }

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 10,
  }) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.searchPlaces(
        query: query,
        latitude: latitude,
        longitude: longitude,
        limit: limit,
      ),
      (suggestions) => suggestions as List<PlaceSuggestion>,
    );
  }

  @override
  Future<Either<Failure, List<TurkeyLocation>>> getTurkeyLocations() async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getTurkeyLocations(),
      (locations) => locations as List<TurkeyLocation>,
    );
  }
}
