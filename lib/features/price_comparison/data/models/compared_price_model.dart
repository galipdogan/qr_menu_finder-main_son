import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/compared_price.dart';

/// Data model for ComparedPrice entity
class ComparedPriceModel extends ComparedPrice {
  const ComparedPriceModel({
    required super.restaurantId,
    required super.restaurantName,
    required super.price,
    required super.currency,
  });

  /// Create ComparedPriceModel from Firestore document
  factory ComparedPriceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Note: In a real app, you'd fetch the restaurant name
    // from the 'restaurants' collection using restaurantId.
    // For now, we'll use a placeholder or assume it's denormalized.
    final restaurantName = data['restaurantName'] ?? 'Bilinmeyen Restoran';

    return ComparedPriceModel(
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: restaurantName,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'TRY',
    );
  }

  /// Convert model to entity
  ComparedPrice toEntity() {
    return ComparedPrice(
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      price: price,
      currency: currency,
    );
  }

  /// Create model from entity
  factory ComparedPriceModel.fromEntity(ComparedPrice entity) {
    return ComparedPriceModel(
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      price: entity.price,
      currency: entity.currency,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'price': price,
      'currency': currency,
    };
  }
}
