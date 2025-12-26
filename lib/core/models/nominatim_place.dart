import 'place_result.dart';

/// Nominatim place model for OpenStreetMap data
/// TR: OpenStreetMap verileri için Nominatim yer modeli
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

  /// Create from Nominatim JSON response
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

  /// Get city from address / Adresten şehir al
  String? get city {
    if (address == null) return null;
    return address!['city'] as String? ??
        address!['town'] as String? ??
        address!['village'] as String?;
  }

  /// Get district from address / Adresten ilçe al
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

  /// Get country from address / Adresten ülke al
  String? get country {
    if (address == null) return null;
    return address!['country'] as String?;
  }

  /// Convert to PlaceResult for compatibility
  /// TR: Uyumluluk için PlaceResult'a dönüştür
  PlaceResult toPlaceResult() {
    return PlaceResult(
      placeId: placeId,
      name: name,
      displayName: displayName,
      latitude: latitude,
      longitude: longitude,
      address: street,
      city: city,
      country: country,
      type: type ?? 'place',
    );
  }
}
