import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_nearby_restaurants.dart';
import '../../domain/usecases/search_restaurants.dart';
import '../../domain/usecases/get_restaurant_by_id.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/error/error.dart';

import 'restaurant_event.dart';
import 'restaurant_state.dart';

import '../../domain/usecases/create_restaurant.dart';

// Bloc
class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetNearbyRestaurants getNearbyRestaurants;
  final SearchRestaurants searchRestaurants;
  final GetRestaurantById getRestaurantById;
  final CreateRestaurant createRestaurant;

  RestaurantBloc({
    required this.getNearbyRestaurants,
    required this.searchRestaurants,
    required this.getRestaurantById,
    required this.createRestaurant,
  }) : super(RestaurantInitial()) {
    on<RestaurantNearbyRequested>(_onRestaurantNearbyRequested);
    on<RestaurantSearchRequested>(_onRestaurantSearchRequested);
    on<RestaurantDetailRequested>(_onRestaurantDetailRequested);
    on<RestaurantCreateRequested>(_onRestaurantCreateRequested);
  }

  Future<void> _onRestaurantNearbyRequested(
    RestaurantNearbyRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    AppLogger.i('RestaurantBloc: Nearby restaurants requested');
    AppLogger.i('Location: ${event.latitude}, ${event.longitude}');
    AppLogger.i('Radius: ${event.radiusMeters}m, Limit: ${event.limit}');

    emit(RestaurantLoading());

    final result = await getNearbyRestaurants(
      NearbyRestaurantsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusMeters: event.radiusMeters,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e(
          'RestaurantBloc: Failed to fetch restaurants',
          error: failure.message,
        );
        // Use userMessage from Failure (automatically handles error types)
        emit(RestaurantError(message: failure.userMessage));
      },
      (restaurants) {
        AppLogger.i('RestaurantBloc: Loaded ${restaurants.length} restaurants');
        if (restaurants.isEmpty) {
          emit(
            const RestaurantListEmpty(message: ErrorMessages.noRestaurantsNearby),
          );
        } else {
          emit(RestaurantListLoaded(restaurants: restaurants));
        }
      },
    );
  }

  Future<void> _onRestaurantSearchRequested(
    RestaurantSearchRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());

    final result = await searchRestaurants(
      SearchRestaurantsParams(
        query: event.query,
        latitude: event.latitude,
        longitude: event.longitude,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e('RestaurantBloc: Search failed', error: failure.message);
        emit(RestaurantError(message: failure.userMessage));
      },
      (restaurants) {
        AppLogger.i(
          'RestaurantBloc: Search returned ${restaurants.length} restaurants',
        );
        if (restaurants.isEmpty) {
          emit(
            const RestaurantListEmpty(message: ErrorMessages.noRestaurantsFoundForSearch),
          );
        } else {
          emit(RestaurantListLoaded(restaurants: restaurants));
        }
      },
    );
  }

  Future<void> _onRestaurantDetailRequested(
    RestaurantDetailRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());

    final result = await getRestaurantById(RestaurantByIdParams(id: event.id));

    result.fold(
      (failure) {
        AppLogger.e(
          'RestaurantBloc: Failed to load restaurant detail',
          error: failure.message,
        );
        emit(RestaurantError(message: failure.userMessage));
      },
      (restaurant) {
        AppLogger.i(
          'RestaurantBloc: Loaded restaurant detail: ${restaurant.name}',
        );
        emit(RestaurantDetailLoaded(restaurant: restaurant));
      },
    );
  }

  Future<void> _onRestaurantCreateRequested(
    RestaurantCreateRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());

    final result = await createRestaurant(
      CreateRestaurantParams(restaurant: event.restaurant),
    );

    result.fold(
      (failure) {
        AppLogger.e(
          'RestaurantBloc: Failed to create restaurant',
          error: failure.message,
        );
        emit(RestaurantError(message: failure.userMessage));
      },
      (restaurant) {
        AppLogger.i(
          'RestaurantBloc: Successfully created restaurant: ${restaurant.name}',
        );
        emit(
          const RestaurantOperationSuccess(
            message: 'Restoran başarıyla oluşturuldu!',
          ),
        );
      },
    );
  }
}
