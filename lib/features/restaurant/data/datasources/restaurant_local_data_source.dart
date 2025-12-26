import 'package:qr_menu_finder/core/cache/cache_manager.dart';
import 'package:qr_menu_finder/features/restaurant/data/models/restaurant_model.dart';

abstract class RestaurantLocalDataSource {
  Future<RestaurantModel?> getRestaurantById(String id);
  Future<void> cacheRestaurant(RestaurantModel restaurant);
  Future<List<RestaurantModel>?> getNearbyRestaurants(
      double latitude, double longitude);
  Future<void> cacheNearbyRestaurants(
      List<RestaurantModel> restaurants, double latitude, double longitude);
}

class RestaurantLocalDataSourceImpl implements RestaurantLocalDataSource {
  final CacheManager<Map<String, dynamic>> _cacheManager;

  RestaurantLocalDataSourceImpl(this._cacheManager);

  static const _restaurantKeyPrefix = 'restaurant_';
  static const _nearbyRestaurantsKeyPrefix = 'nearby_restaurants_';
  static final _ttl = const Duration(minutes: 30);

  String _getRestaurantKey(String id) => '$_restaurantKeyPrefix$id';
  String _getNearbyRestaurantsKey(double lat, double lon) =>
      '$_nearbyRestaurantsKeyPrefix${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';

  @override
  Future<void> cacheRestaurant(RestaurantModel restaurant) async {
    await _cacheManager.set(
      _getRestaurantKey(restaurant.id),
      restaurant.toJson(),
      ttl: _ttl,
    );
  }

  @override
  Future<RestaurantModel?> getRestaurantById(String id) async {
    final json = await _cacheManager.get(_getRestaurantKey(id));
    if (json != null) {
      return RestaurantModel.fromJson(json);
    }
    return null;
  }

  @override
  Future<void> cacheNearbyRestaurants(List<RestaurantModel> restaurants,
      double latitude, double longitude) async {
    final key = _getNearbyRestaurantsKey(latitude, longitude);
    final data = {
      'restaurants': restaurants.map((r) => r.toJson()).toList(),
    };
    await _cacheManager.set(key, data, ttl: _ttl);
  }

  @override
  Future<List<RestaurantModel>?> getNearbyRestaurants(
      double latitude, double longitude) async {
    final key = _getNearbyRestaurantsKey(latitude, longitude);
    final data = await _cacheManager.get(key);
    if (data != null && data['restaurants'] is List) {
      final list = data['restaurants'] as List;
      return list.map((json) => RestaurantModel.fromJson(json)).toList();
    }
    return null;
  }
}
