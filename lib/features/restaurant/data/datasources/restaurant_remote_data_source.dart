import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/error/error.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/maps/data/datasources/openstreetmap_details_remote_data_source.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/models/place_result.dart';
import '../../../../core/services/nominatim_service.dart';
import '../models/restaurant_model.dart';
import '../cache/restaurant_cache_service.dart';

/// Abstract restaurant remote data source
abstract class RestaurantRemoteDataSource {
  /// Get nearby restaurants
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    int limit = 20,
  });

  /// Search restaurants by name or category
  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  });

  /// Get restaurant by ID
  Future<RestaurantModel> getRestaurantById(String id);

  /// Get restaurants by owner ID
  Future<List<RestaurantModel>> getRestaurantsByOwnerId(String ownerId);

  /// Create new restaurant
  Future<RestaurantModel> createRestaurant(RestaurantModel restaurant);

  /// Update restaurant
  Future<RestaurantModel> updateRestaurant(RestaurantModel restaurant);

  /// Delete restaurant
  Future<void> deleteRestaurant(String id);

  /// Get popular restaurants
  Future<List<RestaurantModel>> getPopularRestaurants({int limit = 10});

  /// Get restaurants by category
  Future<List<RestaurantModel>> getRestaurantsByCategory({
    required String category,
    int limit = 20,
  });

  /// Search restaurants directly from Firestore based on query
  Future<List<PlaceResult>> searchRestaurantsFromFirestore(
    String query, {
    int limit = 10,
  });
}

/// Firebase implementation of restaurant remote data source
/// TR: Restaurant uzak veri kaynağının Firebase implementasyonu
///
/// Now uses Nominatim (OpenStreetMap) instead of Google Places API
/// Artık Google Places API yerine Nominatim (OpenStreetMap) kullanıyor
class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final FirebaseFirestore firestore;
  final NominatimService nominatimService;
  final OpenStreetMapDetailsRemoteDataSource osmDetailsService;
  late final RestaurantCacheService _cacheService;

  // Cache for nearby restaurants
  static final Map<String, List<RestaurantModel>> _nearbyCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);

  RestaurantRemoteDataSourceImpl({
    required this.firestore,
    required this.nominatimService,
    required this.osmDetailsService,
  }) {
    _cacheService = RestaurantCacheService(firestore: firestore);
  }

  @override
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    int limit = 20,
  }) async {
    final cacheKey = _buildCacheKey(latitude, longitude, radiusMeters, limit);

    final cachedRestaurants = _getCachedRestaurants(cacheKey);
    if (cachedRestaurants != null) {
      AppLogger.i(
        '📦 Using cached nearby restaurants (${cachedRestaurants.length} restaurants)',
      );
      return cachedRestaurants;
    }

    try {
      final nominatimRestaurants = await _fetchRestaurantsFromNominatim(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        limit: limit,
      );

      if (nominatimRestaurants.isNotEmpty) {
        _cacheResults(cacheKey, nominatimRestaurants);
        return nominatimRestaurants;
      }

      AppLogger.w(
        '⚠️ Nominatim returned 0 restaurants. Falling back to Overpass.',
      );
      final overpassRestaurants = await _fetchRestaurantsFromOverpass(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        limit: limit,
      );
      _cacheResults(cacheKey, overpassRestaurants);
      return overpassRestaurants;
    } catch (e, stackTrace) {
      AppLogger.w(
        '⚠️ Nominatim fetch failed, trying Overpass',
        error: e,
        stackTrace: stackTrace,
      );

      try {
        final overpassRestaurants = await _fetchRestaurantsFromOverpass(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
          limit: limit,
        );
        _cacheResults(cacheKey, overpassRestaurants);
        return overpassRestaurants;
      } catch (err, overpassStackTrace) {
        AppLogger.e(
          '❌ getNearbyRestaurants error',
          error: err,
          stackTrace: overpassStackTrace,
        );

        if (err.toString().toLowerCase().contains('network') ||
            err.toString().toLowerCase().contains('connection')) {
          throw ServerException(ErrorMessages.noInternet);
        }

        throw ServerException(ErrorMessages.restaurantLoadFailed);
      }
    }
  }

  String _buildCacheKey(
    double latitude,
    double longitude,
    int radiusMeters,
    int limit,
  ) {
    return '${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}_${radiusMeters}_$limit';
  }

  List<RestaurantModel>? _getCachedRestaurants(String cacheKey) {
    final cache = _nearbyCache[cacheKey];
    final timestamp = _cacheTimestamps[cacheKey];

    if (cache == null || timestamp == null) {
      return null;
    }

    if (DateTime.now().difference(timestamp) >= _cacheExpiry) {
      _nearbyCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
      return null;
    }

    return cache;
  }

  void _cacheResults(String cacheKey, List<RestaurantModel> restaurants) {
    if (restaurants.isEmpty) return;
    _nearbyCache[cacheKey] = restaurants;
    _cacheTimestamps[cacheKey] = DateTime.now();
    AppLogger.i(
      '🎯 Cached ${restaurants.length} restaurants for ${_cacheExpiry.inMinutes} minutes',
    );
  }

  /// Cache restaurants to Firebase for future detail page access
  void _cacheRestaurantsToFirebase(List<RestaurantModel> restaurants) {
    _cacheService.cacheRestaurantsToFirebase(restaurants);
  }

  Future<List<RestaurantModel>> _fetchRestaurantsFromNominatim({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required int limit,
  }) async {
    AppLogger.i('🌐 Getting nearby restaurants from Nominatim (fast path)...');
    final places = await nominatimService.searchNearby(
      query: 'restaurant', // Generic query for restaurants
      latitude: latitude,
      longitude: longitude,
      limit: limit,
    );

    if (places.isEmpty) {
      AppLogger.w('⚠️ Nominatim returned 0 results');
      return [];
    }

    // Convert NominatimPlace to PlaceResult
    final placeResults = places.map((place) => PlaceResult(
      placeId: place.placeId.toString(),
      name: place.displayName.split(',').first.trim(),
      displayName: place.displayName,
      latitude: place.latitude,
      longitude: place.longitude,
      type: place.type ?? 'restaurant',
    )).toList();

    final models = placeResults
        .map((place) => _convertPlaceResultToRestaurantModel(place))
        .toList();

    final placeIds = models
        .map((model) => model.placeId)
        .where((id) => id.isNotEmpty)
        .toList();

    final restaurantsWithMenus = await _fetchRestaurantsWithMenus(placeIds);

    final enriched = models
        .map(
          (model) => restaurantsWithMenus.contains(model.placeId)
              ? model.copyWith(
                  hasMenu: true,
                  itemCount: max(model.itemCount, 5),
                  contributedBy: model.contributedBy ?? 'nominatim',
                )
              : model,
        )
        .toList();

    _sortByDistance(enriched, latitude, longitude);
    AppLogger.i(
      '✅ Nominatim prepared ${enriched.length} restaurants before limiting',
    );

    final finalResults = enriched.take(limit).toList();

    // Cache restaurants to Firebase for future detail page access
    _cacheRestaurantsToFirebase(finalResults);

    return finalResults;
  }

  Future<List<RestaurantModel>> _fetchRestaurantsFromOverpass({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required int limit,
  }) async {
    AppLogger.i(
      '🌐 Getting nearby restaurants from OpenStreetMap (Overpass)...',
    );
    AppLogger.i(
      '📍 Location: ($latitude, $longitude), Radius: ${radiusMeters / 1000}km',
    );

    final osmRestaurants = await osmDetailsService
        .getNearbyRestaurantsWithDetails(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusMeters / 1000,
          limit: limit * 2,
        );

    if (osmRestaurants.isEmpty) {
      AppLogger.w('⚠️ No restaurants found in OpenStreetMap');
      return [];
    }

    final osmIds = osmRestaurants
        .map((data) => data['osm_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    final restaurantsWithMenus = await _fetchRestaurantsWithMenus(osmIds);

    final restaurants = <RestaurantModel>[];

    for (final osmData in osmRestaurants) {
      try {
        final osmId = osmData['osm_id']?.toString() ?? '';
        final addressString = (osmData['address'] ?? '').toString();
        final restaurantId =
            'osm_${osmData['osm_type']?.toString().substring(0, 1).toUpperCase() ?? 'N'}$osmId';

        final hasMenu = restaurantsWithMenus.contains(osmId);

        final restaurant = RestaurantModel(
          id: restaurantId,
          name: osmData['name']?.toString() ?? 'Bilinmeyen Restoran',
          description: osmData['description']?.toString() ?? '',
          address: addressString,
          latitude: (osmData['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (osmData['longitude'] as num?)?.toDouble() ?? 0.0,
          phoneNumber: osmData['phone']?.toString() ?? '',
          website: osmData['website']?.toString() ?? '',
          imageUrls: const [],
          rating:
              4.0 +
              ((osmData['name']?.toString().hashCode.abs() ?? 0) % 10) / 10,
          reviewCount:
              ((osmData['name']?.toString().hashCode.abs() ?? 0) % 50) + 5,
          categories: _parseCuisineTypes(
            osmData['cuisine']?.toString() ??
                osmData['amenity']?.toString() ??
                'restaurant',
          ),
          openingHours: _parseOpeningHours(
            osmData['opening_hours']?.toString() ?? '',
          ),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          ownerId: '',
          hasMenu: hasMenu,
          placeId: osmId,
          geohash: '',
          district: addressString.contains(',')
              ? addressString.split(',').last.trim()
              : '',
          contributedBy: 'openstreetmap',
          isFromGooglePlaces: false,
          itemCount: hasMenu
              ? ((osmData['name']?.toString().hashCode.abs() ?? 0) % 20) + 5
              : 0,
          menuLinks: const [],
        );

        restaurants.add(restaurant);
      } catch (e) {
        AppLogger.w('Error converting OSM restaurant: $e');
      }
    }

    AppLogger.i('📊 Summary:');
    AppLogger.i('   Total from OpenStreetMap: ${restaurants.length}');
    final menuCount = restaurants.where((r) => r.hasMenu).length;
    AppLogger.i('   Restaurants with menus: $menuCount');
    AppLogger.i(
      '   Restaurants without menus: ${restaurants.length - menuCount}',
    );

    _sortByDistance(restaurants, latitude, longitude);
    final finalResults = restaurants.take(limit).toList();

    AppLogger.i(
      '🎯 FINAL RESULT: ${finalResults.length} restaurants from OpenStreetMap (FREE!)',
    );
    return finalResults;
  }

  Future<Set<String>> _fetchRestaurantsWithMenus(List<String> placeIds) async {
    return _cacheService.getRestaurantsWithMenus(placeIds);
  }

  void _sortByDistance(
    List<RestaurantModel> restaurants,
    double latitude,
    double longitude,
  ) {
    restaurants.sort((a, b) {
      final distanceA = _calculateDistance(
        latitude,
        longitude,
        a.latitude ?? 0,
        a.longitude ?? 0,
      );
      final distanceB = _calculateDistance(
        latitude,
        longitude,
        b.latitude ?? 0,
        b.longitude ?? 0,
      );
      return distanceA.compareTo(distanceB);
    });
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Future<List<RestaurantModel>> searchRestaurants({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  }) async {
    try {
      AppLogger.i('🔍 Searching restaurants for: "$query"');

      // Use Nominatim service for search (free and comprehensive)
      final searchResults = await nominatimService.searchByText(query: query);

      AppLogger.i(
        '✅ Nominatim search returned ${searchResults.length} results',
      );

      if (searchResults.isEmpty) {
        AppLogger.w('⚠️ No restaurants found for query: "$query"');
        return [];
      }

      // 🔥 OPTIMIZATION: Avoid N+1 queries. Fetch all menu statuses in one go.
      // 🔥 OPTİMİZASYON: N+1 sorgularından kaçının. Tüm menü durumlarını tek seferde alın.
      final placeIds = searchResults
          .map((p) => p.placeId)
          .where((id) => id.isNotEmpty)
          .toList();
      final restaurantsWithMenus = await _fetchRestaurantsWithMenus(placeIds);

      // Convert search results to RestaurantModel
      final restaurants = <RestaurantModel>[];

      for (final place in searchResults) {
        try {
          // Check against the pre-fetched set. No new DB query here.
          // Önceden getirilmiş sete göre kontrol edin. Burada yeni veritabanı sorgusu yok.
          final hasMenu = restaurantsWithMenus.contains(place.placeId);

          // Create RestaurantModel from search result
          final restaurant = RestaurantModel(
            id: 'osm_${place.placeId}',
            name: place.name,
            description: '',
            address: place.displayName,
            latitude: place.latitude,
            longitude: place.longitude,
            phoneNumber: '',
            website: '',
            imageUrls: [],
            rating: 4.0 + (place.name.hashCode.abs() % 10) / 10,
            reviewCount: (place.name.hashCode.abs() % 50) + 5,
            categories: _parseCuisineTypes(place.type ?? 'restaurant'),
            openingHours: {},
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            ownerId: '',
            hasMenu: hasMenu,
            placeId: place.placeId,
            geohash: '',
            district: place.displayName.contains(',')
                ? place.displayName.split(',').last.trim()
                : place.displayName.trim(),
            contributedBy: 'openstreetmap',
            isFromGooglePlaces: false,
            itemCount: hasMenu ? ((place.name.hashCode.abs() % 20) + 5) : 0,
            menuLinks: [],
          );

          restaurants.add(restaurant);
        } catch (e) {
          AppLogger.w('Error converting search result: $e');
        }
      }

      AppLogger.i('🎯 Search result: ${restaurants.length} restaurants');
      return restaurants;
    } catch (e) {
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        throw ServerException(ErrorMessages.noInternet);
      }
      throw ServerException(ErrorMessages.restaurantLoadFailed);
    }
  }

  @override
  Future<RestaurantModel> getRestaurantById(String id) async {
    try {
      AppLogger.i('🔍 getRestaurantById: Fetching restaurant with ID: $id');

      // Check if this is a Nominatim restaurant (starts with 'osm_')
      // TR: Nominatim restoranı mı kontrol et ('osm_' ile başlıyor mu)
      if (id.startsWith('osm_')) {
        AppLogger.i(
          '🌐 This is a Nominatim (OpenStreetMap) restaurant, getting details...',
        );

        // Extract the actual OSM Place ID (remove 'osm_' prefix)
        final osmId = id.substring(4);
        AppLogger.i('📍 OSM ID: $osmId');

        // Try to find in Firebase first (cached data)
        final cachedRestaurant = await _cacheService.getCachedRestaurant(osmId);
        if (cachedRestaurant != null) {
          return cachedRestaurant;
        }

        // Get detailed info from OpenStreetMap
        AppLogger.i('🔍 Fetching details from OpenStreetMap...');
        try {
          final osmDetails = await osmDetailsService.getRestaurantDetails(
            osmId,
          );

          AppLogger.i('📦 OSM Details: ${osmDetails?.keys.join(", ")}');

          if (osmDetails != null && osmDetails.isNotEmpty) {
            // Convert OSM data to RestaurantModel
            final restaurant = RestaurantModel(
              id: id,
              name: osmDetails['name'] ?? 'Bilinmeyen Restoran',
              description: osmDetails['description'] ?? '',
              address: osmDetails['address'] ?? '',
              latitude: osmDetails['latitude'] ?? 0.0,
              longitude: osmDetails['longitude'] ?? 0.0,
              phoneNumber: osmDetails['phone'] ?? '',
              website: osmDetails['website'] ?? '',
              imageUrls: [],
              rating: 4.0, // Default rating
              reviewCount: 0,
              categories: osmDetails['cuisine']?.split(';') ?? ['restaurant'],
              openingHours:
                  (osmDetails['opening_hours'] != null &&
                      (osmDetails['opening_hours'] as String).isNotEmpty)
                  ? {'general': osmDetails['opening_hours']}
                  : {},
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              ownerId: '',
              hasMenu: false,
              placeId: osmId,
              geohash: '',
              district:
                  (osmDetails['address_details'] != null &&
                      osmDetails['address_details']['suburb'] != null &&
                      (osmDetails['address_details']['suburb'] as String)
                          .isNotEmpty)
                  ? osmDetails['address_details']['suburb']
                  : (osmDetails['address_details'] != null &&
                        osmDetails['address_details']['neighbourhood'] !=
                            null &&
                        (osmDetails['address_details']['neighbourhood']
                                as String)
                            .isNotEmpty)
                  ? osmDetails['address_details']['neighbourhood']
                  : '',
              contributedBy: 'openstreetmap',
              isFromGooglePlaces: false,
              itemCount: 0,
              menuLinks: [],
            );

            // Cache in Firebase for future use
            await _cacheService.cacheRestaurant(restaurant);
            return restaurant;
          }
        } catch (e) {
          AppLogger.w('⚠️ Failed to fetch OSM details: $e');
        }

        // If OSM details not available, create a minimal restaurant from the ID
        // This allows the page to show something even if OSM lookup fails
        AppLogger.w(
          '⚠️ Restaurant details not available from OpenStreetMap, creating minimal restaurant',
        );
        return RestaurantModel(
          id: id,
          name: 'Restoran',
          description: 'Detaylar yükleniyor...',
          address: 'Adres bilgisi mevcut değil',
          latitude:
              null, // Use null instead of 0.0 to avoid map rendering issues
          longitude:
              null, // Use null instead of 0.0 to avoid map rendering issues
          phoneNumber: null,
          website: null,
          imageUrls: const [],
          rating: 4.0, // Provide a default rating instead of null
          reviewCount: 0,
          categories: const ['restaurant'],
          openingHours: const {},
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          ownerId: null,
          hasMenu: false,
          placeId: osmId,
          geohash: '',
          district: null,
          contributedBy: 'openstreetmap',
          isFromGooglePlaces: false,
          itemCount: 0,
          menuLinks: const [],
        );
      }

      // Regular Firebase restaurant
      AppLogger.i('🔥 This is a Firebase restaurant, querying Firestore...');
      final doc = await firestore.collection(AppConstants.restaurantsCollection).doc(id).get();

      if (!doc.exists) {
        AppLogger.w('⚠️ Restaurant not found in Firestore: $id');
        throw const NotFoundException(ErrorMessages.restaurantNotFound);
      }

      AppLogger.i('✅ Restaurant found in Firestore');
      return RestaurantModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      AppLogger.e('❌ getRestaurantById error', error: e);

      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        throw ServerException(ErrorMessages.noInternet);
      }

      throw ServerException(ErrorMessages.restaurantLoadFailed);
    }
  }

  @override
  Future<List<RestaurantModel>> getRestaurantsByOwnerId(String ownerId) async {
    try {
      final query = firestore
          .collection(AppConstants.restaurantsCollection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => RestaurantModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        throw ServerException(ErrorMessages.noInternet);
      }
      throw ServerException(ErrorMessages.restaurantLoadFailed);
    }
  }

  @override
  Future<RestaurantModel> createRestaurant(RestaurantModel restaurant) async {
    try {
      final docRef = firestore.collection(AppConstants.restaurantsCollection).doc(restaurant.id);
      final restaurantWithId = restaurant.copyWith(id: docRef.id);

      await docRef.set(restaurantWithId.toFirestore());

      return restaurantWithId;
    } catch (e) {
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        throw ServerException(ErrorMessages.noInternet);
      }
      throw ServerException(ErrorMessages.operationFailed);
    }
  }

  @override
  Future<RestaurantModel> updateRestaurant(RestaurantModel restaurant) async {
    try {
      await firestore
          .collection(AppConstants.restaurantsCollection)
          .doc(restaurant.id)
          .update(restaurant.toFirestore());

      return restaurant;
    } catch (e) {
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        throw ServerException(ErrorMessages.noInternet);
      }
      throw ServerException(ErrorMessages.operationFailed);
    }
  }

  @override
  Future<void> deleteRestaurant(String id) async {
    try {
      await firestore.collection(AppConstants.restaurantsCollection).doc(id).delete();
    } catch (e) {
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        throw ServerException(ErrorMessages.noInternet);
      }
      throw ServerException(ErrorMessages.operationFailed);
    }
  }

  @override
  Future<List<RestaurantModel>> getPopularRestaurants({int limit = 10}) async {
    try {
      final query = firestore
          .collection(AppConstants.restaurantsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('reviewCount', descending: true)
          .orderBy('rating', descending: true)
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => RestaurantModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        throw ServerException(ErrorMessages.noInternet);
      }
      throw ServerException(ErrorMessages.restaurantLoadFailed);
    }
  }

  @override
  Future<List<RestaurantModel>> getRestaurantsByCategory({
    required String category,
    int limit = 20,
  }) async {
    try {
      final query = firestore
          .collection(AppConstants.restaurantsCollection)
          .where('categories', arrayContains: category)
          .where('isActive', isEqualTo: true)
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => RestaurantModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        throw ServerException(ErrorMessages.noInternet);
      }
      throw ServerException(ErrorMessages.restaurantLoadFailed);
    }
  }

  /// Convert Nominatim place to RestaurantModel
  /// TR: Nominatim yerini RestaurantModel'e dönüştür
  ///
  /// Replaces: _convertGooglePlaceToRestaurant
  /// Değiştirir: _convertGooglePlaceToRestaurant
  RestaurantModel _convertPlaceResultToRestaurantModel(
    PlaceResult place, {
    bool hasMenu = false,
  }) {
    // Extract categories from type
    // Tipten kategorileri çıkar
    final categories = [place.type];

    // Use OSM place_id as the restaurant ID (with prefix to avoid conflicts)
    // OSM place_id'yi restoran ID'si olarak kullan (çakışmaları önlemek için prefix ile)
    final restaurantId = place.placeId;

    // Get city and district from address
    // // Adresten şehir ve ilçe al
    // final city = place.address?['city'] ?? place.address?['town'] ?? place.address?['village'];
    // final district = place.address?['suburb'] ?? place.address?['district'];

    return RestaurantModel(
      id: restaurantId,
      name: place.name,
      description: null,
      address: place.displayName,
      latitude: place.latitude,
      longitude: place.longitude,
      phoneNumber: null, // Nominatim doesn't provide phone numbers
      website: null, // Nominatim doesn't provide websites
      imageUrls: [], // Nominatim doesn't provide images
      rating: null, // Nominatim doesn't provide ratings
      reviewCount: 0,
      categories: categories,
      openingHours: {}, // Nominatim doesn't provide opening hours
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: null,
      ownerId: null,
      hasMenu: hasMenu, // Menu var mı?
      placeId: place.placeId,
      geohash: '',
      lastSyncedAt: DateTime.now(),
      city: '',
      district: '',
      contributedBy: 'nominatim',
      isFromGooglePlaces: false, // Now from OpenStreetMap!
      itemCount: 0,
      menuLinks: [],
    );
  }

  @override
  Future<List<PlaceResult>> searchRestaurantsFromFirestore(
    String query, {
    int limit = 10,
  }) async {
    // This method seems to be part of a fallback strategy.
    // For now, we return an empty list as the primary search is handled by Nominatim/Overpass.
    return [];
  }

  /// Parse cuisine types from OSM data
  List<String> _parseCuisineTypes(String cuisine) {
    if (cuisine.isEmpty) return ['restaurant'];

    final types = cuisine
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (types.isEmpty) return ['restaurant'];

    // Map common OSM cuisine types to Turkish
    final Map<String, String> cuisineMap = {
      'turkish': 'Türk Mutfağı',
      'kebab': 'Kebap',
      'pizza': 'Pizza',
      'burger': 'Burger',
      'italian': 'İtalyan',
      'chinese': 'Çin Mutfağı',
      'indian': 'Hint Mutfağı',
      'seafood': 'Deniz Ürünleri',
      'fast_food': 'Fast Food',
      'cafe': 'Kafe',
      'restaurant': 'Restoran',
    };

    return types.map((type) => cuisineMap[type.toLowerCase()] ?? type).toList();
  }

  /// Parse opening hours from OSM format
  Map<String, String> _parseOpeningHours(String openingHours) {
    if (openingHours.isEmpty) return {};

    // Simple parsing for common formats like "Mo-Su 09:00-22:00"
    if (openingHours.contains('Mo-Su') || openingHours.contains('24/7')) {
      return {
        'monday': openingHours,
        'tuesday': openingHours,
        'wednesday': openingHours,
        'thursday': openingHours,
        'friday': openingHours,
        'saturday': openingHours,
        'sunday': openingHours,
      };
    }

    return {'general': openingHours};
  }
}
