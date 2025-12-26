import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/restaurant.dart';

/// Restaurant location model
class RestaurantLocation {
  final double lat;
  final double lng;

  RestaurantLocation({required this.lat, required this.lng});

  factory RestaurantLocation.fromMap(dynamic data) {
    if (data is GeoPoint) {
      return RestaurantLocation(lat: data.latitude, lng: data.longitude);
    } else if (data is Map<String, dynamic>) {
      return RestaurantLocation(
        lat: (data['lat'] ?? 0.0).toDouble(),
        lng: (data['lng'] ?? 0.0).toDouble(),
      );
    } else {
      return RestaurantLocation(lat: 0.0, lng: 0.0);
    }
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng};
  }

  GeoPoint toGeoPoint() {
    return GeoPoint(lat, lng);
  }
}

/// Restaurant model for data layer - extends domain entity
class RestaurantModel extends Restaurant {
  final String placeId;
  final String geohash;
  final DateTime? lastSyncedAt;
  final String? city;
  final String? district;
  final String? contributedBy;
  final bool isFromGooglePlaces;
  final int itemCount;
  final List<Map<String, dynamic>> menuLinks;
  final List<Map<String, dynamic>> menuPreview;

  const RestaurantModel({
    required super.id,
    required super.name,
    super.description,
    super.address,
    super.latitude,
    super.longitude,
    super.phoneNumber,
    super.website,
    super.imageUrls,
    super.rating,
    super.reviewCount,
    super.categories,
    super.openingHours,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
    super.ownerId,
    super.hasMenu,
    required this.placeId,
    required this.geohash,
    this.lastSyncedAt,
    this.city,
    this.district,
    this.contributedBy,
    this.isFromGooglePlaces = true,
    this.itemCount = 0,
    this.menuLinks = const [],
    this.menuPreview = const [],
  });

  factory RestaurantModel.fromEntity(Restaurant entity) {
    if (entity is RestaurantModel) {
      return entity;
    }
    return RestaurantModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      phoneNumber: entity.phoneNumber,
      website: entity.website,
      imageUrls: entity.imageUrls,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      categories: entity.categories,
      openingHours: entity.openingHours,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      ownerId: entity.ownerId,
      hasMenu: entity.hasMenu,
      placeId: entity.id, // Default to ID if missing
      geohash: '', // Default to empty if missing
    );
  }

  /// ✅ Create from Firestore document (ID NORMALIZED)
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final location = RestaurantLocation.fromMap(data['location'] ?? {});

    final name = data['name'] as String?;
    if (name == null || name.isEmpty) {
      throw StateError('Missing or empty name for restaurant ID: ${doc.id}');
    }

    // ✅ Normalize ID
    final placeId = data['placeId']?.toString() ?? '';
    final normalizedId = placeId.isNotEmpty
        ? placeId
        : doc.id; // fallback for manually added restaurants

    return RestaurantModel(
      id: normalizedId, // ✅ CRITICAL FIX
      name: name,
      description: data['description'],
      address: data['address'] ?? '',
      latitude: location.lat,
      longitude: location.lng,
      phoneNumber: data['phoneNumber'],
      website: data['website'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      rating: (data['googleRating'] as num?)?.toDouble(),
      reviewCount: (data['reviewCount'] ?? 0) as int,
      categories: List<String>.from(data['categories'] ?? []),
      openingHours: _parseOpeningHours(data['openingHours']),
      isActive: _parseBool(data['isActive']) ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      ownerId: data['ownerId'],
      hasMenu: true,
      placeId: placeId,
      geohash: data['geohash'] ?? '',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
      city: data['city'],
      district: data['district'],
      contributedBy: data['contributedBy'],
      isFromGooglePlaces: data['isFromGooglePlaces'] ?? true,
      itemCount: (data['itemCount'] ?? 0) as int,
      menuLinks: List<Map<String, dynamic>>.from(data['menuLinks'] ?? []),
      menuPreview: List<Map<String, dynamic>>.from(data['menuPreview'] ?? []),
    );
  }

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phoneNumber: json['phoneNumber'],
      website: json['website'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'],
      categories: List<String>.from(json['categories'] ?? []),
      openingHours: Map<String, String>.from(json['openingHours'] ?? {}),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      ownerId: json['ownerId'],
      hasMenu: json['hasMenu'],
      placeId: json['placeId'],
      geohash: json['geohash'],
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : null,
      city: json['city'],
      district: json['district'],
      contributedBy: json['contributedBy'],
      isFromGooglePlaces: json['isFromGooglePlaces'],
      itemCount: json['itemCount'],
      menuLinks: List<Map<String, dynamic>>.from(json['menuLinks'] ?? []),
      menuPreview: List<Map<String, dynamic>>.from(json['menuPreview'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'website': website,
      'imageUrls': imageUrls,
      'rating': rating,
      'reviewCount': reviewCount,
      'categories': categories,
      'openingHours': openingHours,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'ownerId': ownerId,
      'hasMenu': hasMenu,
      'placeId': placeId,
      'geohash': geohash,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'city': city,
      'district': district,
      'contributedBy': contributedBy,
      'isFromGooglePlaces': isFromGooglePlaces,
      'itemCount': itemCount,
      'menuLinks': menuLinks,
      'menuPreview': menuPreview,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'location': RestaurantLocation(
        lat: latitude ?? 0.0,
        lng: longitude ?? 0.0,
      ).toMap(),
      'phoneNumber': phoneNumber,
      'website': website,
      'imageUrls': imageUrls,
      'googleRating': rating,
      'reviewCount': reviewCount,
      'categories': categories,
      'openingHours': openingHours,
      'isActive': isActive,
      'ownerId': ownerId,
      'placeId': placeId,
      'geohash': geohash,
      'lastSyncedAt': lastSyncedAt != null
          ? Timestamp.fromDate(lastSyncedAt!)
          : null,
      'city': city,
      'district': district,
      'contributedBy': contributedBy,
      'isFromGooglePlaces': isFromGooglePlaces,
      'itemCount': itemCount,
      'menuLinks': menuLinks,
      'menuPreview': menuPreview,
      'updatedAt': FieldValue.serverTimestamp(),
      if (createdAt == DateTime.now())
        'createdAt': FieldValue.serverTimestamp(),
    };
  }

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? website,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    List<String>? categories,
    Map<String, String>? openingHours,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerId,
    bool? hasMenu,
    String? placeId,
    String? geohash,
    DateTime? lastSyncedAt,
    String? city,
    String? district,
    String? contributedBy,
    bool? isFromGooglePlaces,
    int? itemCount,
    List<Map<String, dynamic>>? menuLinks,
    List<Map<String, dynamic>>? menuPreview,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      categories: categories ?? this.categories,
      openingHours: openingHours ?? this.openingHours,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerId: ownerId ?? this.ownerId,
      hasMenu: hasMenu ?? this.hasMenu,
      placeId: placeId ?? this.placeId,
      geohash: geohash ?? this.geohash,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      city: city ?? this.city,
      district: district ?? this.district,
      contributedBy: contributedBy ?? this.contributedBy,
      isFromGooglePlaces: isFromGooglePlaces ?? this.isFromGooglePlaces,
      itemCount: itemCount ?? this.itemCount,
      menuLinks: menuLinks ?? this.menuLinks,
      menuPreview: menuPreview ?? this.menuPreview,
    );
  }

  Restaurant toEntity() {
    return Restaurant(
      id: id,
      name: name,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phoneNumber: phoneNumber,
      website: website,
      imageUrls: imageUrls,
      rating: rating,
      reviewCount: reviewCount,
      categories: categories,
      openingHours: openingHours,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      ownerId: ownerId,
      hasMenu: hasMenu,
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) return value != 0;
    return null;
  }

  static Map<String, String> _parseOpeningHours(dynamic value) {
    if (value == null) return {};
    if (value is! Map) return {};

    final result = <String, String>{};
    value.forEach((key, val) {
      if (key is String) {
        if (val is String) {
          result[key] = val;
        } else if (val is bool) {
          result[key] = val.toString();
        } else if (val != null) {
          result[key] = val.toString();
        }
      }
    });
    return result;
  }
}
