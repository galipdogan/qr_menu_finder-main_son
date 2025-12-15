import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/item_promotion_params.dart';
import '../entities/item_report_params.dart';

/// Abstract repository for item moderation operations
/// TR: Item moderasyon işlemleri için soyut repository
/// 
/// This repository handles:
/// - Promoting staging items to live collection
/// - Approving/rejecting items (admin only)
/// - Reporting items (user reports)
/// 
/// Bu repository şunları yönetir:
/// - Staging item'ları canlı koleksiyona yükseltme
/// - Item'ları onaylama/reddetme (sadece admin)
/// - Item'ları raporlama (kullanıcı raporları)
abstract class ItemModerationRepository {
  /// Promote a staging item to live items collection
  /// TR: Staging item'ı canlı items koleksiyonuna yükselt
  /// 
  /// This replaces the Cloud Function: promoteToLive
  /// Bu Cloud Function'ı değiştirir: promoteToLive
  Future<Either<Failure, void>> promoteToLive(ItemPromotionParams params);

  /// Approve a pending item (admin only)
  /// TR: Bekleyen bir item'ı onayla (sadece admin)
  /// 
  /// This replaces the Cloud Function: approveItem
  /// Bu Cloud Function'ı değiştirir: approveItem
  Future<Either<Failure, void>> approveItem(String itemId);

  /// Reject a pending item (admin only)
  /// TR: Bekleyen bir item'ı reddet (sadece admin)
  /// 
  /// This replaces the Cloud Function: rejectItem
  /// Bu Cloud Function'ı değiştirir: rejectItem
  Future<Either<Failure, void>> rejectItem(String itemId, {String? reason});

  /// Report an item for wrong price, spam, etc.
  /// TR: Yanlış fiyat, spam vb. için bir item'ı raporla
  /// 
  /// This replaces the Cloud Function: reportItem
  /// Bu Cloud Function'ı değiştirir: reportItem
  Future<Either<Failure, void>> reportItem(ItemReportParams params);
}
