import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_location_name.dart';
import '../../../restaurant/domain/entities/restaurant.dart';
import '../../../restaurant/domain/usecases/get_nearby_restaurants.dart';
import '../../../favorites/domain/usecases/get_user_favorites.dart';
import '../../../favorites/domain/usecases/toggle_favorite.dart';
import '../../../favorites/domain/entities/favorite_item.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCurrentLocation getCurrentLocation;
  final GetLocationName getLocationName;
  final GetNearbyRestaurants getNearbyRestaurants;
  final GetUserFavorites getUserFavorites;
  final ToggleFavorite toggleFavorite;

  HomeBloc({
    required this.getCurrentLocation,
    required this.getLocationName,
    required this.getNearbyRestaurants,
    required this.getUserFavorites,
    required this.toggleFavorite,
  }) : super(HomeInitial()) {
    on<HomeLocationRequested>(_onLocationRequested);
    on<HomeLoadCurrentLocation>(_onLoadCurrentLocation); // New event handler
    on<HomeLocationNameRequested>(_onLocationNameRequested);
    on<HomeLocationSelected>(_onLocationSelected);
    on<HomeRestaurantsRequested>(_onRestaurantsRequested);
    on<HomeFavoriteToggled>(_onFavoriteToggled);
  }


  
  Future<void> _onLoadCurrentLocation(
    HomeLoadCurrentLocation event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLocationLoading());

    final result = await getCurrentLocation(NoParams());

    await result.fold(
      (failure) async => emit(HomeLocationError(failure.message)),
      (location) async {
        final nameResult = await getLocationName(
          GetLocationNameParams(location: location),
        );

        final locationName = nameResult.fold(
          (failure) => 'Mevcut konumunuz',
          (name) => name,
        );

        if (!emit.isDone) {
          emit(HomeLoaded(
            location: location,
            locationName: locationName,
            isLoadingRestaurants: true,
          ));
        }

        if (!emit.isDone) {
          await _loadRestaurantsForLocation(location, emit);
        }
      },
    );
  }

  Future<void> _onLocationRequested(
    HomeLocationRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLocationLoading());

    final result = await getCurrentLocation(NoParams());
    
    await result.fold(
      (failure) async => emit(HomeLocationError(failure.message)),
      (location) async {
        // Get location name
        final nameResult = await getLocationName(
          GetLocationNameParams(location: location),
        );
        
        final locationName = nameResult.fold(
          (failure) => 'Mevcut konumunuz',
          (name) => name,
        );

        // Check if emit is still valid before emitting
        if (!emit.isDone) {
          emit(HomeLoaded(
            location: location,
            locationName: locationName,
            isLoadingRestaurants: true,
          ));
        }

        // Load restaurants directly instead of adding event
        if (!emit.isDone) {
          await _loadRestaurantsForLocation(location, emit);
        }
      },
    );
  }

  Future<void> _onLocationNameRequested(
    HomeLocationNameRequested event,
    Emitter<HomeState> emit,
  ) async {
    // This is now handled in _onLocationRequested
  }

  Future<void> _onLocationSelected(
    HomeLocationSelected event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoaded(
      location: event.location,
      locationName: event.locationName,
      isLoadingRestaurants: true,
    ));

    // Load restaurants for selected location
    await _loadRestaurantsForLocation(event.location, emit);
  }

  Future<void> _onRestaurantsRequested(
    HomeRestaurantsRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadRestaurantsForLocation(event.location, emit);
  }

  Future<void> _onFavoriteToggled(
    HomeFavoriteToggled event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      // Optimistic update
      final newFavoriteIds = Set<String>.from(currentState.favoriteIds);
      if (newFavoriteIds.contains(event.restaurantId)) {
        newFavoriteIds.remove(event.restaurantId);
      } else {
        newFavoriteIds.add(event.restaurantId);
      }

      emit(currentState.copyWith(
        favoriteIds: newFavoriteIds,
        isLoadingFavorites: true,
      ));

      final result = await toggleFavorite(
        ToggleFavoriteParams(
          userId: event.userId,
          itemId: event.restaurantId,
          type: FavoriteType.restaurant,
        ),
      );

      result.fold(
        (failure) {
          // Revert optimistic update on failure
          emit(currentState.copyWith(isLoadingFavorites: false));
        },
        (success) async {
          // Load fresh favorites
          await _loadFavorites(event.userId, emit);
        },
      );
    }
  }

  Future<void> _loadFavorites(String userId, Emitter<HomeState> emit) async {
    final result = await getUserFavorites(
      GetUserFavoritesParams(
        userId: userId,
        type: FavoriteType.restaurant,
      ),
    );

    final currentState = state;
    if (currentState is HomeLoaded && !emit.isDone) {
      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingFavorites: false)),
        (favorites) {
          final favoriteIds = favorites
              .where((fav) => fav.type == FavoriteType.restaurant)
              .map((fav) => fav.itemId)
              .toSet();
          
          emit(currentState.copyWith(
            favoriteIds: favoriteIds,
            isLoadingFavorites: false,
          ));
        },
      );
    }
  }

  Future<void> _loadRestaurantsForLocation(Location location, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded && !emit.isDone) {
      emit(currentState.copyWith(isLoadingRestaurants: true));

      final result = await getNearbyRestaurants(
        NearbyRestaurantsParams(
          latitude: location.latitude,
          longitude: location.longitude,
          radiusMeters: 5000, // 5km radius
          limit: 20,
        ),
      );

      if (!emit.isDone) {
        result.fold(
          (failure) => emit(currentState.copyWith(
            isLoadingRestaurants: false,
            restaurantError: failure.message,
          )),
          (restaurants) => emit(currentState.copyWith(
            isLoadingRestaurants: false,
            restaurants: restaurants,
            restaurantError: null,
          )),
        );
      }
    }
  }
}