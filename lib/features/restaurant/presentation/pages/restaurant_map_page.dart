import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../maps/data/services/location_service.dart'; // Removed
import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../routing/app_navigation.dart';
import '../../domain/entities/restaurant.dart';
import '../blocs/restaurant_bloc.dart';
import '../blocs/restaurant_event.dart' show RestaurantNearbyRequested;
import '../blocs/restaurant_state.dart';
import '../widgets/restaurant_map_view.dart';
import '../../../home/presentation/blocs/home_bloc.dart'; // Import HomeBloc

/// Restaurant Map Page - Shows restaurants on OpenStreetMap
class RestaurantMapPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final List<Restaurant>? initialRestaurants;

  const RestaurantMapPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialRestaurants,
  });

  @override
  State<RestaurantMapPage> createState() => _RestaurantMapPageState();
}

class _RestaurantMapPageState extends State<RestaurantMapPage> {
  // final LocationService _locationService = LocationService(); // Removed

  @override
  void initState() {
    super.initState();

    // If initial location is provided from router, use it
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      AppLogger.i(
        "📍 Router üzerinden gelen konum kullanılıyor: ${widget.initialLatitude}, ${widget.initialLongitude}",
      );

      // Trigger nearby restaurants search with provided initial location
      context.read<RestaurantBloc>().add(
        RestaurantNearbyRequested(
          latitude: widget.initialLatitude!,
          longitude: widget.initialLongitude!,
          radiusMeters: 5000,
          limit: 10,
        ),
      );
    } else {
      // Otherwise, load location via HomeBloc
      _loadLocationAndRestaurants();
    }
  }

  void _loadLocationAndRestaurants() {
    context.read<HomeBloc>().add(HomeLoadCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restoran Haritası'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Konumumu Bul',
            onPressed: _loadLocationAndRestaurants,
          ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, homeState) {
          if (homeState is HomeLoaded) {
            // Once HomeBloc has loaded the location, request restaurants
            context.read<RestaurantBloc>().add(
              RestaurantNearbyRequested(
                latitude: homeState.location.latitude,
                longitude: homeState.location.longitude,
                radiusMeters: 5000,
                limit: 10,
              ),
            );
          } else if (homeState is HomeLocationError) {
            AppLogger.e('Location Error in HomeBloc: ${homeState.message}');
            // Show error specific to location if needed,
            // or let RestaurantBloc handle its own error
          }
        },
        builder: (context, homeState) {
          if (homeState is HomeLocationLoading) {
            return const LoadingIndicator(message: 'Konum alınıyor...');
          }
          if (homeState is HomeLocationError) {
            return ErrorView(
              message: homeState.message,
              onRetry: _loadLocationAndRestaurants,
            );
          }
          if (homeState is HomeLoaded) {
            // Now render the map using RestaurantBloc state
            return BlocBuilder<RestaurantBloc, RestaurantState>(
              builder: (context, restaurantState) {
                if (restaurantState is RestaurantLoading) {
                  return const LoadingIndicator(
                    message: 'Restoranlar yükleniyor...',
                  );
                }
                if (restaurantState is RestaurantError) {
                  // If initial restaurants were provided, use fallback
                  if (widget.initialRestaurants != null) {
                    return RestaurantMapView(
                      restaurants: widget.initialRestaurants!,
                      userLatitude: homeState.location.latitude,
                      userLongitude: homeState.location.longitude,
                      onRestaurantTap: (restaurant) {
                        AppNavigation.pushRestaurantDetail(
                          context,
                          restaurant.id,
                          initialRestaurant: restaurant,
                        );
                      },
                    );
                  }
                  return ErrorView(
                    message: restaurantState.message,
                    onRetry: () => context.read<RestaurantBloc>().add(
                      RestaurantNearbyRequested(
                        latitude: homeState.location.latitude,
                        longitude: homeState.location.longitude,
                        radiusMeters: 5000,
                        limit: 10,
                      ),
                    ),
                  );
                }

                if (restaurantState is RestaurantListLoaded) {
                  if (restaurantState.restaurants.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Yakınında restoran bulunamadı',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return RestaurantMapView(
                    restaurants: restaurantState.restaurants,
                    userLatitude: homeState.location.latitude,
                    userLongitude: homeState.location.longitude,
                    onRestaurantTap: (restaurant) {
                      AppNavigation.pushRestaurantDetail(
                        context,
                        restaurant.id,
                        initialRestaurant: restaurant,
                      );
                    },
                  );
                }

                // Initial state for RestaurantBloc
                return const LoadingIndicator(
                  message: 'Harita hazırlanıyor...',
                );
              },
            );
          }
          // Fallback if HomeBloc is in an unexpected state
          return const LoadingIndicator(message: 'Başlatılıyor...');
        },
      ),
    );
  }
}
