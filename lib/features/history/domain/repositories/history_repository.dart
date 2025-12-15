import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/history_entry.dart';

/// History repository interface for clean architecture
abstract class HistoryRepository {
  /// Get user's history
  Future<Either<Failure, List<HistoryEntry>>> getUserHistory(
    String userId, {
    int limit = 50,
  });

  /// Get history by type
  Future<Either<Failure, List<HistoryEntry>>> getUserHistoryByType(
    String userId,
    HistoryType type, {
    int limit = 50,
  });

  /// Add a history entry
  Future<Either<Failure, void>> addHistory(HistoryEntry entry);

  /// Delete specific history entry
  Future<Either<Failure, void>> deleteHistory(String historyId);

  /// Clear all user history
  Future<Either<Failure, void>> clearUserHistory(String userId);

  /// Get history count
  Future<Either<Failure, int>> getHistoryCount(String userId);

  /// Track restaurant view (convenience method)
  Future<Either<Failure, void>> trackRestaurantView({
    required String userId,
    required String restaurantId,
    required String restaurantName,
  });

  /// Track item view (convenience method)
  Future<Either<Failure, void>> trackItemView({
    required String userId,
    required String itemId,
    required String itemName,
    String? restaurantId,
    String? restaurantName,
  });

  /// Track search (convenience method)
  Future<Either<Failure, void>> trackSearch({
    required String userId,
    required String searchQuery,
  });
}
