import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/item_moderation_repository.dart';

/// Use case for approving a pending item (admin only)
/// TR: Bekleyen bir item'ı onaylamak için use case (sadece admin)
/// 
/// This replaces the Cloud Function callable: approveItem
/// Bu Cloud Function callable'ı değiştirir: approveItem
/// 
/// Flow / Akış:
/// 1. Check if user is admin / Kullanıcının admin olup olmadığını kontrol et
/// 2. Update item status to 'approved' / Item durumunu 'approved' olarak güncelle
/// 3. Index item in Algolia / Item'ı Algolia'da indeksle
class ApproveItemUseCase implements UseCase<void, String> {
  final ItemModerationRepository repository;

  ApproveItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String itemId) async {
    return await repository.approveItem(itemId);
  }
}
