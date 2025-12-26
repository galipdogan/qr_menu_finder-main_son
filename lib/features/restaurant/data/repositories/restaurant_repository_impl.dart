import 'package:dartz/dartz.dart';
//import 'package:qr_menu_finder/core/error/exceptions.dart';
import '../../../../core/error/error.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../../../core/mapper/mapper.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_local_data_source.dart';
import '../datasources/restaurant_remote_data_source.dart';
import '../models/restaurant_model.dart';

/// Implementation of restaurant repository
class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;
  final RestaurantLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Mappr mappr;

  RestaurantRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.mappr,
  });

  @override
  Future<Either<Failure, List<Restaurant>>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRestaurants = await remoteDataSource.getNearbyRestaurants(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
          limit: limit,
        );
        await localDataSource.cacheNearbyRestaurants(
          remoteRestaurants,
          latitude,
          longitude,
        );
        return Right(
          remoteRestaurants
              .map(
                (e) => mappr.convert<RestaurantModel, Restaurant>(e),
              )
              .toList(),
        );
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      }
    } else {
      try {
        final localRestaurants = await localDataSource.getNearbyRestaurants(
          latitude,
          longitude,
        );
        if (localRestaurants != null) {
          return Right(
            localRestaurants
                .map(
                  (e) => mappr.convert<RestaurantModel, Restaurant>(e),
                )
                .toList(),
          );
        } else {
          return Left(CacheFailure('No cached data available.'));
        }
      } on CacheException {
        return Left(CacheFailure('Failed to retrieve data from cache.'));
      }
    }
  }

  @override
  Future<Either<Failure, Restaurant>> getRestaurantById(String id) async {
    // Try getting from cache first
    try {
      final localRestaurant = await localDataSource.getRestaurantById(id);
      if (localRestaurant != null) {
        return Right(
          mappr.convert<RestaurantModel, Restaurant>(localRestaurant),
        );
      }
    } on CacheException {
      // Ignore cache failure and proceed to remote
    }

    // If not in cache or cache failed, get from remote
    if (await networkInfo.isConnected) {
      try {
        final remoteRestaurant = await remoteDataSource.getRestaurantById(id);
        await localDataSource.cacheRestaurant(remoteRestaurant);
        return Right(
          mappr.convert<RestaurantModel, Restaurant>(remoteRestaurant),
        );
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      }
    } else {
      return Left(NetworkFailure('No internet connection.'));
    }
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
      (model) => mappr.convert<RestaurantModel, Restaurant>(model),
    );
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurantsByOwnerId(
    String ownerId,
  ) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getRestaurantsByOwnerId(ownerId),
      (model) => mappr.convert<RestaurantModel, Restaurant>(model),
    );
  }

  @override
  Future<Either<Failure, Restaurant>> createRestaurant(
    Restaurant restaurant,
  ) async {
    try {
      final restaurantModel = mappr.convert<Restaurant, RestaurantModel>(
        restaurant,
      );
      final createdRestaurantModel = await remoteDataSource.createRestaurant(
        restaurantModel,
      );
      return Right(
        mappr.convert<RestaurantModel, Restaurant>(createdRestaurantModel),
      );
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
    try {
      final restaurantModel = mappr.convert<Restaurant, RestaurantModel>(
        restaurant,
      );
      final updatedRestaurantModel = await remoteDataSource.updateRestaurant(
        restaurantModel,
      );
      return Right(
        mappr.convert<RestaurantModel, Restaurant>(updatedRestaurantModel),
      );
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
      (model) => mappr.convert<RestaurantModel, Restaurant>(model),
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
      (model) => mappr.convert<RestaurantModel, Restaurant>(model),
    );
  }
}
