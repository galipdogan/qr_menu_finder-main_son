import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/favorite_item.dart';
import '../models/favorite_item_model.dart';

/// Abstract favorites remote data source
abstract class FavoritesRemoteDataSource {
  /// Get user's favorites
  Future<List<FavoriteItemModel>> getUserFavorites(
    String userId, {
    FavoriteType? type,
  });

  /// Add item to favorites
  Future<void> addFavorite({
    required String userId,
    required String itemId,
    required FavoriteType type,
  });

  /// Remove item from favorites
  Future<void> removeFavorite(String favoriteId);

  /// Check if item is favorited
  Future<bool> isFavorite({
    required String userId,
    required String itemId,
  });

  /// Get favorite IDs (legacy support)
  Future<List<String>> getFavoriteIds(String userId);

  /// Clear all user favorites
  Future<void> clearUserFavorites(String userId);
}

/// Firestore implementation of favorites remote data source
class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final FirebaseFirestore firestore;
  final String _collection = 'favorites';

  FavoritesRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<FavoriteItemModel>> getUserFavorites(
    String userId, {
    FavoriteType? type,
  }) async {
    try {
      AppLogger.d('getUserFavorites: userId=$userId, type=$type');
      
      Query query = firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId);

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query.get();
      AppLogger.d('Found ${snapshot.docs.length} favorites in Firestore');

      // Sort by createdAt in memory instead of Firestore query
      final favorites = snapshot.docs
          .map((doc) {
            AppLogger.d('Favorite doc: ${doc.id} - ${doc.data()}');
            return FavoriteItemModel.fromFirestore(doc);
          })
          .toList();

      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      AppLogger.i('Returning ${favorites.length} favorites');
      return favorites;
    } catch (e, stackTrace) {
      AppLogger.e('getUserFavorites error', error: e, stackTrace: stackTrace);
      throw ServerException(
        'Failed to get user favorites: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> addFavorite({
    required String userId,
    required String itemId,
    required FavoriteType type,
  }) async {
    try {
      AppLogger.d('addFavorite: userId=$userId, itemId=$itemId, type=$type');
      
      // Check if already exists
      final existing = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .get();

      AppLogger.d('Existing favorites: ${existing.docs.length}');

      if (existing.docs.isNotEmpty) {
        // Already favorited, no need to add again
        AppLogger.w('Already favorited, skipping');
        return;
      }

      // Add new favorite
      final favorite = FavoriteItemModel(
        id: '', // Firestore will generate
        userId: userId,
        itemId: itemId,
        type: type,
        createdAt: DateTime.now(),
      );

      AppLogger.d('Adding favorite to Firestore: ${favorite.toFirestore()}');
      AppLogger.d('Collection name: $_collection');
      AppLogger.d('Firestore instance: ${firestore.hashCode}');
      
      try {
        AppLogger.d('Calling firestore.collection($_collection).add()...');
        final docRef = await firestore
            .collection(_collection)
            .add(favorite.toFirestore())
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                AppLogger.e('❌ Firestore add() TIMEOUT after 15 seconds');
                throw TimeoutException('Firestore add operation timed out');
              },
            );
        AppLogger.i('✅ Favorite added with ID: ${docRef.id}');
      } catch (writeError) {
        AppLogger.e('❌ Firestore write failed', error: writeError);
        AppLogger.e('Error type: ${writeError.runtimeType}');
        AppLogger.e('Error details: ${writeError.toString()}');
        
        // Try to get more details
        if (writeError.toString().contains('permission')) {
          AppLogger.e('⚠️ PERMISSION DENIED - Check Firestore rules!');
        } else if (writeError.toString().contains('network')) {
          AppLogger.e('⚠️ NETWORK ERROR - Check internet connection!');
        } else if (writeError is TimeoutException) {
          AppLogger.e('⚠️ TIMEOUT - Firestore is not responding!');
        }
        rethrow;
      }
    } catch (e, stackTrace) {
      AppLogger.e('addFavorite error', error: e, stackTrace: stackTrace);
      throw ServerException(
        'Failed to add favorite: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> removeFavorite(String favoriteId) async {
    try {
      await firestore.collection(_collection).doc(favoriteId).delete();
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to remove favorite: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isFavorite({
    required String userId,
    required String itemId,
  }) async {
    try {
      AppLogger.d('isFavorite: userId=$userId, itemId=$itemId');
      
      final snapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .limit(1)
          .get();

      final result = snapshot.docs.isNotEmpty;
      AppLogger.d('isFavorite result: $result (${snapshot.docs.length} docs)');
      
      return result;
    } catch (e, stackTrace) {
      AppLogger.e('isFavorite error', error: e, stackTrace: stackTrace);
      throw ServerException(
        'Failed to check favorite status: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<String>> getFavoriteIds(String userId) async {
    try {
      final snapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => (doc.data()['itemId'] as String?) ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to get favorite IDs: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearUserFavorites(String userId) async {
    try {
      final snapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to clear favorites: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }
}
