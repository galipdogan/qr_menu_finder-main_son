import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/app_logger.dart';

abstract class TurkeyLocationRemoteDataSource {
  List<String> getMajorCities();
  Map<String, double>? getCityCoordinates(String cityName);
  Future<List<String>> getDistricts(String cityName);
  Future<List<String>> getNeighborhoods(String cityName, String districtName);
  Future<Map<String, double>?> getCoordinatesForLocation({
    required String city,
    String? district,
    String? neighborhood,
  });
}

/// Türkiye il, ilçe, mahalle bilgileri servisi implementasyonu
class TurkeyLocationRemoteDataSourceImpl implements TurkeyLocationRemoteDataSource {
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'QRMenuFinder/1.0';

  // Türkiye'nin büyük şehirleri ve koordinatları
  static const Map<String, Map<String, double>> _majorCities = {
    'İstanbul': {'lat': 41.0082, 'lng': 28.9784},
    'Ankara': {'lat': 39.9334, 'lng': 32.8597},
    'İzmir': {'lat': 38.4192, 'lng': 27.1287},
    'Bursa': {'lat': 40.1826, 'lng': 29.0665},
    'Antalya': {'lat': 36.8969, 'lng': 30.7133},
    'Adana': {'lat': 37.0000, 'lng': 35.3213},
    'Konya': {'lat': 37.8667, 'lng': 32.4833},
    'Gaziantep': {'lat': 37.0662, 'lng': 37.3833},
    'Mersin': {'lat': 36.8000, 'lng': 34.6333},
    'Diyarbakır': {'lat': 37.9144, 'lng': 40.2306},
    'Kayseri': {'lat': 38.7312, 'lng': 35.4787},
    'Eskişehir': {'lat': 39.7767, 'lng': 30.5206},
    'Urfa': {'lat': 37.1591, 'lng': 38.7969},
    'Malatya': {'lat': 38.3552, 'lng': 38.3095},
    'Trabzon': {'lat': 41.0015, 'lng': 39.7178},
    'Erzurum': {'lat': 39.9000, 'lng': 41.2700},
    'Van': {'lat': 38.4891, 'lng': 43.4089},
    'Samsun': {'lat': 41.2928, 'lng': 36.3313},
    'Denizli': {'lat': 37.7765, 'lng': 29.0864},
    'Sakarya': {'lat': 40.6940, 'lng': 30.4358},
  };

  /// Büyük şehirlerin listesini getir
  @override
  List<String> getMajorCities() {
    return _majorCities.keys.toList()..sort();
  }

  /// Şehir koordinatlarını getir
  @override
  Map<String, double>? getCityCoordinates(String cityName) {
    return _majorCities[cityName];
  }

  /// Nominatim'den ilçeleri getir
  @override
  Future<List<String>> getDistricts(String cityName) async {
    try {
      AppLogger.i('🔍 Getting districts for: $cityName');

      final url = '$_nominatimUrl/search?q=$cityName,Turkey&format=json&addressdetails=1&limit=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Get city's bounding box and search for districts


          
          // Search for districts in the city
          final districtUrl = '$_nominatimUrl/search?q=district,$cityName,Turkey&format=json&limit=20';
          
          final districtResponse = await http.get(
            Uri.parse(districtUrl),
            headers: {'User-Agent': _userAgent},
          ).timeout(const Duration(seconds: 10));

          if (districtResponse.statusCode == 200) {
            final List<dynamic> districtData = json.decode(districtResponse.body);
            final districts = districtData
                .map((d) => d['display_name']?.toString().split(',')[0] ?? '')
                .where((name) => name.isNotEmpty)
                .toSet()
                .toList();
            
            districts.sort();
            AppLogger.i('✅ Found ${districts.length} districts for $cityName');
            return districts;
          }
        }
      }
      
      // Fallback districts for major cities
      return _getFallbackDistricts(cityName);
    } catch (e) {
      AppLogger.w('⚠️ Error getting districts: $e');
      return _getFallbackDistricts(cityName);
    }
  }

  /// Nominatim'den mahalleleri getir
  @override
  Future<List<String>> getNeighborhoods(String cityName, String districtName) async {
    try {
      AppLogger.i('🔍 Getting neighborhoods for: $districtName, $cityName');

      final url = '$_nominatimUrl/search?q=$districtName,$cityName,Turkey&format=json&addressdetails=1&limit=10';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final neighborhoods = data
            .where((item) => item['address'] != null)
            .map((item) {
              final address = item['address'] as Map<String, dynamic>;
              return address['neighbourhood'] ?? 
                     address['suburb'] ?? 
                     address['quarter'] ?? '';
            })
            .where((name) => name.toString().isNotEmpty)
            .map((name) => name.toString())
            .toSet()
            .toList();
        
        neighborhoods.sort();
        AppLogger.i('✅ Found ${neighborhoods.length} neighborhoods');
        return neighborhoods;
      }
      
      return [];
    } catch (e) {
      AppLogger.w('⚠️ Error getting neighborhoods: $e');
      return [];
    }
  }

  /// Seçilen konum için koordinatları getir
  @override
  Future<Map<String, double>?> getCoordinatesForLocation({
    required String city,
    String? district,
    String? neighborhood,
  }) async {
    try {
      // Build search query
      final queryParts = <String>[];
      if (neighborhood != null && neighborhood.isNotEmpty) {
        queryParts.add(neighborhood);
      }
      if (district != null && district.isNotEmpty) {
        queryParts.add(district);
      }
      queryParts.add(city);
      queryParts.add('Turkey');
      
      final query = queryParts.join(',');
      AppLogger.i('🔍 Getting coordinates for: $query');

      final url = '$_nominatimUrl/search?q=${Uri.encodeComponent(query)}&format=json&limit=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          final coordinates = {
            'lat': double.parse(location['lat']),
            'lng': double.parse(location['lon']),
          };
          
          AppLogger.i('✅ Coordinates found: ${coordinates['lat']}, ${coordinates['lng']}');
          return coordinates;
        }
      }
      
      // Fallback to city coordinates
      return getCityCoordinates(city);
    } catch (e) {
      AppLogger.w('⚠️ Error getting coordinates: $e');
      return getCityCoordinates(city);
    }
  }

  /// Fallback ilçeler (büyük şehirler için)
  List<String> _getFallbackDistricts(String cityName) {
    final Map<String, List<String>> fallbackDistricts = {
      'İstanbul': [
        'Kadıköy', 'Beşiktaş', 'Şişli', 'Beyoğlu', 'Fatih', 'Üsküdar',
        'Bakırköy', 'Zeytinburnu', 'Kağıthane', 'Sarıyer', 'Maltepe',
        'Pendik', 'Kartal', 'Ataşehir', 'Çekmeköy', 'Sancaktepe'
      ],
      'Ankara': [
        'Çankaya', 'Keçiören', 'Yenimahalle', 'Mamak', 'Sincan',
        'Etimesgut', 'Altındağ', 'Gölbaşı', 'Pursaklar', 'Elmadağ'
      ],
      'İzmir': [
        'Konak', 'Karşıyaka', 'Bornova', 'Alsancak', 'Bostanlı',
        'Gaziemir', 'Balçova', 'Narlıdere', 'Güzelbahçe', 'Foça'
      ],
      'Bursa': [
        'Osmangazi', 'Nilüfer', 'Yıldırım', 'Mudanya', 'Gemlik',
        'İnegöl', 'Orhangazi', 'Kestel', 'Gürsu', 'Karacabey'
      ],
      'Antalya': [
        'Muratpaşa', 'Kepez', 'Konyaaltı', 'Döşemealtı', 'Aksu',
        'Alanya', 'Manavgat', 'Side', 'Belek', 'Kaş'
      ],
    };
    
    return fallbackDistricts[cityName] ?? ['Merkez'];
  }
}