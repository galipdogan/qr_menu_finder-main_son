/// Yer sonucu modeli
class PlaceResult {
  final String placeId;
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? phone;
  final String? website;
  final String? cuisine;
  final double? rating;
  final String type;

  PlaceResult({
    required this.placeId,
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.phone,
    this.website,
    this.cuisine,
    this.rating,
    this.type = 'place',
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;

    return PlaceResult(
      placeId: json['place_id']?.toString() ?? json['osm_id']?.toString() ?? '',
      name: json['name'] ?? json['display_name']?.split(',').first ?? 'Unnamed',
      displayName: json['display_name'] ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      address: _formatAddress(address),
      city: address?['city'] ?? address?['town'] ?? address?['village'],
      country: address?['country'],
      type: json['type'] ?? 'place',
    );
  }

  factory PlaceResult.fromOverpass(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};
    final lat = json['lat'] ?? json['center']?['lat'] ?? 0.0;
    final lon = json['lon'] ?? json['center']?['lon'] ?? 0.0;

    return PlaceResult(
      placeId: json['id']?.toString() ?? '',
      name: tags['name'] ?? 'Unnamed Restaurant',
      displayName: tags['name'] ?? 'Restaurant',
      latitude: double.tryParse(lat.toString()) ?? 0.0,
      longitude: double.tryParse(lon.toString()) ?? 0.0,
      address: _formatOverpassAddress(tags),
      city: tags['addr:city'],
      country: tags['addr:country'],
      phone: tags['phone'],
      website: tags['website'],
      cuisine: tags['cuisine'],
      type: 'restaurant',
    );
  }

  /// Photon API sonucundan PlaceResult oluştur
  factory PlaceResult.fromPhoton(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [0, 0];

    return PlaceResult(
      placeId: properties['osm_id']?.toString() ?? '',
      name: properties['name'] ?? 'Unnamed',
      displayName: properties['name'] ?? '',
      latitude: (coordinates.length > 1)
          ? (coordinates[1] as num).toDouble()
          : 0.0,
      longitude: (coordinates.isNotEmpty)
          ? (coordinates[0] as num).toDouble()
          : 0.0,
      address: properties['street'],
      city: properties['city'] ?? properties['county'],
      country: properties['country'],
      type: properties['osm_value'] ?? 'place',
    );
  }

  static String? _formatAddress(Map<String, dynamic>? address) {
    if (address == null) {
      return null;
    }

    final parts = <String>[];
    if (address['house_number'] != null) parts.add(address['house_number']);
    if (address['road'] != null) parts.add(address['road']);
    if (address['neighbourhood'] != null) parts.add(address['neighbourhood']);

    return parts.isNotEmpty ? parts.join(' ') : null;
  }

  static String? _formatOverpassAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber']);
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:neighbourhood'] != null) {
      parts.add(tags['addr:neighbourhood']);
    }

    return parts.isNotEmpty ? parts.join(' ') : null;
  }

  @override
  String toString() {
    return 'PlaceResult(name: $name, city: $city, type: $type)';
  }
}
