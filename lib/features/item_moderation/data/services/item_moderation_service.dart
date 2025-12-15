import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Client-side item moderation service
/// Replaces Cloud Functions: approveItem, rejectItem, reportItem
class ItemModerationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ItemModerationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Approve a pending item (admin only)
  /// Replaces: Cloud Function approveItem
  Future<void> approveItem(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Verify admin role
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final role = userDoc.data()?['role'] as String?;
    
    if (role != 'admin') {
      throw Exception('Only admins can approve items');
    }

    await _firestore.collection('items').doc(itemId).update({
      'status': 'approved',
      'approvedBy': user.uid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reject a pending item (admin only)
  /// Replaces: Cloud Function rejectItem
  Future<void> rejectItem(String itemId, {String? reason}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Verify admin role
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final role = userDoc.data()?['role'] as String?;
    
    if (role != 'admin') {
      throw Exception('Only admins can reject items');
    }

    final updateData = {
      'status': 'rejected',
      'rejectedBy': user.uid,
      'rejectedAt': FieldValue.serverTimestamp(),
    };

    if (reason != null) {
      updateData['rejectionReason'] = reason;
    }

    await _firestore.collection('items').doc(itemId).update(updateData);
  }

  /// Report an item (any authenticated user)
  /// Replaces: Cloud Function reportItem
  Future<void> reportItem({
    required String itemId,
    required String reason,
    String? details,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final validReasons = [
      'wrong_price',
      'spam',
      'inappropriate',
      'duplicate',
      'other',
    ];

    if (!validReasons.contains(reason)) {
      throw Exception('Invalid report reason');
    }

    // Check if user already reported this item
    final existingReport = await _firestore
        .collection('item_reports')
        .where('itemId', isEqualTo: itemId)
        .where('reportedBy', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (existingReport.docs.isNotEmpty) {
      throw Exception('You have already reported this item');
    }

    // Use transaction for atomic operations
    await _firestore.runTransaction((transaction) async {
      final itemRef = _firestore.collection('items').doc(itemId);
      final itemSnap = await transaction.get(itemRef);

      if (!itemSnap.exists) {
        throw Exception('Item not found');
      }

      final currentReportCount = (itemSnap.data()?['reportCount'] as int?) ?? 0;

      // Increment report count
      transaction.update(itemRef, {
        'reportCount': FieldValue.increment(1),
      });

      // Create report document
      final reportRef = _firestore.collection('item_reports').doc();
      transaction.set(reportRef, {
        'itemId': itemId,
        'reportedBy': user.uid,
        'reason': reason,
        'details': details ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Auto-flag if report count exceeds threshold
      if (currentReportCount + 1 >= 3) {
        transaction.update(itemRef, {
          'status': 'flagged',
        });
      }
    });
  }
}