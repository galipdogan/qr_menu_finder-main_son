part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLocationRequested extends HomeEvent {}

class HomeLocationNameRequested extends HomeEvent {
  final Location location;

  const HomeLocationNameRequested(this.location);

  @override
  List<Object> get props => [location];
}

class HomeLocationSelected extends HomeEvent {
  final Location location;
  final String locationName;

  const HomeLocationSelected({
    required this.location,
    required this.locationName,
  });

  @override
  List<Object> get props => [location, locationName];
}

class HomeRestaurantsRequested extends HomeEvent {
  final Location location;

  const HomeRestaurantsRequested(this.location);

  @override
  List<Object> get props => [location];
}

class HomeFavoriteToggled extends HomeEvent {
  final String restaurantId;
  final String userId;

  const HomeFavoriteToggled({
    required this.restaurantId,
    required this.userId,
  });

  @override
  List<Object> get props => [restaurantId, userId];
}

class HomeLoadCurrentLocation extends HomeEvent {}