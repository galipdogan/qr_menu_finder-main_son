import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart';
import 'cache_service.dart';

/// Generic Firebase Firestore cache manager
/// TR: Generic Firebase Firestore önbellek yöneticisi
/// 
/// Provides persistent caching using Firestore with automatic serialization
/// Firestore kullanarak otomatik serialization ile kalıcı önbellekleme sağlar
class FirebaseCacheManager<T> implements CacheService<T> {
  final FirebaseFirestore _firestore;
  final String _collectionName;
  final T Function(DocumentSnapshot doc) _fromFirestore;
  final Map<String, dynamic> Function(T item) _toFirestore;

  FirebaseCacheManager({
    required FirebaseFirestore firestore,
    required String collectionName,
    required T Function(DocumentSnapshot doc) fromFirestore,
    required Map<String, dynamic> Function(T item) toFirestore,
  })  : _firestore = firestore,
        _collectionName = collectionName,
        _fromFirestore = fromFirestore,
        _toFirestore = toFirestore;

  @override
  Future<T?> get(String key) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(key).get();

      if (!doc.exists) {
        AppLogger.d('No cached data in Firestore for key: $key');
        return null;
      }

      AppLogger.d('Retrieved cached data from Firestore for key: $key');
      return _fromFirestore(doc);
    } catch (e) {
      AppLogger.e('Failed to get cached data from Firestore for key: $key', error: e);
      return null;
    }
  }

  @override
  Future<void> set(String key, T value, {Duration? ttl}) async {
    try {
      final data = _toFirestore(value);
      
      // Add expiry if TTL is provided
      if (ttl != null) {
        final expiryTime = DateTime.now().add(ttl);
        data['_cacheExpiry'] = Timestamp.fromDate(expiryTime);
      }

      await _firestore
          .collection(_collectionName)
          .doc(key)
          .set(data, SetOptions(merge: true));

      AppLogger.d('Cached data to Firestore for key: $key');
    } catch (e) {
      AppLogger.e('Failed to cache data to Firestore for key: $key', error: e);
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _firestore.collection(_collectionName).doc(key).delete();
      AppLogger.d('Removed cached data from Firestore for key: $key');
    } catch (e) {
      AppLogger.e('Failed to remove cached data from Firestore for key: $key', error: e);
    }
  }

  @override
  Future<void> clear() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection(_collectionName).get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      AppLogger.d('Cleared all cached data from Firestore collection: $_collectionName');
    } catch (e) {
      AppLogger.e('Failed to clear Firestore cache for collection: $_collectionName', error: e);
    }
  }

  /// Check if data is cached and valid (considering TTL if present)
  Future<bool> isCached(String key) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(key).get();

      if (!doc.exists) return false;

      // Check TTL if present
      final data = doc.data();
      if (data != null && data['_cacheExpiry'] != null) {
        final expiry = (data['_cacheExpiry'] as Timestamp).toDate();
        if (DateTime.now().isAfter(expiry)) {
          // Expired, remove it
          await remove(key);
          return false;
        }
      }

      return true;
    } catch (e) {
      AppLogger.e('Failed to check if data is cached for key: $key', error: e);
      return false;
    }
  }

  /// Get multiple items by keys (batch operation)
  Future<List<T>> getMultiple(List<String> keys) async {
    try {
      if (keys.isEmpty) return [];

      final results = <T>[];
      
      // Firestore 'in' query limit is 10, so batch them
      final batches = <List<String>>[];
      for (int i = 0; i < keys.length; i += 10) {
        batches.add(keys.skip(i).take(10).toList());
      }

      for (final batch in batches) {
        final snapshot = await _firestore
            .collection(_collectionName)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in snapshot.docs) {
          try {
            results.add(_fromFirestore(doc));
          } catch (e) {
            AppLogger.w('Failed to deserialize cached item: ${doc.id}', error: e);
          }
        }
      }

      AppLogger.d('Retrieved ${results.length} cached items from Firestore');
      return results;
    } catch (e) {
      AppLogger.e('Failed to get multiple cached items from Firestore', error: e);
      return [];
    }
  }

  /// Set multiple items (batch operation)
  Future<void> setMultiple(Map<String, T> items, {Duration? ttl}) async {
    try {
      if (items.isEmpty) return;

      final batch = _firestore.batch();
      final expiryTime = ttl != null ? DateTime.now().add(ttl) : null;

      for (final entry in items.entries) {
        final data = _toFirestore(entry.value);
        
        if (expiryTime != null) {
          data['_cacheExpiry'] = Timestamp.fromDate(expiryTime);
        }

        final docRef = _firestore.collection(_collectionName).doc(entry.key);
        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      AppLogger.d('Cached ${items.length} items to Firestore');
    } catch (e) {
      AppLogger.e('Failed to cache multiple items to Firestore', error: e);
    }
  }

  /// Clean expired cache entries
  Future<void> cleanExpired() async {
    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('_cacheExpiry', isLessThan: now)
          .get();

      if (snapshot.docs.isEmpty) {
        AppLogger.d('No expired cache entries found');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      AppLogger.d('Cleaned ${snapshot.docs.length} expired cache entries');
    } catch (e) {
      AppLogger.e('Failed to clean expired cache entries', error: e);
    }
  }
}
