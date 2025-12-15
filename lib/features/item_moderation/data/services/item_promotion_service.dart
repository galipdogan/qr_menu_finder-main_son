import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/app_logger.dart';

/// Service for promoting staging items to live items collection
/// Replaces the promoteToLive Cloud Function
///
/// Staging item'ları live items koleksiyonuna taşıma servisi
/// promoteToLive Cloud Function'ının yerine geçer
class ItemPromotionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Promote a staging item to live items collection
  ///
  /// Bir staging item'ı live items koleksiyonuna taşır
  ///
  /// Parameters:
  /// - [stagingId]: ID of the staging item / Staging item'ın ID'si
  /// - [restaurantId]: ID of the restaurant / Restoran ID'si
  /// - [itemId]: Optional existing item ID to update / Güncellenecek mevcut item ID'si (opsiyonel)
  /// - [updatedName]: Optional updated name / Güncellenmiş isim (opsiyonel)
  /// - [updatedPrice]: Optional updated price / Güncellenmiş fiyat (opsiyonel)
  /// - [updatedCurrency]: Optional updated currency / Güncellenmiş para birimi (opsiyonel)
  Future<Map<String, dynamic>> promoteToLive({
    required String stagingId,
    required String restaurantId,
    String? itemId,
    String? updatedName,
    double? updatedPrice,
    String? updatedCurrency,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not authenticated / Kullanıcı doğrulanmamış');
      }

      AppLogger.i('🔄 Promoting staging item: $stagingId');

      // Get staging item / Staging item'ı al
      final stagingDoc = await _firestore
          .collection('items_staging')
          .doc(stagingId)
          .get();

      if (!stagingDoc.exists) {
        throw Exception('Staging item not found / Staging item bulunamadı');
      }

      final stagingData = stagingDoc.data()!;
      AppLogger.d('📋 Staging data: $stagingData');

      // Get restaurant data for denormalization / Denormalizasyon için restoran verisini al
      final restaurantDoc = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      if (!restaurantDoc.exists) {
        throw Exception('Restaurant not found / Restoran bulunamadı');
      }

      final restaurant = restaurantDoc.data()!;
      AppLogger.d('🏪 Restaurant: ${restaurant['name']}');

      // Prepare item data / Item verisini hazırla
      final finalName = updatedName ?? stagingData['name'];
      final finalPrice = updatedPrice ?? stagingData['price'];
      final finalCurrency = updatedCurrency ?? stagingData['currency'] ?? 'TRY';

      // Validate required data / Gerekli verileri doğrula
      if (finalName == null || finalName.isEmpty) {
        throw Exception('Item name is required / Item ismi gerekli');
      }
      if (finalPrice == null || finalPrice <= 0) {
        throw Exception('Valid price is required / Geçerli fiyat gerekli');
      }

      // Create searchable text for Firestore queries
      // Firestore sorguları için aranabilir metin oluştur
      final searchableText =
          '$finalName ${restaurant['name'] ?? ''} '
                  '${restaurant['city'] ?? ''} ${restaurant['district'] ?? ''}'
              .toLowerCase();

      final itemData = {
        'name': finalName,
        'price': finalPrice,
        'currency': finalCurrency,
        'restaurantId': restaurantId,
        'menuId': restaurantId, // Using restaurantId as menuId
        'restaurantName': restaurant['name'] ?? 'Unknown Restaurant',
        'city': restaurant['city'] ?? '',
        'district': restaurant['district'] ?? '',
        'searchableText': searchableText,
        'contributedBy': uid,
        'status': 'pending', // Requires admin approval / Admin onayı gerektirir
        'reportCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Use batch write for atomicity / Atomiklik için batch write kullan
      final batch = _firestore.batch();

      // Create or update item / Item oluştur veya güncelle
      final itemRef = itemId != null
          ? _firestore.collection('items').doc(itemId)
          : _firestore.collection('items').doc();

      if (itemId != null) {
        // Update existing item / Mevcut item'ı güncelle
        final existingDoc = await itemRef.get();
        if (existingDoc.exists) {
          final existingData = existingDoc.data()!;
          final prevPrices = List<Map<String, dynamic>>.from(
            existingData['previousPrices'] ?? [],
          );

          // If price changed, append to history / Fiyat değiştiyse geçmişe ekle
          if (existingData['price'] != null &&
              existingData['price'] != finalPrice) {
            prevPrices.add({
              'price': existingData['price'],
              'date': existingData['updatedAt'] ?? FieldValue.serverTimestamp(),
            });
          }

          batch.update(itemRef, {
            ...itemData,
            'previousPrices': prevPrices.take(50).toList(), // Keep last 50
            'createdAt': existingData['createdAt'], // Preserve creation date
          });
        } else {
          // Item doesn't exist, create new / Item yoksa yeni oluştur
          batch.set(itemRef, {
            ...itemData,
            'createdAt': FieldValue.serverTimestamp(),
            'previousPrices': [],
          });
        }
      } else {
        // Create new item / Yeni item oluştur
        batch.set(itemRef, {
          ...itemData,
          'createdAt': FieldValue.serverTimestamp(),
          'previousPrices': stagingData['previousPrices'] ?? [],
        });
      }

      // Update restaurant lastSyncedAt / Restoran lastSyncedAt'i güncelle
      batch.update(_firestore.collection('restaurants').doc(restaurantId), {
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });

      // Delete staging item / Staging item'ı sil
      batch.delete(stagingDoc.reference);

      // Commit batch / Batch'i commit et
      await batch.commit();

      AppLogger.i('✅ Successfully promoted item: ${itemRef.id}');

      return {'success': true, 'itemId': itemRef.id};
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error promoting item', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Promote multiple staging items at once
  ///
  /// Birden fazla staging item'ı aynı anda taşır
  Future<Map<String, dynamic>> promoteMultiple({
    required List<String> stagingIds,
    required String restaurantId,
  }) async {
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final stagingId in stagingIds) {
      try {
        await promoteToLive(stagingId: stagingId, restaurantId: restaurantId);
        successCount++;
      } catch (e) {
        failureCount++;
        errors.add('$stagingId: ${e.toString()}');
        AppLogger.e('Failed to promote $stagingId', error: e);
      }
    }

    return {
      'success': failureCount == 0,
      'successCount': successCount,
      'failureCount': failureCount,
      'errors': errors,
    };
  }
}
