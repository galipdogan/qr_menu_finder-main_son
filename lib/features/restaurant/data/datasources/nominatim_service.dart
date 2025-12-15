import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;
import '../../../../core/error/exceptions.dart';

/// Nominatim (OpenStreetMap) service for free geocoding and place search
/// TR: Ãœcretsiz geocoding ve yer arama iÃ§in Nominatim (OpenStreetMap) servisi
/// 
/// This replaces Google Places API with free OpenStreetMap data
/// Bu, Google Places API'yi Ã¼cretsiz OpenStreetMap verisiyle deÄŸiÅŸtirir
/// 
/// Rate Limits / HÄ±z Limitleri:
/// - 1 request per second / saniyede 1 istek
/// - User-Agent header required / User-Agent header'Ä± gerekli
/// 
/// Cost: FREE âœ… / Maliyet: ÃœCRETSÄ°Z âœ…
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'QRMenuFinder/1.0 (Flutter App)';
  
  final http.Client _client;
  DateTime? _lastRequestTime;
  
  // Cache for search results
  static final Map<String, List<NominatimPlace>> _searchCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 15);
  
  NominatimService({http.Client? client}) : _client = client ?? http.Client();

  /// Enforce rate limit (1 request per second)
  /// TR: HÄ±z limitini uygula (saniyede 1 istek)
  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest.inMilliseconds < 1000) {
        final waitTime = 1000 - timeSinceLastRequest.inMilliseconds;
        debugPrint('Rate limit: waiting ${waitTime}ms');
        await Future.delayed(Duration(milliseconds: waitTime));
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Search for places (restaurants) near a location
  /// TR: Bir konumun yakÄ±nÄ±ndaki yerleri (restoranlarÄ±) ara
  /// 
  /// Replaces: Google Places Nearby Search
  /// DeÄŸiÅŸtirir: Google Places Nearby Search
  Future<List<NominatimPlace>> searchNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String query = 'restaurant',
    int limit = 20,
  }) async {
    try {
      // Check cache first
      final cacheKey = '${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}_${radiusKm}_$query';
      final cached = _getCachedPlaces(cacheKey);
      if (cached != null) {
        debugPrint('Using cached Nominatim results (${cached.length} places)');
        return cached.take(limit).toList();
      }

      await _enforceRateLimit();

      debugPrint('Nominatim: Searching nearby places...');
      debugPrint('Location: $latitude, $longitude');
      debugPrint('Radius: ${radiusKm}km, Query: $query');

      // Calculate bounding box / SÄ±nÄ±rlayÄ±cÄ± kutu hesapla
      final latDelta = radiusKm / 111.0; // 1 degree â‰ˆ 111 km
      final lngDelta = radiusKm / (111.0 * cos(latitude * pi / 180));

      final params = {
        'format': 'json',
        'q': query,
        'limit': limit.toString(),
        'addressdetails': '1',
        'bounded': '1',
        'viewbox': '${longitude - lngDelta},${latitude + latDelta},${longitude + lngDelta},${latitude - latDelta}',
        'accept-language': 'tr,en', // Turkish and English
      };

      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);
      
      debugPrint('Request URL: $uri');

      final response = await _client.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        debugPrint('âœ… Nominatim returned ${results.length} results');

        final places = results
            .map((r) => NominatimPlace.fromJson(r as Map<String, dynamic>))
            .toList();

        // Filter by distance / Mesafeye gÃ¶re filtrele
        final filteredPlaces = places.where((place) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            place.latitude,
            place.longitude,
          );
          return distance <= radiusKm * 1000; // Convert km to meters
        }).toList();

        // Sort by distance / Mesafeye gÃ¶re sÄ±rala
        filteredPlaces.sort((a, b) {
          final distA = _calculateDistance(latitude, longitude, a.latitude, a.longitude);
          final distB = _calculateDistance(latitude, longitude, b.latitude, b.longitude);
          return distA.compareTo(distB);
        });

        debugPrint('Filtered to ${filteredPlaces.length} places within ${radiusKm}km');
        
        // Cache the results
        _cachePlaces(cacheKey, filteredPlaces);
        
        return filteredPlaces;
      } else if (response.statusCode == 429) {
        debugPrint('Rate limit exceeded');
        throw ServerException('Rate limit exceeded. Please try again later.');
      } else {
        debugPrint('Nominatim error: ${response.statusCode}');
        throw ServerException('Nominatim search failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Nominatim search error: $e');
      throw ServerException('Failed to search nearby places: $e');
    }
  }

  /// Search for places by text query
  /// TR: Metin sorgusuyla yer ara
  /// 
  /// Replaces: Google Places Text Search
  /// DeÄŸiÅŸtirir: Google Places Text Search
  Future<List<NominatimPlace>> searchByText({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 20,
  }) async {
    try {
      // Check cache first
      final cacheKey = 'text_${query}_${latitude?.toStringAsFixed(3) ?? 'null'}_${longitude?.toStringAsFixed(3) ?? 'null'}';
      final cached = _getCachedPlaces(cacheKey);
      if (cached != null) {
        debugPrint('Using cached text search results (${cached.length} places)');
        return cached.take(limit).toList();
      }

      await _enforceRateLimit();

      debugPrint('Nominatim: Text search for "$query"');

      final params = {
        'format': 'json',
        'q': '$query restaurant', // Add "restaurant" to improve results
        'limit': limit.toString(),
        'addressdetails': '1',
        'accept-language': 'tr,en',
      };

      // Add location bias if provided / Konum Ã¶nyargÄ±sÄ± ekle
      if (latitude != null && longitude != null) {
        params['lat'] = latitude.toString();
        params['lon'] = longitude.toString();
      }

      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);

      final response = await _client.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        debugPrint('âœ… Nominatim returned ${results.length} results');

        final places = results
            .map((r) => NominatimPlace.fromJson(r as Map<String, dynamic>))
            .toList();
        
        // Cache the results
        _cachePlaces(cacheKey, places);
        
        return places;
      } else if (response.statusCode == 429) {
        throw ServerException('Rate limit exceeded. Please try again later.');
      } else {
        throw ServerException('Nominatim search failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Nominatim text search error: $e');
      throw ServerException('Failed to search places: $e');
    }
  }

  /// Autocomplete place search
  /// TR: Yer arama otomatik tamamlama
  /// 
  /// Replaces: Google Places Autocomplete
  /// DeÄŸiÅŸtirir: Google Places Autocomplete
  Future<List<String>> autocomplete({
    required String input,
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (input.length < 3) return []; // Minimum 3 characters

      await _enforceRateLimit();

      debugPrint('Nominatim: Autocomplete for "$input"');

      final params = {
        'format': 'json',
        'q': '$input restaurant',
        'limit': '5',
        'addressdetails': '0',
        'accept-language': 'tr,en',
      };

      if (latitude != null && longitude != null) {
        params['lat'] = latitude.toString();
        params['lon'] = longitude.toString();
      }

      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);

      final response = await _client.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        
        // Extract unique display names / Benzersiz gÃ¶rÃ¼nen adlarÄ± Ã§Ä±kar
        final suggestions = results
            .map((r) => r['display_name'] as String)
            .toSet()
            .toList();

        debugPrint('Nominatim returned ${suggestions.length} suggestions');
        return suggestions;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Nominatim autocomplete error: $e');
      return [];
    }
  }

  /// Reverse geocoding (get address from coordinates)
  /// TR: Ters geocoding (koordinatlardan adres al)
  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _enforceRateLimit();

      debugPrint('Nominatim: Reverse geocoding $latitude, $longitude');

      final params = {
        'format': 'json',
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'accept-language': 'tr,en',
      };

      final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: params);

      final response = await _client.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final address = result['display_name'] as String?;
        debugPrint('Reverse geocoding result: $address');
        return address;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  /// TR: Ä°ki koordinat arasÄ±ndaki mesafeyi hesapla (Haversine formÃ¼lÃ¼)
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

  /// Cache management methods
  List<NominatimPlace>? _getCachedPlaces(String cacheKey) {
    final cache = _searchCache[cacheKey];
    final timestamp = _cacheTimestamps[cacheKey];

    if (cache == null || timestamp == null) {
      return null;
    }

    if (DateTime.now().difference(timestamp) >= _cacheExpiry) {
      _searchCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
      return null;
    }

    return cache;
  }

  void _cachePlaces(String cacheKey, List<NominatimPlace> places) {
    if (places.isEmpty) return;
    _searchCache[cacheKey] = places;
    _cacheTimestamps[cacheKey] = DateTime.now();
    debugPrint('Cached ${places.length} places for ${_cacheExpiry.inMinutes} minutes');
  }

  /// Clear all caches
  static void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
    debugPrint('Nominatim cache cleared');
  }

  /// Dispose resources / KaynaklarÄ± temizle
  void dispose() {
    _client.close();
  }
}

/// Nominatim place model
/// TR: Nominatim yer modeli
class NominatimPlace {
  final String placeId;
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;
  final String? type;
  final String? category;
  final Map<String, dynamic>? address;

  NominatimPlace({
    required this.placeId,
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.type,
    this.category,
    this.address,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      placeId: json['place_id'].toString(),
      name: json['name'] ?? json['display_name'] ?? 'Unknown',
      displayName: json['display_name'] ?? '',
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      type: json['type'] as String?,
      category: json['category'] as String?,
      address: json['address'] as Map<String, dynamic>?,
    );
  }

  /// Get city from address / Adresten ÅŸehir al
  String? get city {
    if (address == null) return null;
    return address!['city'] as String? ??
        address!['town'] as String? ??
        address!['village'] as String?;
  }

  /// Get district from address / Adresten ilÃ§e al
  String? get district {
    if (address == null) return null;
    return address!['suburb'] as String? ??
        address!['neighbourhood'] as String? ??
        address!['quarter'] as String?;
  }

  /// Get street address / Sokak adresini al
  String? get street {
    if (address == null) return null;
    final road = address!['road'] as String?;
    final houseNumber = address!['house_number'] as String?;
    if (road != null && houseNumber != null) {
      return '$road No:$houseNumber';
    }
    return road;
  }
}
