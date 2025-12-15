import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/error.dart';
import '../models/menu_item_model.dart';
import '../cache/menu_cache_service.dart';
import 'menu_firestore_queries.dart';
import 'menu_remote_data_source.dart';

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final FirebaseFirestore firestore;
  final MenuCacheService cache;
  final MenuFirestoreQueries queries;

  MenuRemoteDataSourceImpl({required this.firestore, required this.cache})
    : queries = MenuFirestoreQueries(firestore);

  @override
  Future<List<MenuItemModel>> getMenuItemsByRestaurantId({
    required String restaurantId,
    String? category,
    int limit = 50,
  }) async {
    final key = '${restaurantId}_${category ?? 'all'}_$limit';
    final cached = cache.get(key);
    if (cached != null) return cached;

    Query q = queries.itemsByRestaurant(restaurantId, limit);
    if (category != null) q = q.where('category', isEqualTo: category);

    var snapshot = await q.get(const GetOptions(source: Source.cache));
    if (snapshot.docs.isEmpty) {
      snapshot = await q.get(const GetOptions(source: Source.server));
    }

    final items = snapshot.docs
        .map((doc) => MenuItemModel.fromFirestore(doc))
        .toList();

    cache.set(key, items);
    return items;
  }

  @override
  Future<MenuItemModel> getMenuItemById(String id) async {
    try {
      var doc = await firestore
          .collection('items')
          .doc(id)
          .get(const GetOptions(source: Source.cache));

      if (!doc.exists) {
        doc = await firestore
            .collection('items')
            .doc(id)
            .get(const GetOptions(source: Source.server));
      }

      if (!doc.exists) {
        throw const NotFoundException('Menu item not found');
      }

      return MenuItemModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get menu item: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> searchMenuItems({
    required String query,
    String? restaurantId,
    String? category,
    int limit = 20,
  }) async {
    try {
      Query q = firestore
          .collection('items')
          .where('searchableText', isGreaterThanOrEqualTo: query.toLowerCase())
          .where(
            'searchableText',
            isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff',
          )
          .where('status', isEqualTo: 'approved')
          .limit(limit);

      if (restaurantId != null) {
        q = q.where('restaurantId', isEqualTo: restaurantId);
      }

      if (category != null) {
        q = q.where('category', isEqualTo: category);
      }

      final snapshot = await q.get();
      return snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to search menu items: $e');
    }
  }

  // @override
  // Future<void> addMenuLink({
  //   required String restaurantId,
  //   required String url,
  //   required String type,
  // }) async {
  //   try {
  //     await firestore.collection('restaurants').doc(restaurantId).update({
  //       'menuLinks': FieldValue.arrayUnion([
  //         {'url': url, 'type': type, 'addedAt': DateTime.now()},
  //       ]),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     throw ServerException('Failed to add menu link: $e');
  //   }
  // }

  @override
  Future<void> addMenuLink({
    required String restaurantId,
    required String url,
    required String type, // "photo" | "url"
  }) async {
    try {
      // ✅ 1) Duplicate kontrolü
      final existing = await firestore
          .collection('items')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('type', isEqualTo: 'link')
          .where('url', isEqualTo: url)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Bu link zaten eklenmiş
        return;
      }

      // ✅ 2) Yeni link item oluştur
      await firestore.collection('items').add({
        'restaurantId': restaurantId,
        'type': 'link',
        'url': url,
        'source': 'manual_link',
        'status': 'pending',
        'name': 'Menu Link', // UI için placeholder
        'category': 'Menu',
        'price': 0,
        'imageUrls': [],
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to add menu link: $e');
    }
  }

  @override
  Future<void> deleteMenuItem(String id) async {
    try {
      await firestore.collection('items').doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete menu item: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> getPopularMenuItems({int limit = 10}) async {
    try {
      final snapshot = await firestore
          .collection('items')
          .where('status', isEqualTo: 'approved')
          .orderBy('reviewCount', descending: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get popular items: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByCategory({
    required String category,
    int limit = 20,
  }) async {
    try {
      final snapshot = await queries.itemsByCategory(category, limit).get();
      return snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get items by category: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByContributor({
    required String contributorId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await queries
          .itemsByContributor(contributorId, limit)
          .get();

      return snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get items by contributor: $e');
    }
  }

  @override
  Future<MenuItemModel> createMenuItem(MenuItemModel menuItem) async {
    try {
      final docRef = firestore.collection('items').doc();
      final itemWithId = menuItem.copyWith(id: docRef.id);

      await docRef.set(itemWithId.toFirestore());

      return itemWithId;
    } catch (e) {
      throw ServerException('Failed to create menu item: $e');
    }
  }

  @override
  Future<MenuItemModel> updateMenuItem(MenuItemModel menuItem) async {
    try {
      await firestore
          .collection('items')
          .doc(menuItem.id)
          .update(menuItem.toFirestore());

      return menuItem;
    } catch (e) {
      throw ServerException('Failed to update menu item: $e');
    }
  }

  @override
  Future<void> createOcrItem({
    required String restaurantId,
    required double price,
    required String? currency,
  }) async {
    await firestore.collection('items').add({
      'restaurantId': restaurantId,
      'type': 'ocr_item',
      'price': price,
      'currency': currency ?? 'TRY',
      'category': 'Menu',
      'source': 'ocr_from_link',
      'status': 'approved',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markLinkAsProcessed(String linkItemId) async {
    await firestore.collection('items').doc(linkItemId).update({
      'status': 'processed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
