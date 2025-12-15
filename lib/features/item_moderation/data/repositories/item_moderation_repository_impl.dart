import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/item_promotion_params.dart';
import '../../domain/entities/item_report_params.dart';
import '../../domain/repositories/item_moderation_repository.dart';
import '../datasources/item_moderation_remote_data_source.dart';

/// Implementation of item moderation repository
/// TR: Item moderasyon repository'sinin implementasyonu
///
/// This layer handles:
/// - Error mapping from exceptions to failures
/// - Business logic coordination
///
/// Bu katman şunları yönetir:
/// - Exception'lardan failure'lara hata eşleme
/// - İş mantığı koordinasyonu
class ItemModerationRepositoryImpl implements ItemModerationRepository {
  final ItemModerationRemoteDataSource remoteDataSource;

  ItemModerationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> promoteToLive(
    ItemPromotionParams params,
  ) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.promoteToLive(params),
    );
  }

  @override
  Future<Either<Failure, void>> approveItem(String itemId) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.approveItem(itemId),
    );
  }

  @override
  Future<Either<Failure, void>> rejectItem(
    String itemId, {
    String? reason,
  }) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.rejectItem(itemId, reason: reason),
    );
  }

  @override
  Future<Either<Failure, void>> reportItem(ItemReportParams params) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.reportItem(params),
    );
  }
}
