import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/item_promotion_params.dart';
import '../repositories/item_moderation_repository.dart';

/// Use case for promoting a staging item to live items collection
/// TR: Staging item'ı canlı items koleksiyonuna yükseltmek için use case
/// 
/// This replaces the Cloud Function callable: promoteToLive
/// Bu Cloud Function callable'ı değiştirir: promoteToLive
/// 
/// Flow / Akış:
/// 1. Get staging item from Firestore / Firestore'dan staging item'ı al
/// 2. Get restaurant data for denormalization / Denormalizasyon için restoran verisini al
/// 3. Create/update item in items collection / Items koleksiyonunda item oluştur/güncelle
/// 4. Update restaurant lastSyncedAt / Restoranın lastSyncedAt'ini güncelle
/// 5. Delete staging item / Staging item'ı sil
class PromoteToLiveUseCase implements UseCase<void, ItemPromotionParams> {
  final ItemModerationRepository repository;

  PromoteToLiveUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ItemPromotionParams params) async {
    return await repository.promoteToLive(params);
  }
}
