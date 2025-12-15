import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/owner_stats_model.dart';
import '../models/owner_restaurant_model.dart';

/// Remote data source for Owner Panel feature
abstract class OwnerPanelRemoteDataSource {
  /// Get owner statistics
  Future<OwnerStatsModel> getOwnerStats(String ownerId);

  /// Get owner's restaurants with details
  Future<List<OwnerRestaurantModel>> getOwnerRestaurants(String ownerId);

  /// Request owner account upgrade
  Future<void> requestOwnerUpgrade(String userId);
}

/// Implementation of OwnerPanelRemoteDataSource using Firebase Firestore
class OwnerPanelRemoteDataSourceImpl implements OwnerPanelRemoteDataSource {
  final FirebaseFirestore firestore;

  OwnerPanelRemoteDataSourceImpl({required this.firestore});

  @override
  Future<OwnerStatsModel> getOwnerStats(String ownerId) async {
    try {
      // Get owner's restaurants
      final restaurantsSnapshot = await firestore
          .collection('restaurants')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      final restaurants = restaurantsSnapshot.docs;
      int totalMenuItems = 0;
      int totalReviews = 0;

      // Calculate stats for each restaurant
      for (final restaurant in restaurants) {
        // Get menu items count
        final itemsSnapshot = await firestore
            .collection('menu_items')
            .where('restaurantId', isEqualTo: restaurant['placeId'])
            .get();
        totalMenuItems += itemsSnapshot.docs.length;

        // Get reviews count
        final reviewsSnapshot = await firestore
            .collection('reviews')
            .where('restaurantId', isEqualTo: restaurant['placeId'])
            .get();
        totalReviews += reviewsSnapshot.docs.length;
      }

      return OwnerStatsModel(
        restaurantCount: restaurants.length,
        menuItemCount: totalMenuItems,
        reviewCount: totalReviews,
        viewCount: 0, // View tracking not implemented yet
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to load owner stats: $e');
    }
  }

  @override
  Future<List<OwnerRestaurantModel>> getOwnerRestaurants(String ownerId) async {
    try {
      final restaurantsSnapshot = await firestore
          .collection('restaurants')
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<OwnerRestaurantModel> restaurants = [];

      for (final doc in restaurantsSnapshot.docs) {
        // Get menu items count
        final itemsSnapshot = await firestore
            .collection('menu_items')
            .where('restaurantId', isEqualTo: doc['placeId'])
            .get();

        // Get reviews count and average rating
        final reviewsSnapshot = await firestore
            .collection('reviews')
            .where('restaurantId', isEqualTo: doc['placeId'])
            .get();

        double? avgRating;
        if (reviewsSnapshot.docs.isNotEmpty) {
          final ratings = reviewsSnapshot.docs
              .map((r) => (r.data()['rating'] as num?)?.toDouble() ?? 0.0)
              .where((r) => r > 0);
          if (ratings.isNotEmpty) {
            avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
          }
        }

        final data = doc.data();
        restaurants.add(
          OwnerRestaurantModel(
            id: doc.id,
            name: data['name'] as String? ?? '',
            address: data['address'] as String? ?? '',
            imageUrl: data['imageUrl'] as String?,
            menuItemCount: itemsSnapshot.docs.length,
            reviewCount: reviewsSnapshot.docs.length,
            rating: avgRating,
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
          ),
        );
      }

      return restaurants;
    } catch (e) {
      throw Exception('Failed to load owner restaurants: $e');
    }
  }

  @override
  Future<void> requestOwnerUpgrade(String userId) async {
    try {
      // Update user role to pendingOwner
      await firestore.collection('users').doc(userId).update({
        'role': 'pendingOwner',
        'upgradeRequestedAt': FieldValue.serverTimestamp(),
      });

      // Create upgrade request document
      await firestore.collection('owner_upgrade_requests').add({
        'userId': userId,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to request owner upgrade: $e');
    }
  }
}
