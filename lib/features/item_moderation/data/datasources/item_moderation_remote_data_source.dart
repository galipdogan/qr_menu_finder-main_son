import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/item_promotion_params.dart';
import '../../domain/entities/item_report_params.dart';

/// Abstract remote data source for item moderation
/// TR: Item moderasyon için soyut uzak veri kaynağı
abstract class ItemModerationRemoteDataSource {
  Future<void> promoteToLive(ItemPromotionParams params);
  Future<void> approveItem(String itemId);
  Future<void> rejectItem(String itemId, {String? reason});
  Future<void> reportItem(ItemReportParams params);
}

/// Firestore implementation of item moderation remote data source
/// TR: Item moderasyon uzak veri kaynağının Firestore implementasyonu
/// 
/// This replaces all Cloud Functions with direct Firestore operations
/// Bu, tüm Cloud Functions'ları doğrudan Firestore işlemleriyle değiştirir
class ItemModerationRemoteDataSourceImpl
    implements ItemModerationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ItemModerationRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Future<void> promoteToLive(ItemPromotionParams params) async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null) {
        throw AuthenticationException('User not authenticated');
      }

      // Check idempotency / İdempotency kontrolü
      if (params.idempotencyKey != null) {
        final idemDoc = await firestore
            .collection('idempotency')
            .doc(params.idempotencyKey)
            .get();

        if (idemDoc.exists) {
          // Already processed / Zaten işlenmiş
          return;
        }

        // Set idempotency record / İdempotency kaydı oluştur
        await firestore.collection('idempotency').doc(params.idempotencyKey).set({
          'uid': uid,
          'stagingId': params.stagingId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Get staging item / Staging item'ı al
      final stagingDoc = await firestore
          .collection('items_staging')
          .doc(params.stagingId)
          .get();

      if (!stagingDoc.exists) {
        throw NotFoundException('Staging item not found');
      }

      final stagingData = stagingDoc.data()!;

      // Get restaurant data / Restoran verisini al
      final restaurantDoc = await firestore
          .collection('restaurants')
          .doc(params.restaurantId)
          .get();

      if (!restaurantDoc.exists) {
        throw NotFoundException('Restaurant not found');
      }

      final restaurant = restaurantDoc.data()!;

      // Prepare item data / Item verisini hazırla
      final finalName = params.updatedName ?? stagingData['name'];
      final finalPrice = params.updatedPrice ?? stagingData['price'];
      final finalCurrency =
          params.updatedCurrency ?? stagingData['currency'] ?? 'TRY';

      // Validate / Doğrula
      if (finalName == null || finalName.isEmpty) {
        throw ValidationException('Item name is required');
      }
      if (finalPrice == null || finalPrice <= 0) {
        throw ValidationException('Item price must be greater than 0');
      }

      final itemData = {
        'name': finalName,
        'price': finalPrice,
        'currency': finalCurrency,
        'restaurantId': params.restaurantId,
        'menuId': params.restaurantId,
        'restaurantName': restaurant['name'] ?? 'Unknown Restaurant',
        'city': restaurant['city'] ?? '',
        'district': restaurant['district'] ?? '',
        'searchableText':
            '$finalName ${restaurant['name']} ${restaurant['city']} ${restaurant['district']}'
                .toLowerCase(),
        'contributedBy': uid,
        'status': 'pending', // Requires admin approval / Admin onayı gerektirir
        'reportCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'previousPrices': stagingData['previousPrices'] ?? [],
      };

      // Use batch for atomicity / Atomiklik için batch kullan
      final batch = firestore.batch();

      // Create or update item / Item oluştur veya güncelle
      final itemRef = params.itemId != null
          ? firestore.collection('items').doc(params.itemId)
          : firestore.collection('items').doc();

      batch.set(itemRef, itemData, SetOptions(merge: true));

      // Update restaurant lastSyncedAt / Restoranın lastSyncedAt'ini güncelle
      batch.update(
        firestore.collection('restaurants').doc(params.restaurantId),
        {'lastSyncedAt': FieldValue.serverTimestamp()},
      );

      // Delete staging item / Staging item'ı sil
      batch.delete(stagingDoc.reference);

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}', code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Failed to promote item: $e');
    }
  }

  @override
  Future<void> approveItem(String itemId) async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null) {
        throw AuthenticationException('User not authenticated');
      }

      // Check if user is admin / Kullanıcının admin olup olmadığını kontrol et
      final userDoc = await firestore.collection('users').doc(uid).get();
      final isAdmin = userDoc.data()?['role'] == 'admin';

      if (!isAdmin) {
        throw PermissionDeniedException('Only admins can approve items');
      }

      // Update item status / Item durumunu güncelle
      await firestore.collection('items').doc(itemId).update({
        'status': 'approved',
        'approvedBy': uid,
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Note: Algolia indexing will be handled in repository layer
      // Not: Algolia indeksleme repository katmanında yapılacak
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}', code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Failed to approve item: $e');
    }
  }

  @override
  Future<void> rejectItem(String itemId, {String? reason}) async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null) {
        throw AuthenticationException('User not authenticated');
      }

      // Check if user is admin / Kullanıcının admin olup olmadığını kontrol et
      final userDoc = await firestore.collection('users').doc(uid).get();
      final isAdmin = userDoc.data()?['role'] == 'admin';

      if (!isAdmin) {
        throw PermissionDeniedException('Only admins can reject items');
      }

      // Update item status / Item durumunu güncelle
      final updateData = {
        'status': 'rejected',
        'rejectedBy': uid,
        'rejectedAt': FieldValue.serverTimestamp(),
      };

      if (reason != null) {
        updateData['rejectionReason'] = reason;
      }

      await firestore.collection('items').doc(itemId).update(updateData);

      // Note: Algolia removal will be handled in repository layer
      // Not: Algolia'dan kaldırma repository katmanında yapılacak
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}', code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Failed to reject item: $e');
    }
  }

  @override
  Future<void> reportItem(ItemReportParams params) async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null) {
        throw AuthenticationException('User not authenticated');
      }

      // Check if user already reported this item
      // Kullanıcının bu item'ı daha önce raporlayıp raporlamadığını kontrol et
      final existingReport = await firestore
          .collection('item_reports')
          .where('itemId', isEqualTo: params.itemId)
          .where('reportedBy', isEqualTo: uid)
          .limit(1)
          .get();

      if (existingReport.docs.isNotEmpty) {
        throw ValidationException('You have already reported this item');
      }

      // Use transaction for atomicity / Atomiklik için transaction kullan
      await firestore.runTransaction((transaction) async {
        final itemRef = firestore.collection('items').doc(params.itemId);
        final itemDoc = await transaction.get(itemRef);

        if (!itemDoc.exists) {
          throw NotFoundException('Item not found');
        }

        final currentReportCount = itemDoc.data()?['reportCount'] ?? 0;

        // Increment report count / Rapor sayısını artır
        transaction.update(itemRef, {
          'reportCount': FieldValue.increment(1),
        });

        // Create report document / Rapor belgesi oluştur
        final reportRef = firestore.collection('item_reports').doc();
        transaction.set(reportRef, {
          'itemId': params.itemId,
          'reportedBy': uid,
          'reason': params.reason,
          'details': params.details ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Auto-flag if report count exceeds threshold
        // Rapor sayısı eşiği aşarsa otomatik olarak işaretle
        if (currentReportCount + 1 >= 3) {
          transaction.update(itemRef, {
            'status': 'flagged',
          });
        }
      });
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}', code: e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Failed to report item: $e');
    }
  }
}
