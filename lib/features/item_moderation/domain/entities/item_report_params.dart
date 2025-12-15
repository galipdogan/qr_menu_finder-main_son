import 'package:equatable/equatable.dart';

/// Parameters for reporting an item
/// TR: Bir item'ı raporlamak için parametreler
class ItemReportParams extends Equatable {
  final String itemId;
  final String reason; // 'wrong_price', 'spam', 'inappropriate', 'duplicate', 'other'
  final String? details;

  const ItemReportParams({
    required this.itemId,
    required this.reason,
    this.details,
  });

  /// Valid report reasons / Geçerli rapor nedenleri
  static const List<String> validReasons = [
    'wrong_price',
    'spam',
    'inappropriate',
    'duplicate',
    'other',
  ];

  /// Check if reason is valid / Nedenin geçerli olup olmadığını kontrol et
  bool get isReasonValid => validReasons.contains(reason);

  @override
  List<Object?> get props => [itemId, reason, details];
}
