import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String? name;

  const Location({
    required this.latitude,
    required this.longitude,
    this.name,
  });

  @override
  List<Object?> get props => [latitude, longitude, name];

  Location copyWith({
    double? latitude,
    double? longitude,
    String? name,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
    );
  }
}