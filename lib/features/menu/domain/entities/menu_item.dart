import 'package:equatable/equatable.dart';

/// Menu item entity for clean architecture
class MenuItem extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final String category;
  final List<String> imageUrls;
  final bool isAvailable;
  final String restaurantId;
  final Map<String, dynamic>? nutritionInfo;
  final List<String> allergens;
  final List<String> tags;
  final double? rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? contributedBy;
  // ✅ Yeni alanlar
  final String? url;

  // ✅ OCR / Link / Manual item ayrımı için gerekli
  final String type; // "link", "ocr_item", "manual"

  // ✅ Link item’ın işlenip işlenmediğini anlamak için
  final String status; // "pending", "processed"

  // ✅ OCR veya link kaynağı için
  final String? source; // "ocr_from_link", "user_uploaded", vs.

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'TRY',
    required this.category,
    this.imageUrls = const [],
    this.isAvailable = true,
    required this.restaurantId,
    this.nutritionInfo,
    this.allergens = const [],
    this.tags = const [],
    this.rating,
    this.reviewCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.contributedBy,
    this.url,

    // ✅ Yeni alanlar
    this.type = 'manual',
    this.status = 'pending',
    this.source,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    currency,
    category,
    imageUrls,
    isAvailable,
    restaurantId,
    nutritionInfo,
    allergens,
    tags,
    rating,
    reviewCount,
    createdAt,
    updatedAt,
    contributedBy,
    type,
    status,
    source,
    url,
  ];
}
