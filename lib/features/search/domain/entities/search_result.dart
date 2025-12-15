import 'package:equatable/equatable.dart';

/// Search result entity for clean architecture
/// Represents a single search result item (can be restaurant or menu item)
class SearchResult extends Equatable {
  final String id;
  final String type; // 'restaurant' or 'menu_item'
  final String name;
  final String? description;
  final double? price;
  final String? restaurantId;
  final String? restaurantName;
  final String? category;
  final String? imageUrl;
  final double? rating;
  final String? address;
  final String? city;
  final String? district;

  const SearchResult({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.price,
    this.restaurantId,
    this.restaurantName,
    this.category,
    this.imageUrl,
    this.rating,
    this.address,
    this.city,
    this.district,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        description,
        price,
        restaurantId,
        restaurantName,
        category,
        imageUrl,
        rating,
        address,
        city,
        district,
      ];
}
