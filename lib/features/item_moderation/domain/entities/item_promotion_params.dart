import 'package:equatable/equatable.dart';

/// Parameters for promoting a staging item to live items collection
/// TR: Staging item'ı canlı items koleksiyonuna yükseltmek için parametreler
class ItemPromotionParams extends Equatable {
  final String stagingId;
  final String restaurantId;
  final String? itemId; // If updating existing item / Mevcut item güncelleniyorsa
  final String? idempotencyKey; // For preventing duplicate requests / Tekrar istekleri önlemek için
  final String? updatedName;
  final double? updatedPrice;
  final String? updatedCurrency;

  const ItemPromotionParams({
    required this.stagingId,
    required this.restaurantId,
    this.itemId,
    this.idempotencyKey,
    this.updatedName,
    this.updatedPrice,
    this.updatedCurrency,
  });

  @override
  List<Object?> get props => [
        stagingId,
        restaurantId,
        itemId,
        idempotencyKey,
        updatedName,
        updatedPrice,
        updatedCurrency,
      ];
}
