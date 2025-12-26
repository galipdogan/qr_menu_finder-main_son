import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/cache/firebase_cache_manager.dart';
import '../../../../core/cache/cache_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/restaurant_model.dart';

/// Restaurant cache service using FirebaseCacheManager
/// TR: FirebaseCacheManager kullanan restoran önbellek servisi
/// 
/// Adapter pattern: Wraps FirebaseCacheManager for restaurant-specific operations
/// Adapter pattern: Restoran-özel işlemler için FirebaseCacheManager'ı sarar
class RestaurantCacheService implements CacheService<RestaurantModel> {
  final FirebaseCacheManager<RestaurantModel> _cacheManager;

  RestaurantCacheService({required FirebaseFirestore firestore})
      : _cacheManager = FirebaseCacheManager<RestaurantModel>(
          firestore: firestore,
          collectionName: AppConstants.restaurantsCollection,
          fromFirestore: (doc) => RestaurantModel.fromFirestore(doc),
          toFirestore: (restaurant) => restaurant.toFirestore(),
        );

  @override
  Future<RestaurantModel?> get(String key) async {
    return await _cacheManager.get(key);
  }

  @override
  Future<void> set(String key, RestaurantModel value, {Duration? ttl}) async {
    await _cacheManager.set(key, value, ttl: ttl);
  }

  @override
  Future<void> remove(String key) async {
    await _cacheManager.remove(key);
  }

  @override
  Future<void> clear() async {
    await _cacheManager.clear();
  }

  /// Cache restaurants to Firebase for future detail page access
  /// TR: Gelecekteki detay sayfası erişimi için restoranları Firebase'e önbelleğe al
  void cacheRestaurantsToFirebase(List<RestaurantModel> restaurants) {
    Future.microtask(() async {
      final items = <String, RestaurantModel>{};
      
      for (final restaurant in restaurants) {
        final normalizedId = restaurant.placeId;
        
        // Check if already cached to avoid unnecessary writes
        final isCached = await _cacheManager.isCached(normalizedId);
        if (!isCached) {
          items[normalizedId] = restaurant;
        }
      }

      if (items.isNotEmpty) {
        await _cacheManager.setMultiple(items);
        AppLogger.i('💾 Cached ${items.length} restaurants to Firebase');
      }
    });
  }

  /// Get cached restaurant from Firebase by place ID
  /// TR: Place ID'ye göre Firebase'den önbelleğe alınmış restoranı getir
  Future<RestaurantModel?> getCachedRestaurant(String placeId) async {
    try {
      final normalizedId = placeId.startsWith('osm_') ? placeId : 'osm_$placeId';
      final restaurant = await _cacheManager.get(normalizedId);

      if (restaurant != null) {
        AppLogger.i('✅ Found cached restaurant in Firebase: $normalizedId');
      }

      return restaurant;
    } catch (e) {
      AppLogger.w('Failed to get cached restaurant: $e');
      return null;
    }
  }

  /// Cache single restaurant to Firebase
  /// TR: Tek bir restoranı Firebase'e önbelleğe al
  Future<void> cacheRestaurant(RestaurantModel restaurant) async {
    try {
      final normalizedId = restaurant.placeId;
      await _cacheManager.set(normalizedId, restaurant);
      AppLogger.i('💾 Cached restaurant data in Firebase: $normalizedId');
    } catch (e) {
      AppLogger.w('⚠️ Failed to cache restaurant in Firebase: $e');
    }
  }

  /// Check which restaurants have menus in Firebase
  /// TR: Firebase'de hangi restoranların menüsü olduğunu kontrol et
  Future<Set<String>> getRestaurantsWithMenus(List<String> placeIds) async {
    if (placeIds.isEmpty) return {};

    final Set<String> restaurantsWithMenus = {};

    try {
      final restaurants = await _cacheManager.getMultiple(placeIds);

      for (final restaurant in restaurants) {
        if (restaurant.hasMenu) {
          restaurantsWithMenus.add(restaurant.placeId);
        }
      }

      AppLogger.i(
        '✅ Found ${restaurantsWithMenus.length} restaurants with menus in Firebase',
      );
    } catch (e) {
      AppLogger.w('Firebase batch check failed: $e');
    }

    return restaurantsWithMenus;
  }

  /// Clean expired restaurant cache entries
  /// TR: Süresi dolmuş restoran önbellek girişlerini temizle
  Future<void> cleanExpiredCache() async {
    await _cacheManager.cleanExpired();
  }
}
