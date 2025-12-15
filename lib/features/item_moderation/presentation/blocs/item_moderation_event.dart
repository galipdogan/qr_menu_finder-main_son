import 'package:equatable/equatable.dart';
import '../../domain/entities/item_promotion_params.dart';
import '../../domain/entities/item_report_params.dart';

/// Base event for item moderation
/// TR: Item moderasyon için temel event
abstract class ItemModerationEvent extends Equatable {
  const ItemModerationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to promote a staging item to live collection
/// TR: Staging item'ı canlı koleksiyona yükseltme event'i
class PromoteItemToLive extends ItemModerationEvent {
  final ItemPromotionParams params;

  const PromoteItemToLive(this.params);

  @override
  List<Object?> get props => [params];
}

/// Event to approve a pending item (admin only)
/// TR: Bekleyen bir item'ı onaylama event'i (sadece admin)
class ApproveItem extends ItemModerationEvent {
  final String itemId;

  const ApproveItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Event to reject a pending item (admin only)
/// TR: Bekleyen bir item'ı reddetme event'i (sadece admin)
class RejectItem extends ItemModerationEvent {
  final String itemId;
  final String? reason;

  const RejectItem(this.itemId, {this.reason});

  @override
  List<Object?> get props => [itemId, reason];
}

/// Event to report an item
/// TR: Bir item'ı raporlama event'i
class ReportItem extends ItemModerationEvent {
  final ItemReportParams params;

  const ReportItem(this.params);

  @override
  List<Object?> get props => [params];
}
