import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/app_logger.dart';

abstract class OpenStreetMapDetailsRemoteDataSource {
  Future<Map<String, dynamic>?> getRestaurantDetails(String osmId);
  Future<List<Map<String, dynamic>>> getNearbyRestaurantsWithDetails({
    required double latitude,
    required double longitude,
    double radiusKm = 1.0,
    int limit = 20,
  });
}

/// OpenStreetMap Overpass API kullanarak restoran detaylarını getiren servis implementasyonu
class OpenStreetMapDetailsRemoteDataSourceImpl
    implements OpenStreetMapDetailsRemoteDataSource {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'QRMenuFinder/1.0';

  /// OSM Place ID'sine göre restoran detaylarını getir
  @override
  Future<Map<String, dynamic>?> getRestaurantDetails(String osmId) async {
    try {
      AppLogger.i('🔍 Getting restaurant details for OSM ID: $osmId');

      // Önce Nominatim'den temel bilgileri al
      final nominatimDetails = await _getNominatimDetails(osmId);
      AppLogger.i('📍 Nominatim details: ${nominatimDetails.keys.join(", ")}');

      // Sonra Overpass API'den detaylı bilgileri al
      final overpassDetails = await _getOverpassDetails(osmId);
      AppLogger.i('🔧 Overpass details: ${overpassDetails.keys.join(", ")}');

      // İki kaynağı birleştir
      final combinedDetails = <String, dynamic>{
        ...nominatimDetails,
        ...overpassDetails,
      };

      AppLogger.i(
        '✅ Combined details (${combinedDetails.length} keys): ${combinedDetails.keys.join(", ")}',
      );
      return combinedDetails.isNotEmpty ? combinedDetails : null;
    } catch (e) {
      AppLogger.e('❌ Error getting restaurant details: $e');
      return null;
    }
  }

  /// Nominatim'den temel bilgileri al
  Future<Map<String, dynamic>> _getNominatimDetails(String osmId) async {
    try {
      // OSM ID formatını kontrol et (node, way, relation)
      String osmType = 'node';
      String cleanId = osmId;

      if (osmId.startsWith('N')) {
        osmType = 'node';
        cleanId = osmId.substring(1);
      } else if (osmId.startsWith('W')) {
        osmType = 'way';
        cleanId = osmId.substring(1);
      } else if (osmId.startsWith('R')) {
        osmType = 'relation';
        cleanId = osmId.substring(1);
      }

      // Nominatim lookup requires format like: N123, W456, R789
      final osmTypePrefix = osmType == 'node'
          ? 'N'
          : (osmType == 'way' ? 'W' : 'R');
      final url =
          '$_nominatimUrl/lookup?osm_ids=$osmTypePrefix$cleanId&format=json&addressdetails=1&extratags=1';

      AppLogger.i('🔗 Nominatim URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final place = data[0];
          return {
            'name':
                place['display_name']?.split(',')[0] ?? 'Bilinmeyen Restoran',
            'address': place['display_name'] ?? '',
            'latitude': double.tryParse(place['lat']?.toString() ?? '0') ?? 0.0,
            'longitude':
                double.tryParse(place['lon']?.toString() ?? '0') ?? 0.0,
            'place_id': place['place_id']?.toString() ?? '',
            'osm_type': place['osm_type'] ?? osmType,
            'osm_id': place['osm_id']?.toString() ?? cleanId,
            'category': place['category'] ?? 'amenity',
            'type': place['type'] ?? 'restaurant',
            'importance': place['importance'] ?? 0.5,
            'extratags': place['extratags'] ?? {},
            'address_details': place['address'] ?? {},
          };
        }
      }

      return {};
    } catch (e) {
      AppLogger.w('⚠️ Nominatim lookup failed: $e');
      return {};
    }
  }

  /// Overpass API'den detaylı bilgileri al
  Future<Map<String, dynamic>> _getOverpassDetails(String osmId) async {
    try {
      // OSM ID formatını ayarla
      String osmType = 'node';
      String cleanId = osmId;

      if (osmId.startsWith('N')) {
        osmType = 'node';
        cleanId = osmId.substring(1);
      } else if (osmId.startsWith('W')) {
        osmType = 'way';
        cleanId = osmId.substring(1);
      } else if (osmId.startsWith('R')) {
        osmType = 'relation';
        cleanId = osmId.substring(1);
      }

      // Overpass QL sorgusu - restoran detaylarını al
      final query =
          '''
[out:json][timeout:25];
(
  $osmType($cleanId);
);
out tags;
''';

      final response = await http
          .post(
            Uri.parse(_overpassUrl),
            headers: {
              'User-Agent': _userAgent,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'data=${Uri.encodeComponent(query)}',
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List<dynamic>?;

        if (elements != null && elements.isNotEmpty) {
          final tags = elements[0]['tags'] as Map<String, dynamic>? ?? {};

          return {
            'phone': tags['phone'] ?? tags['contact:phone'] ?? '',
            'website': tags['website'] ?? tags['contact:website'] ?? '',
            'email': tags['email'] ?? tags['contact:email'] ?? '',
            'opening_hours': tags['opening_hours'] ?? '',
            'cuisine': tags['cuisine'] ?? '',
            'diet': _parseDietaryOptions(tags),
            'payment': _parsePaymentOptions(tags),
            'accessibility': _parseAccessibility(tags),
            'amenities': _parseAmenities(tags),
            'capacity': tags['capacity'] ?? '',
            'outdoor_seating': tags['outdoor_seating'] == 'yes',
            'takeaway': tags['takeaway'] == 'yes',
            'delivery': tags['delivery'] == 'yes',
            'reservation': tags['reservation'] == 'yes',
            'smoking': tags['smoking'] ?? 'no',
            'internet_access': tags['internet_access'] ?? '',
            'wifi': tags['wifi'] == 'yes' || tags['internet_access'] == 'wlan',
            'parking': tags['parking'] ?? '',
            'level': tags['level'] ?? '0',
            'operator': tags['operator'] ?? tags['brand'] ?? '',
            'description': tags['description'] ?? '',
            'note': tags['note'] ?? '',
            'all_tags': tags,
          };
        }
      }

      return {};
    } catch (e) {
      AppLogger.w('⚠️ Overpass API failed: $e');
      return {};
    }
  }

  /// Diyet seçeneklerini parse et
  List<String> _parseDietaryOptions(Map<String, dynamic> tags) {
    final dietary = <String>[];

    if (tags['diet:vegetarian'] == 'yes') dietary.add('Vejetaryen');
    if (tags['diet:vegan'] == 'yes') dietary.add('Vegan');
    if (tags['diet:halal'] == 'yes') dietary.add('Helal');
    if (tags['diet:kosher'] == 'yes') dietary.add('Koşer');
    if (tags['diet:gluten_free'] == 'yes') dietary.add('Glutensiz');

    return dietary;
  }

  /// Ödeme seçeneklerini parse et
  List<String> _parsePaymentOptions(Map<String, dynamic> tags) {
    final payment = <String>[];

    if (tags['payment:cash'] == 'yes') payment.add('Nakit');
    if (tags['payment:cards'] == 'yes') payment.add('Kart');
    if (tags['payment:contactless'] == 'yes') payment.add('Temassız');
    if (tags['payment:mobile_payment'] == 'yes') payment.add('Mobil Ödeme');

    return payment;
  }

  /// Erişilebilirlik bilgilerini parse et
  Map<String, bool> _parseAccessibility(Map<String, dynamic> tags) {
    return {
      'wheelchair': tags['wheelchair'] == 'yes',
      'wheelchair_toilet': tags['toilets:wheelchair'] == 'yes',
      'hearing_loop': tags['hearing_loop'] == 'yes',
      'tactile_paving': tags['tactile_paving'] == 'yes',
    };
  }

  /// Olanakları parse et
  List<String> _parseAmenities(Map<String, dynamic> tags) {
    final amenities = <String>[];

    if (tags['toilets'] == 'yes') amenities.add('Tuvalet');
    if (tags['baby_feeding'] == 'yes') amenities.add('Bebek Bakım');
    if (tags['highchair'] == 'yes') amenities.add('Mama Sandalyesi');
    if (tags['changing_table'] == 'yes') amenities.add('Alt Değiştirme');
    if (tags['air_conditioning'] == 'yes') amenities.add('Klima');
    if (tags['outdoor_seating'] == 'yes') amenities.add('Dış Mekan');

    return amenities;
  }

  /// Yakındaki restoranları detaylarıyla birlikte getir
  @override
  Future<List<Map<String, dynamic>>> getNearbyRestaurantsWithDetails({
    required double latitude,
    required double longitude,
    double radiusKm = 1.0,
    int limit = 20,
  }) async {
    try {
      AppLogger.i('🔍 Getting nearby restaurants with details');

      // Overpass QL sorgusu - yakındaki restoranları al
      final query =
          '''
[out:json][timeout:15];
(
  node["amenity"="restaurant"](around:${radiusKm * 1000},$latitude,$longitude);
  way["amenity"="restaurant"](around:${radiusKm * 1000},$latitude,$longitude);
  node["amenity"="fast_food"](around:${radiusKm * 1000},$latitude,$longitude);
  way["amenity"="fast_food"](around:${radiusKm * 1000},$latitude,$longitude);
  node["amenity"="cafe"](around:${radiusKm * 1000},$latitude,$longitude);
  way["amenity"="cafe"](around:${radiusKm * 1000},$latitude,$longitude);
);
out tags geom;
''';

      final response = await http
          .post(
            Uri.parse(_overpassUrl),
            headers: {
              'User-Agent': _userAgent,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'data=${Uri.encodeComponent(query)}',
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List<dynamic>? ?? [];

        final restaurants = <Map<String, dynamic>>[];

        for (final element in elements.take(limit)) {
          final tags = element['tags'] as Map<String, dynamic>? ?? {};
          final lat = element['lat'] ?? element['center']?['lat'] ?? 0.0;
          final lon = element['lon'] ?? element['center']?['lon'] ?? 0.0;

          if (tags['name'] != null && lat != 0.0 && lon != 0.0) {
            restaurants.add({
              'id':
                  'osm_${element['type']?.substring(0, 1).toUpperCase()}${element['id']}',
              'name': tags['name'] ?? 'Bilinmeyen Restoran',
              'latitude': double.tryParse(lat.toString()) ?? 0.0,
              'longitude': double.tryParse(lon.toString()) ?? 0.0,
              'address': _buildAddress(tags),
              'phone': tags['phone'] ?? tags['contact:phone'] ?? '',
              'website': tags['website'] ?? tags['contact:website'] ?? '',
              'cuisine': tags['cuisine'] ?? '',
              'opening_hours': tags['opening_hours'] ?? '',
              'amenity': tags['amenity'] ?? 'restaurant',
              'takeaway': tags['takeaway'] == 'yes',
              'delivery': tags['delivery'] == 'yes',
              'outdoor_seating': tags['outdoor_seating'] == 'yes',
              'wifi':
                  tags['wifi'] == 'yes' || tags['internet_access'] == 'wlan',
              'wheelchair': tags['wheelchair'] == 'yes',
              'osm_type': element['type'],
              'osm_id': element['id'].toString(),
              'all_tags': tags,
            });
          }
        }

        AppLogger.i('✅ Found ${restaurants.length} restaurants with details');
        return restaurants;
      }

      return [];
    } catch (e) {
      AppLogger.e('❌ Error getting nearby restaurants: $e');
      return [];
    }
  }

  /// Adres bilgisini oluştur
  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];

    if (tags['addr:street'] != null) {
      parts.add(tags['addr:street']);
      if (tags['addr:housenumber'] != null) {
        parts[parts.length - 1] += ' ${tags['addr:housenumber']}';
      }
    }

    if (tags['addr:neighbourhood'] != null) {
      parts.add(tags['addr:neighbourhood']);
    }
    if (tags['addr:district'] != null) parts.add(tags['addr:district']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);

    return parts.join(', ');
  }
}
