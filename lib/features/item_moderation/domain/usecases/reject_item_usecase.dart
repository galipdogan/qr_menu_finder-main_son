import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/item_moderation_repository.dart';

/// Parameters for rejecting an item
/// TR: Bir item'ı reddetmek için parametreler
class RejectItemParams {
  final String itemId;
  final String? reason;

  const RejectItemParams({
    required this.itemId,
    this.reason,
  });
}

/// Use case for rejecting a pending item (admin only)
/// TR: Bekleyen bir item'ı reddetmek için use case (sadece admin)
/// 
/// This replaces the Cloud Function callable: rejectItem
/// Bu Cloud Function callable'ı değiştirir: rejectItem
/// 
/// Flow / Akış:
/// 1. Check if user is admin / Kullanıcının admin olup olmadığını kontrol et
/// 2. Update item status to 'rejected' / Item durumunu 'rejected' olarak güncelle
/// 3. Remove item from Algolia index / Item'ı Algolia indeksinden kaldır
class RejectItemUseCase {
  final ItemModerationRepository repository;

  RejectItemUseCase(this.repository);

  Future<Either<Failure, void>> call(RejectItemParams params) async {
    return await repository.rejectItem(params.itemId, reason: params.reason);
  }
}
