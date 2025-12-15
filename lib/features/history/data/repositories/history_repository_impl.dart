import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';
import '../models/history_entry_model.dart';

/// Implementation of history repository
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HistoryEntry>>> getUserHistory(
    String userId, {
    int limit = 50,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getUserHistory(userId, limit: limit),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<HistoryEntry>>> getUserHistoryByType(
    String userId,
    HistoryType type, {
    int limit = 50,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getUserHistoryByType(userId, type, limit: limit),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, void>> addHistory(HistoryEntry entry) async {
    return RepositoryHelper.executeVoid(() {
      final model = HistoryEntryModel.fromEntity(entry);
      return remoteDataSource.addHistory(model);
    });
  }

  @override
  Future<Either<Failure, void>> deleteHistory(String historyId) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.deleteHistory(historyId),
    );
  }

  @override
  Future<Either<Failure, void>> clearUserHistory(String userId) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.clearUserHistory(userId),
    );
  }

  @override
  Future<Either<Failure, int>> getHistoryCount(String userId) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getHistoryCount(userId),
      (count) => count as int,
    );
  }

  @override
  Future<Either<Failure, void>> trackRestaurantView({
    required String userId,
    required String restaurantId,
    required String restaurantName,
  }) async {
    final entry = HistoryEntry(
      id: '',
      userId: userId,
      type: HistoryType.restaurantView,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      timestamp: DateTime.now(),
    );

    return addHistory(entry);
  }

  @override
  Future<Either<Failure, void>> trackItemView({
    required String userId,
    required String itemId,
    required String itemName,
    String? restaurantId,
    String? restaurantName,
  }) async {
    final entry = HistoryEntry(
      id: '',
      userId: userId,
      type: HistoryType.itemView,
      itemId: itemId,
      itemName: itemName,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      timestamp: DateTime.now(),
    );

    return addHistory(entry);
  }

  @override
  Future<Either<Failure, void>> trackSearch({
    required String userId,
    required String searchQuery,
  }) async {
    final entry = HistoryEntry(
      id: '',
      userId: userId,
      type: HistoryType.search,
      searchQuery: searchQuery,
      timestamp: DateTime.now(),
    );

    return addHistory(entry);
  }
}
