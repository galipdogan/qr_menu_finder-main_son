import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/owner_restaurant.dart';

/// Data model for owner's restaurant
class OwnerRestaurantModel extends OwnerRestaurant {
  const OwnerRestaurantModel({
    required super.id,
    required super.name,
    required super.address,
    super.imageUrl,
    required super.menuItemCount,
    required super.reviewCount,
    super.rating,
    required super.createdAt,
  });

  /// Create from Firestore document
  factory OwnerRestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OwnerRestaurantModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      menuItemCount: data['menuItemCount'] as int? ?? 0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      rating: (data['rating'] as num?)?.toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create from map
  factory OwnerRestaurantModel.fromMap(Map<String, dynamic> map, String id) {
    return OwnerRestaurantModel(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      menuItemCount: map['menuItemCount'] as int? ?? 0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
