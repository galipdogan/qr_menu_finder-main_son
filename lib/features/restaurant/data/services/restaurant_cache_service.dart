import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/restaurant_model.dart';

/// Service for caching restaurants to Firebase
class RestaurantCacheService {
  final FirebaseFirestore firestore;

  RestaurantCacheService({required this.firestore});

  /// Cache restaurants to Firebase for future detail page access
  void cacheRestaurantsToFirebase(List<RestaurantModel> restaurants) {
    Future.microtask(() async {
      for (final restaurant in restaurants) {
        try {
          // ✅ Normalize ID
          final normalizedId = restaurant.placeId;

          // ✅ Check if already exists
          final existing = await firestore
              .collection('restaurants')
              .doc(normalizedId)
              .get();

          if (!existing.exists) {
            await firestore
                .collection('restaurants')
                .doc(normalizedId)
                .set(restaurant.toFirestore(), SetOptions(merge: true));

            AppLogger.i("💾 Cached restaurant: $normalizedId");
          }
        } catch (e) {
          AppLogger.w('Failed to cache restaurant ${restaurant.id}: $e');
        }
      }
    });
  }

  /// Get cached restaurant from Firebase by place ID
  Future<RestaurantModel?> getCachedRestaurant(String placeId) async {
    try {
      final normalizedId = "osm_$placeId";

      final doc = await firestore
          .collection('restaurants')
          .doc(normalizedId)
          .get();

      if (doc.exists) {
        AppLogger.i('✅ Found cached restaurant in Firebase');
        return RestaurantModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      AppLogger.w('Failed to get cached restaurant: $e');
      return null;
    }
  }

  /// Cache single restaurant to Firebase
  Future<void> cacheRestaurant(RestaurantModel restaurant) async {
    try {
      final normalizedId = restaurant.placeId;

      await firestore
          .collection('restaurants')
          .doc(normalizedId)
          .set(restaurant.toFirestore(), SetOptions(merge: true));

      AppLogger.i('💾 Cached restaurant data in Firebase');
    } catch (e) {
      AppLogger.w('⚠️ Failed to cache in Firebase: $e');
    }
  }

  /// Check which restaurants have menus in Firebase
  Future<Set<String>> getRestaurantsWithMenus(List<String> placeIds) async {
    if (placeIds.isEmpty) return {};

    final Set<String> restaurantsWithMenus = {};

    try {
      final uniqueIds = placeIds.toSet().toList();
      final List<List<String>> batches = [];

      for (int i = 0; i < uniqueIds.length; i += 10) {
        batches.add(uniqueIds.skip(i).take(10).toList());
      }

      final queries = batches
          .map(
            (batch) => firestore
                .collection('restaurants')
                .where('placeId', whereIn: batch)
                .get(),
          )
          .toList();

      final snapshots = await Future.wait(queries);

      for (final snapshot in snapshots) {
        for (final doc in snapshot.docs) {
          final placeId = doc.data()['placeId']?.toString();
          if (placeId != null) {
            restaurantsWithMenus.add(placeId);
          }
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
}
