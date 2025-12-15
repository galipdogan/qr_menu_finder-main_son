import '../../domain/entities/search_result.dart';

/// Search result model for data layer - extends domain entity
/// Converts from/to Algolia search response
class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.id,
    required super.type,
    required super.name,
    super.description,
    super.price,
    super.restaurantId,
    super.restaurantName,
    super.category,
    super.imageUrl,
    super.rating,
    super.address,
    super.city,
    super.district,
  });

  factory SearchResultModel.fromMeiliSearchHit(Map<String, dynamic> hit) {
    final String type = hit['type'] ?? _inferType(hit);

    return SearchResultModel(
      id: hit['id'] ?? '',
      type: type,
      name: hit['name'] ?? '',
      description: hit['description'],
      price: (hit['price'] as num?)?.toDouble(),
      restaurantId: hit['restaurantId'] ?? hit['restaurant_id'],
      restaurantName: hit['restaurantName'] ?? hit['restaurant_name'],
      category: hit['category'],
      imageUrl: _extractImageUrl(hit),
      rating: (hit['rating'] as num?)?.toDouble(),
      address: hit['address'],
      city: hit['city'],
      district: hit['district'],
    );
  }

  /// Create from Algolia hit (Map with String, dynamic)
  factory SearchResultModel.fromAlgoliaHit(Map<String, dynamic> hit) {
    // Determine type from objectID or explicit type field
    final String type = hit['type'] ?? _inferType(hit);

    return SearchResultModel(
      id: hit['objectID'] ?? '',
      type: type,
      name: hit['name'] ?? '',
      description: hit['description'],
      price: (hit['price'] as num?)?.toDouble(),
      restaurantId: hit['restaurantId'] ?? hit['restaurant_id'],
      restaurantName: hit['restaurantName'] ?? hit['restaurant_name'],
      category: hit['category'],
      imageUrl: _extractImageUrl(hit),
      rating: (hit['rating'] as num?)?.toDouble() ??
              (hit['googleRating'] as num?)?.toDouble(),
      address: hit['address'],
      city: hit['city'],
      district: hit['district'],
    );
  }

  /// Infer type from hit data
  static String _inferType(Map<String, dynamic> hit) {
    // If it has restaurantId and price, it's likely a menu item
    if (hit.containsKey('restaurantId') && hit.containsKey('price')) {
      return 'menu_item';
    }
    // If it has placeId or location, it's a restaurant
    if (hit.containsKey('placeId') || hit.containsKey('location')) {
      return 'restaurant';
    }
    // Default to restaurant
    return 'restaurant';
  }

  /// Extract image URL from various possible fields
  static String? _extractImageUrl(Map<String, dynamic> hit) {
    // Try imageUrl field
    if (hit['imageUrl'] != null) {
      return hit['imageUrl'] as String;
    }
    // Try imageUrls array
    if (hit['imageUrls'] is List && (hit['imageUrls'] as List).isNotEmpty) {
      return (hit['imageUrls'] as List).first as String;
    }
    return null;
  }

  /// Convert to domain entity
  SearchResult toEntity() {
    return SearchResult(
      id: id,
      type: type,
      name: name,
      description: description,
      price: price,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      category: category,
      imageUrl: imageUrl,
      rating: rating,
      address: address,
      city: city,
      district: district,
    );
  }

  /// Convert from domain entity
  factory SearchResultModel.fromEntity(SearchResult entity) {
    return SearchResultModel(
      id: entity.id,
      type: entity.type,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      category: entity.category,
      imageUrl: entity.imageUrl,
      rating: entity.rating,
      address: entity.address,
      city: entity.city,
      district: entity.district,
    );
  }
}
