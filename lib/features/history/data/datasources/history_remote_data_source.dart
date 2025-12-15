import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/error.dart';
import '../../domain/entities/history_entry.dart';
import '../models/history_entry_model.dart';

/// Abstract history remote data source
abstract class HistoryRemoteDataSource {
  /// Get user's history
  Future<List<HistoryEntryModel>> getUserHistory(
    String userId, {
    int limit = 50,
  });

  /// Get history by type
  Future<List<HistoryEntryModel>> getUserHistoryByType(
    String userId,
    HistoryType type, {
    int limit = 50,
  });

  /// Add a history entry
  Future<void> addHistory(HistoryEntryModel entry);

  /// Delete specific history entry
  Future<void> deleteHistory(String historyId);

  /// Clear all user history
  Future<void> clearUserHistory(String userId);

  /// Get history count
  Future<int> getHistoryCount(String userId);
}

/// Firestore implementation of history remote data source
class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final String _collection = 'user_history';

  HistoryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<HistoryEntryModel>> getUserHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => HistoryEntryModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to get user history: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<HistoryEntryModel>> getUserHistoryByType(
    String userId,
    HistoryType type, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => HistoryEntryModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to get history by type: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> addHistory(HistoryEntryModel entry) async {
    try {
      await firestore.collection(_collection).add(entry.toFirestore());
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to add history: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteHistory(String historyId) async {
    try {
      await firestore.collection(_collection).doc(historyId).delete();
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to delete history: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearUserHistory(String userId) async {
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
        'Failed to clear history: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> getHistoryCount(String userId) async {
    try {
      final snapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to get history count: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }
}
