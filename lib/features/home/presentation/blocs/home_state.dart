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
  List<Object?> get props => [message];
}

class HomeLoaded extends HomeState {
  final Location location;
  final String locationName;
  final List<Restaurant> restaurants;
  final bool isLoadingRestaurants;
  final String? restaurantError;
  final Set<String> favoriteIds;
  final bool isLoadingFavorites;

  const HomeLoaded({
    required this.location,
    required this.locationName,
    this.restaurants = const [],
    this.isLoadingRestaurants = false,
    this.restaurantError,
    this.favoriteIds = const {},
    this.isLoadingFavorites = false,
  });

  HomeLoaded copyWith({
    Location? location,
    String? locationName,
    List<Restaurant>? restaurants,
    bool? isLoadingRestaurants,
    // Special handling for nullable fields using a wrapper or object check is ideal,
    // but standard copyWith is common in Flutter Bloc.
    // For now, we will assume standard behavior and if we need to clear error, we rely on new state emission.
    String? restaurantError,
    Set<String>? favoriteIds,
    bool? isLoadingFavorites,
  }) {
    return HomeLoaded(
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      restaurants: restaurants ?? this.restaurants,
      isLoadingRestaurants: isLoadingRestaurants ?? this.isLoadingRestaurants,
      restaurantError: restaurantError ?? this.restaurantError,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
    );
  }

  @override
  List<Object?> get props => [
        location,
        locationName,
        restaurants,
        isLoadingRestaurants,
        restaurantError,
        favoriteIds,
        isLoadingFavorites,
      ];
}
