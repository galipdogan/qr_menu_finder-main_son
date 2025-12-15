import 'dart:async'; // Add this import
import 'dart:convert';
// import 'dart:math'; // Removed
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/models/place_result.dart';

abstract class NominatimRemoteDataSource {
  Future<List<PlaceResult>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 10,
  });
  Future<PlaceResult?> reverseGeocode(LatLng location);
}

/// OpenStreetMap Nominatim geocoding service implementation
class NominatimRemoteDataSourceImpl implements NominatimRemoteDataSource {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'QRMenuFinder/1.0';

  final http.Client client; // Add http.Client dependency

  NominatimRemoteDataSourceImpl({required this.client}); // Update constructor

  /// Search for places by query using Nominatim API (similar to PlacesService._searchWithNominatim)
  @override
  Future<List<PlaceResult>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 10,
  }) async {
    if (query.isEmpty || query.length < 2) return [];

    final params = {
      'q': query,
      'format': 'json',
      'addressdetails': '1',
      'limit': limit.toString(),
      'accept-language': 'tr,en',
      if (latitude != null && longitude != null) ...{
        'viewbox': _createViewBox(latitude, longitude, 10), // 10km radius
        'bounded': '1',
      },
    };

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);

    try {
      AppLogger.i('🔍 Searching with Nominatim API: $query');

      final response = await client
          .get(
            uri,
            headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
          )
          .timeout(
            const Duration(
              seconds: 15,
            ), // Nominatim is slower, give it more time
            onTimeout: () {
              AppLogger.w('⏰ Nominatim API timeout for query: $query');
              throw TimeoutException('Nominatim API timeout after 15 seconds');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        AppLogger.i(
          '✅ Nominatim API returned ${data.length} results for: $query',
        );

        return data
            .map((item) => PlaceResult.fromJson(item))
            .where((place) => place.name.isNotEmpty)
            .toList();
      } else {
        AppLogger.w(
          '❌ Nominatim API error ${response.statusCode} for query: $query',
        );
        throw Exception(
          'Nominatim API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      AppLogger.e(
        '🚨 Nominatim API request failed for query: $query',
        error: e,
      );
      rethrow;
    }
  }

  /// Reverse geocode (get address from coordinates)
  @override
  Future<PlaceResult?> reverseGeocode(LatLng location) async {
    try {
      final uri = Uri.parse('$_baseUrl/reverse').replace(
        queryParameters: {
          'lat': location.latitude.toString(),
          'lon': location.longitude.toString(),
          'format': 'json',
          'addressdetails': '1',
        },
      );

      final response = await client.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PlaceResult.fromJson(data);
      } else {
        AppLogger.w('Reverse geocoding failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.e('Error reverse geocoding: $e');
      return null;
    }
  }

  /// ViewBox oluştur (koordinat etrafında kare alan)
  String _createViewBox(double lat, double lon, double radiusKm) {
    const double kmToDegree = 0.009; // Yaklaşık 1km = 0.009 derece
    final double offset = radiusKm * kmToDegree;

    final double left = lon - offset;
    final double bottom = lat - offset;
    final double right = lon + offset;
    final double top = lat + offset;

    return '$left,$bottom,$right,$top';
  }
}
