import 'package:equatable/equatable.dart';

/// Restaurant entity for clean architecture
class Restaurant extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? website;
  final List<String> imageUrls;
  final double? rating;
  final int reviewCount;
  final List<String> categories;
  final Map<String, String> openingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? ownerId;
  final bool hasMenu; // Menu bilgisi Firebase'de var mı?

  const Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.website,
    this.imageUrls = const [],
    this.rating,
    this.reviewCount = 0,
    this.categories = const [],
    this.openingHours = const {},
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.ownerId,
    this.hasMenu = false, // Default: menü yok
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        latitude,
        longitude,
        phoneNumber,
        website,
        imageUrls,
        rating,
        reviewCount,
        categories,
        openingHours,
        isActive,
        createdAt,
        updatedAt,
        ownerId,
        hasMenu,
      ];
}