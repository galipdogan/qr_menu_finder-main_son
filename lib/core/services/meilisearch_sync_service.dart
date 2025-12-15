import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/meilisearch_config.dart';
import '../utils/app_logger.dart';
import '../../features/search/data/datasources/meilisearch_remote_data_source.dart';

/// Service to sync Firestore data with MeiliSearch
class MeiliSearchSyncService {
  final FirebaseFirestore firestore;
  final MeiliSearchRemoteDataSource meilisearchDataSource;

  MeiliSearchSyncService({
    required this.firestore,
    required this.meilisearchDataSource,
  });

  /// Initialize MeiliSearch indexes with proper settings
  Future<void> initializeIndexes() async {
    if (!MeiliSearchConfig.isEnabled) {
      AppLogger.i('MeiliSearch is disabled, skipping index initialization');
      return;
    }

    try {
      AppLogger.i('Initializing MeiliSearch indexes...');

      // Update restaurants index settings
      await meilisearchDataSource.updateIndexSettings(
        MeiliSearchRemoteDataSourceImpl.restaurantsIndex,
        MeiliSearchConfig.restaurantsIndexSettings,
      );

      // Update menu items index settings
      await meilisearchDataSource.updateIndexSettings(
        MeiliSearchRemoteDataSourceImpl.menuItemsIndex,
        MeiliSearchConfig.menuItemsIndexSettings,
      );

      AppLogger.i('MeiliSearch indexes initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to initialize MeiliSearch indexes',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sync all restaurants from Firestore to MeiliSearch
  Future<void> syncAllRestaurants() async {
    if (!MeiliSearchConfig.isEnabled) {
      AppLogger.i('MeiliSearch is disabled, skipping restaurant sync');
      return;
    }

    try {
      AppLogger.i('Syncing restaurants to MeiliSearch...');

      final snapshot = await firestore
          .collection('restaurants')
          .where('isActive', isEqualTo: true)
          .get();

      int synced = 0;
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;

          await meilisearchDataSource.indexDocument(
            MeiliSearchRemoteDataSourceImpl.restaurantsIndex,
            data,
          );
          synced++;
        } catch (e) {
          AppLogger.e('Failed to sync restaurant ${doc.id}', error: e);
        }
      }

      AppLogger.i(
        'Synced $synced/${snapshot.docs.length} restaurants to MeiliSearch',
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to sync restaurants',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sync all menu items from Firestore to MeiliSearch
  Future<void> syncAllMenuItems() async {
    if (!MeiliSearchConfig.isEnabled) {
      AppLogger.i('MeiliSearch is disabled, skipping menu items sync');
      return;
    }

    try {
      AppLogger.i('Syncing menu items to MeiliSearch...');

      final snapshot = await firestore.collection('menuItems').get();

      int synced = 0;
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;

          await meilisearchDataSource.indexDocument(
            MeiliSearchRemoteDataSourceImpl.menuItemsIndex,
            data,
          );
          synced++;
        } catch (e) {
          AppLogger.e('Failed to sync menu item ${doc.id}', error: e);
        }
      }

      AppLogger.i(
        'Synced $synced/${snapshot.docs.length} menu items to MeiliSearch',
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to sync menu items',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sync a single restaurant to MeiliSearch
  Future<void> syncRestaurant(String restaurantId) async {
    if (!MeiliSearchConfig.isEnabled) return;

    try {
      final doc = await firestore
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      if (!doc.exists) {
        // Delete from MeiliSearch if doesn't exist in Firestore
        await meilisearchDataSource.deleteDocument(
          MeiliSearchRemoteDataSourceImpl.restaurantsIndex,
          restaurantId,
        );
        return;
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      await meilisearchDataSource.indexDocument(
        MeiliSearchRemoteDataSourceImpl.restaurantsIndex,
        data,
      );

      AppLogger.i('Synced restaurant $restaurantId to MeiliSearch');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to sync restaurant $restaurantId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sync a single menu item to MeiliSearch
  Future<void> syncMenuItem(String menuItemId) async {
    if (!MeiliSearchConfig.isEnabled) return;

    try {
      final doc = await firestore.collection('menuItems').doc(menuItemId).get();

      if (!doc.exists) {
        // Delete from MeiliSearch if doesn't exist in Firestore
        await meilisearchDataSource.deleteDocument(
          MeiliSearchRemoteDataSourceImpl.menuItemsIndex,
          menuItemId,
        );
        return;
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      await meilisearchDataSource.indexDocument(
        MeiliSearchRemoteDataSourceImpl.menuItemsIndex,
        data,
      );

      AppLogger.i('Synced menu item $menuItemId to MeiliSearch');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to sync menu item $menuItemId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete a restaurant from MeiliSearch
  Future<void> deleteRestaurant(String restaurantId) async {
    if (!MeiliSearchConfig.isEnabled) return;

    try {
      await meilisearchDataSource.deleteDocument(
        MeiliSearchRemoteDataSourceImpl.restaurantsIndex,
        restaurantId,
      );
      AppLogger.i('Deleted restaurant $restaurantId from MeiliSearch');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to delete restaurant $restaurantId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete a menu item from MeiliSearch
  Future<void> deleteMenuItem(String menuItemId) async {
    if (!MeiliSearchConfig.isEnabled) return;

    try {
      await meilisearchDataSource.deleteDocument(
        MeiliSearchRemoteDataSourceImpl.menuItemsIndex,
        menuItemId,
      );
      AppLogger.i('Deleted menu item $menuItemId from MeiliSearch');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to delete menu item $menuItemId',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Perform full sync (initialize + sync all data)
  Future<void> performFullSync() async {
    if (!MeiliSearchConfig.isEnabled) {
      AppLogger.i('MeiliSearch is disabled, skipping full sync');
      return;
    }

    AppLogger.i('Starting full MeiliSearch sync...');

    await initializeIndexes();
    await syncAllRestaurants();
    await syncAllMenuItems();

    AppLogger.i('Full MeiliSearch sync completed');
  }
}
