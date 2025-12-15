import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/item_report_params.dart';
import '../repositories/item_moderation_repository.dart';

/// Use case for reporting an item
/// TR: Bir item'ı raporlamak için use case
/// 
/// This replaces the Cloud Function callable: reportItem
/// Bu Cloud Function callable'ı değiştirir: reportItem
/// 
/// Flow / Akış:
/// 1. Validate report reason / Rapor nedenini doğrula
/// 2. Check if user already reported this item / Kullanıcının bu item'ı daha önce raporlayıp raporlamadığını kontrol et
/// 3. Increment item reportCount / Item'ın reportCount'unu artır
/// 4. Create report document / Rapor belgesi oluştur
/// 5. Auto-flag item if reportCount >= 3 / reportCount >= 3 ise item'ı otomatik olarak işaretle
class ReportItemUseCase implements UseCase<void, ItemReportParams> {
  final ItemModerationRepository repository;

  ReportItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ItemReportParams params) async {
    // Validate reason / Nedeni doğrula
    if (!params.isReasonValid) {
      return Left(ValidationFailure(
        'Invalid report reason. Must be one of: ${ItemReportParams.validReasons.join(", ")}',
      ));
    }

    return await repository.reportItem(params);
  }
}
