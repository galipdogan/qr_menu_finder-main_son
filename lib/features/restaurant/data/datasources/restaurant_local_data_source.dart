import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error.dart';
import '../models/restaurant_model.dart';

/// Abstract restaurant local data source
abstract class RestaurantLocalDataSource {
  /// Get cached nearby restaurants
  Future<List<RestaurantModel>> getCachedNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  });
  
  /// Cache nearby restaurants
  Future<void> cacheNearbyRestaurants({
    required double latitude,
    required double longitude,
    required List<RestaurantModel> restaurants,
    int radiusMeters = 5000,
  });
  
  /// Get cached restaurant by ID
  Future<RestaurantModel?> getCachedRestaurant(String id);
  
  /// Cache restaurant
  Future<void> cacheRestaurant(RestaurantModel restaurant);
  
  /// Clear restaurant cache
  Future<void> clearRestaurantCache();
}

/// Cache implementation of restaurant local data source
class RestaurantLocalDataSourceImpl implements RestaurantLocalDataSource {
  final CacheManager cacheManager;

  RestaurantLocalDataSourceImpl({required this.cacheManager});

  @override
  Future<List<RestaurantModel>> getCachedNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    try {
      final key = 'nearby_restaurants_${latitude}_${longitude}_$radiusMeters';
      final cachedData = cacheManager.getCachedData<List<dynamic>>(key);
      
      if (cachedData == null) {
        throw const CacheException('No cached nearby restaurants');
      }
      
      return cachedData
          .map((json) => RestaurantModel.fromFirestore(
                // This would need proper DocumentSnapshot mock
                // For now, we'll throw an exception
                throw const CacheException('Cache implementation needs DocumentSnapshot mock'),
              ))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached nearby restaurants: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheNearbyRestaurants({
    required double latitude,
    required double longitude,
    required List<RestaurantModel> restaurants,
    int radiusMeters = 5000,
  }) async {
    try {
      final key = 'nearby_restaurants_${latitude}_${longitude}_$radiusMeters';
      final data = restaurants.map((r) => r.toFirestore()).toList();
      
      await cacheManager.cacheData(
        key: key,
        data: data,
        ttl: const Duration(minutes: 15), // Short TTL for location-based data
      );
    } catch (e) {
      throw CacheException('Failed to cache nearby restaurants: ${e.toString()}');
    }
  }

  @override
  Future<RestaurantModel?> getCachedRestaurant(String id) async {
    try {
      final key = 'restaurant_$id';
      final cachedData = cacheManager.getCachedData<Map<String, dynamic>>(key);
      
      if (cachedData == null) {
        return null;
      }
      
      // This would need proper DocumentSnapshot mock
      // For now, return null
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached restaurant: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheRestaurant(RestaurantModel restaurant) async {
    try {
      final key = 'restaurant_${restaurant.id}';
      await cacheManager.cacheData(
        key: key,
        data: restaurant.toFirestore(),
        ttl: const Duration(hours: 2), // Longer TTL for individual restaurants
      );
    } catch (e) {
      throw CacheException('Failed to cache restaurant: ${e.toString()}');
    }
  }

  @override
  Future<void> clearRestaurantCache() async {
    try {
      // This would clear all restaurant-related cache
      // Implementation would depend on cache key patterns
    } catch (e) {
      throw CacheException('Failed to clear restaurant cache: ${e.toString()}');
    }
  }
}