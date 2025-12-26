import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/error_messages.dart';
import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  // Sadece data layer'a özel alanlar
  final String? menuId;
  final String? city;
  final String? district;
  final String? searchableText;
  final String? unit;
  final double? vatRate;
  final int? reportCount;
  final List<PriceHistory> previousPrices;

  const MenuItemModel({
    // Entity alanları
    required super.id,
    required super.name,
    super.description,
    required super.price,
    super.currency = 'TRY',
    required super.category,
    super.imageUrls = const [],
    super.isAvailable = true,
    required super.restaurantId,
    super.nutritionInfo,
    super.allergens = const [],
    super.tags = const [],
    super.rating,
    super.reviewCount = 0,
    required super.createdAt,
    super.updatedAt,
    super.contributedBy,

    // OCR / Link alanları entity'den geliyor
    super.type = 'manual',
    super.url,
    super.source,
    super.status = 'pending',

    // Model-only alanlar
    this.menuId,
    this.city,
    this.district,
    this.searchableText,
    this.unit,
    this.vatRate,
    this.reportCount,
    this.previousPrices = const [],
  });

  // ---------- FACTORYLAR ----------

  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItemModel.fromMap(data, doc.id);
  }

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      id: id,
      name: map['name'] ?? 'Unknown Item',
      description: map['description'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'TRY',
      category: map['category'] ?? ErrorMessages.otherCategory,
      imageUrls: map['imageUrls'] != null
          ? List<String>.from(map['imageUrls'] as List)
          : const [],
      isAvailable: map['isAvailable'] ?? true,
      restaurantId: map['restaurantId'] ?? '',
      nutritionInfo: map['nutritionInfo'] as Map<String, dynamic>?,
      allergens: map['allergens'] != null
          ? List<String>.from(map['allergens'] as List)
          : const [],
      tags: map['tags'] != null
          ? List<String>.from(map['tags'] as List)
          : const [],
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      contributedBy: map['contributedBy'] as String?,

      // Entity tarafı - OCR/Link
      type: map['type'] ?? 'manual',
      url: map['url'] as String?,
      source: map['source'] as String?,
      status: map['status'] ?? 'pending',

      // Model-only
      menuId: map['menuId'] as String?,
      city: map['city'] as String?,
      district: map['district'] as String?,
      searchableText: map['searchableText'] as String?,
      unit: map['unit'] as String?,
      vatRate: (map['vatRate'] as num?)?.toDouble(),
      reportCount: map['reportCount'] as int?,
      previousPrices: map['previousPrices'] != null
          ? (map['previousPrices'] as List)
                .map((p) => PriceHistory.fromMap(p as Map<String, dynamic>))
                .toList()
          : const [],
    );
  }

  // ---------- MAP & FIRESTORE ----------

  Map<String, dynamic> toMap() {
    return {
      // Entity alanları
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'category': category,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'restaurantId': restaurantId,
      'nutritionInfo': nutritionInfo,
      'allergens': allergens,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'contributedBy': contributedBy,

      // OCR/Link alanları
      'type': type,
      'url': url,
      'source': source,
      'status': status,

      // Model-only alanlar
      'menuId': menuId,
      'city': city,
      'district': district,
      'searchableText': searchableText,
      'unit': unit,
      'vatRate': vatRate,
      'reportCount': reportCount,
      'previousPrices': previousPrices.map((p) => p.toMap()).toList(),
    };
  }

  Map<String, dynamic> toFirestore() {
    final map = toMap();
    map.removeWhere((key, value) => value == null);
    return map;
  }

  // ---------- COPYWITH ----------

  MenuItemModel copyWith({
    // Entity alanları
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    String? category,
    List<String>? imageUrls,
    bool? isAvailable,
    String? restaurantId,
    Map<String, dynamic>? nutritionInfo,
    List<String>? allergens,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? contributedBy,

    // OCR / Link
    String? type,
    String? url,
    String? source,
    String? status,

    // Model-only
    String? menuId,
    String? city,
    String? district,
    String? searchableText,
    String? unit,
    double? vatRate,
    int? reportCount,
    List<PriceHistory>? previousPrices,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      restaurantId: restaurantId ?? this.restaurantId,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      allergens: allergens ?? this.allergens,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contributedBy: contributedBy ?? this.contributedBy,

      type: type ?? this.type,
      url: url ?? this.url,
      source: source ?? this.source,
      status: status ?? this.status,

      menuId: menuId ?? this.menuId,
      city: city ?? this.city,
      district: district ?? this.district,
      searchableText: searchableText ?? this.searchableText,
      unit: unit ?? this.unit,
      vatRate: vatRate ?? this.vatRate,
      reportCount: reportCount ?? this.reportCount,
      previousPrices: previousPrices ?? this.previousPrices,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    menuId,
    city,
    district,
    searchableText,
    unit,
    vatRate,
    reportCount,
    previousPrices,
  ];

  static fromJson(json) {}
}

class PriceHistory {
  final double price;
  final DateTime date;
  final String? changedBy;

  const PriceHistory({required this.price, required this.date, this.changedBy});

  factory PriceHistory.fromMap(Map<String, dynamic> map) {
    return PriceHistory(
      price: (map['price'] as num).toDouble(),
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date'] as String),
      changedBy: map['changedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'date': Timestamp.fromDate(date),
      'changedBy': changedBy,
    };
  }
}
