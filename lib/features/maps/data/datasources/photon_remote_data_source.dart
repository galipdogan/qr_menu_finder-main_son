import 'dart:async'; // Add this import
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/app_logger.dart';
import '../../../../core/models/place_result.dart';

abstract class PhotonRemoteDataSource {
  Future<List<PlaceResult>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 10,
  });
}

class PhotonRemoteDataSourceImpl implements PhotonRemoteDataSource {
  static const String _photonUrl = 'https://photon.komoot.io';
  static const String _userAgent = 'QRMenuFinder/1.0';

  final http.Client client;

  PhotonRemoteDataSourceImpl({required this.client});

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
      'limit': limit.toString(),
      if (latitude != null && longitude != null) ...{
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
    };

    final uri = Uri.parse('$_photonUrl/api/').replace(queryParameters: params);

    try {
      AppLogger.i('🔍 Searching with Photon API: $query');

      final response = await client
          .get(
            uri,
            headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              AppLogger.w('⏰ Photon API timeout for query: $query');
              throw TimeoutException('Photon API timeout after 10 seconds');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List<dynamic>? ?? [];

        AppLogger.i(
          '✅ Photon API returned ${features.length} results for: $query',
        );

        return features
            .map((feature) => PlaceResult.fromPhoton(feature))
            .where((place) => place.name.isNotEmpty)
            .toList();
      } else {
        AppLogger.w(
          '❌ Photon API error ${response.statusCode} for query: $query',
        );
        throw Exception(
          'Photon API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      AppLogger.e('🚨 Photon API request failed for query: $query', error: e);
      rethrow;
    }
  }
}
