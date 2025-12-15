part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLocationLoading extends HomeState {}

class HomeLocationError extends HomeState {
  final String message;

  const HomeLocationError(this.message);

  @override
  List<Object> get props => [message];
}

class HomeLoaded extends HomeState {
  final Location location;
  final String locationName;
  final List<Restaurant> restaurants;
  final Set<String> favoriteIds;
  final bool isLoadingRestaurants;
  final bool isLoadingFavorites;
  final String? restaurantError;

  const HomeLoaded({
    required this.location,
    required this.locationName,
    this.restaurants = const [],
    this.favoriteIds = const {},
    this.isLoadingRestaurants = false,
    this.isLoadingFavorites = false,
    this.restaurantError,
  });

  @override
  List<Object?> get props => [
    location,
    locationName,
    restaurants,
    favoriteIds,
    isLoadingRestaurants,
    isLoadingFavorites,
    restaurantError,
  ];

  HomeLoaded copyWith({
    Location? location,
    String? locationName,
    List<Restaurant>? restaurants,
    Set<String>? favoriteIds,
    bool? isLoadingRestaurants,
    bool? isLoadingFavorites,
    String? restaurantError,
  }) {
    return HomeLoaded(
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      restaurants: restaurants ?? this.restaurants,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoadingRestaurants: isLoadingRestaurants ?? this.isLoadingRestaurants,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      restaurantError: restaurantError ?? this.restaurantError,
    );
  }
}