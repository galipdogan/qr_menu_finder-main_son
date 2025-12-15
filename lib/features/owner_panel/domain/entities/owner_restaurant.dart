import 'package:equatable/equatable.dart';

/// Domain entity for owner's restaurant info
class OwnerRestaurant extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? imageUrl;
  final int menuItemCount;
  final int reviewCount;
  final double? rating;
  final DateTime createdAt;

  const OwnerRestaurant({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    required this.menuItemCount,
    required this.reviewCount,
    this.rating,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        imageUrl,
        menuItemCount,
        reviewCount,
        rating,
        createdAt,
      ];
}
