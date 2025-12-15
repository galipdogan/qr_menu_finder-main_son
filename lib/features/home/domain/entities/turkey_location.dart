import 'package:equatable/equatable.dart';

class TurkeyLocation extends Equatable {
  final String id;
  final String name;
  final String type; // 'city', 'district', 'neighborhood'
  final String? parentId;
  final double? latitude;
  final double? longitude;

  const TurkeyLocation({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [id, name, type, parentId, latitude, longitude];

  TurkeyLocation copyWith({
    String? id,
    String? name,
    String? type,
    String? parentId,
    double? latitude,
    double? longitude,
  }) {
    return TurkeyLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}