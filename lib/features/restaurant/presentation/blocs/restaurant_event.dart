import 'package:equatable/equatable.dart';

import '../../domain/entities/restaurant.dart';

// Events
abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class RestaurantNearbyRequested extends RestaurantEvent {
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final int limit;

  const RestaurantNearbyRequested({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 5000,
    this.limit = 25, // Optimized for faster loading
  });

  @override
  List<Object> get props => [latitude, longitude, radiusMeters, limit];
}

class RestaurantSearchRequested extends RestaurantEvent {
  final String query;
  final double? latitude;
  final double? longitude;
  final int limit;

  const RestaurantSearchRequested({
    required this.query,
    this.latitude,
    this.longitude,
    this.limit = 50, // Increased from 20 to 50 for more results
  });

  @override
  List<Object?> get props => [query, latitude, longitude, limit];
}

class RestaurantDetailRequested extends RestaurantEvent {
  final String id;

  const RestaurantDetailRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class RestaurantCreateRequested extends RestaurantEvent {
  final Restaurant restaurant;

  const RestaurantCreateRequested({required this.restaurant});

  @override
  List<Object> get props => [restaurant];
}
