import 'package:equatable/equatable.dart';
// import 'package:latlong2/latlong.dart'; // Removed
// import 'package:qr_menu_finder/features/maps/data/datasources/nominatim_remote_data_source.dart'; // Import NominatimPlace

class PlaceSuggestion extends Equatable {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? type;

  const PlaceSuggestion({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.type,
  });

  @override
  List<Object?> get props => [id, name, address, latitude, longitude, type];

  PlaceSuggestion copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? type,
  }) {
    return PlaceSuggestion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
    );
  }

  // --- Factory constructors for converting from different sources ---

  factory PlaceSuggestion.fromPhoton(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [0, 0];

    return PlaceSuggestion(
      id: properties['osm_id']?.toString() ?? '',
      name: properties['name'] ?? 'Unnamed',
      address: properties['street'] ?? properties['city'] ?? properties['county'] ?? '',
      latitude: (coordinates.length > 1) ? (coordinates[1] as num).toDouble() : 0.0,
      longitude: (coordinates.isNotEmpty) ? (coordinates[0] as num).toDouble() : 0.0,
      type: properties['osm_value'] ?? 'place',
    );
  }



  factory PlaceSuggestion.fromOsmData(Map<String, dynamic> osmData) {
    return PlaceSuggestion(
      id: osmData['osm_id']?.toString() ?? '',
      name: osmData['name'] ?? 'Unnamed',
      address: osmData['address'] ?? '',
      latitude: osmData['latitude'] ?? 0.0,
      longitude: osmData['longitude'] ?? 0.0,
      type: osmData['amenity'] ?? 'place',
    );
  }
}