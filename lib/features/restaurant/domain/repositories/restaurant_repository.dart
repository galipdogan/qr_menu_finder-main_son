import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/restaurant.dart';

/// Abstract restaurant repository for clean architecture
abstract class RestaurantRepository {
  /// Get nearby restaurants
  Future<Either<Failure, List<Restaurant>>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    int limit = 20,
  });
  
  /// Search restaurants by name or category
  Future<Either<Failure, List<Restaurant>>> searchRestaurants({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  });
  
  /// Get restaurant by ID
  Future<Either<Failure, Restaurant>> getRestaurantById(String id);
  
  /// Get restaurants by owner ID
  Future<Either<Failure, List<Restaurant>>> getRestaurantsByOwnerId(String ownerId);
  
  /// Create new restaurant
  Future<Either<Failure, Restaurant>> createRestaurant(Restaurant restaurant);
  
  /// Update restaurant
  Future<Either<Failure, Restaurant>> updateRestaurant(Restaurant restaurant);
  
  /// Delete restaurant
  Future<Either<Failure, void>> deleteRestaurant(String id);
  
  /// Get popular restaurants
  Future<Either<Failure, List<Restaurant>>> getPopularRestaurants({
    int limit = 10,
  });
  
  /// Get restaurants by category
  Future<Either<Failure, List<Restaurant>>> getRestaurantsByCategory({
    required String category,
    int limit = 20,
  });
}