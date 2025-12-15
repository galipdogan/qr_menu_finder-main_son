import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';
import '../models/restaurant_model.dart';

/// Implementation of restaurant repository
class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Restaurant>>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    int limit = 20,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        limit: limit,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<Restaurant>>> searchRestaurants({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.searchRestaurants(
        query: query,
        latitude: latitude,
        longitude: longitude,
        limit: limit,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, Restaurant>> getRestaurantById(String id) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getRestaurantById(id),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurantsByOwnerId(
    String ownerId,
  ) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getRestaurantsByOwnerId(ownerId),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, Restaurant>> createRestaurant(
    Restaurant restaurant,
  ) async {
    if (restaurant is! RestaurantModel) {
      return Left(
        GeneralFailure(
          'createRestaurant requires a full RestaurantModel, but received a base Restaurant entity.',
        ),
      );
    }
    try {
      final createdRestaurantModel = await remoteDataSource.createRestaurant(
        restaurant,
      );
      return Right(createdRestaurantModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Restaurant>> updateRestaurant(
    Restaurant restaurant,
  ) async {
    if (restaurant is! RestaurantModel) {
      return Left(
        GeneralFailure(
          'updateRestaurant requires a full RestaurantModel, but received a base Restaurant entity.',
        ),
      );
    }
    try {
      final updatedRestaurantModel = await remoteDataSource.updateRestaurant(
        restaurant,
      );
      return Right(updatedRestaurantModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRestaurant(String id) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.deleteRestaurant(id),
    );
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getPopularRestaurants({
    int limit = 10,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getPopularRestaurants(limit: limit),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurantsByCategory({
    required String category,
    int limit = 20,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getRestaurantsByCategory(
        category: category,
        limit: limit,
      ),
      (model) => model.toEntity(),
    );
  }
}
