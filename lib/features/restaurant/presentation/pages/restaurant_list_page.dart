import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../routing/app_navigation.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../../../favorites/presentation/blocs/favorites_bloc.dart';
import '../../../favorites/domain/entities/favorite_item.dart';
import '../blocs/restaurant_bloc.dart';
import '../blocs/restaurant_event.dart';
import '../blocs/restaurant_state.dart';
import '../widgets/restaurant_list_item.dart';

/// Modern restaurant list page using clean architecture and a stateless approach.
class RestaurantListPage extends StatelessWidget {
  final double? userLatitude;
  final double? userLongitude;
  final String? searchQuery;

  const RestaurantListPage({
    super.key,
    this.userLatitude,
    this.userLongitude,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    // This function dispatches the correct event to the bloc.
    void loadRestaurants() {
      final bloc = context.read<RestaurantBloc>();
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        bloc.add(
          RestaurantSearchRequested(
            query: searchQuery!,
            latitude: userLatitude,
            longitude: userLongitude,
          ),
        );
      } else if (userLatitude != null && userLongitude != null) {
        bloc.add(
          RestaurantNearbyRequested(
            latitude: userLatitude!,
            longitude: userLongitude!,
          ),
        );
      }
    }

    return BlocProvider<RestaurantBloc>(
      create: (context) {
        // Get the bloc from dependency injection
        final bloc = di.sl<RestaurantBloc>();

        // Dispatch the initial event right after creation
        if (searchQuery != null && searchQuery!.isNotEmpty) {
          bloc.add(
            RestaurantSearchRequested(
              query: searchQuery!,
              latitude: userLatitude,
              longitude: userLongitude,
            ),
          );
        } else if (userLatitude != null && userLongitude != null) {
          bloc.add(
            RestaurantNearbyRequested(
              latitude: userLatitude!,
              longitude: userLongitude!,
            ),
          );
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            searchQuery != null ? 'Arama Sonuçları' : 'Yakındaki Restoranlar',
          ),
          backgroundColor: ThemeProvider.primary(context),
          foregroundColor: ThemeProvider.onPrimary(context),
          actions: [
            // The refresh button now reads the bloc from the context and adds an event.
            BlocBuilder<RestaurantBloc, RestaurantState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: state is RestaurantLoading
                      ? null
                      : () => loadRestaurants(),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<RestaurantBloc, RestaurantState>(
          builder: (context, state) {
            if (state is RestaurantLoading) {
              return const LoadingIndicator();
            } else if (state is RestaurantError) {
              return ErrorView(
                message: state.message,
                onRetry: () => loadRestaurants(),
              );
            } else if (state is RestaurantListLoaded) {
              if (state.restaurants.isEmpty) {
                return EmptyState(
                  icon: Icons.restaurant,
                  title: 'Restoran Bulunamadı',
                  subtitle: searchQuery != null
                      ? 'Arama kriterlerinize uygun restoran bulunamadı.'
                      : 'Bu bölgede restoran bulunamadı.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async => loadRestaurants(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = state.restaurants[index];
                    return BlocBuilder<FavoritesBloc, FavoritesState>(
                      builder: (context, favState) {
                        final isFavorite =
                            favState is FavoritesLoaded &&
                            favState.favorites.any(
                              (fav) => fav.itemId == restaurant.id,
                            );

                        return RestaurantListItem(
                          restaurant: restaurant,
                          userLatitude: userLatitude,
                          userLongitude: userLongitude,
                          onTap: () {
                            AppNavigation.pushRestaurantDetail(
                              context,
                              restaurant.id,
                              initialRestaurant: restaurant,
                            );
                          },
                          isFavorite: isFavorite,
                          onFavoriteToggle: () {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              context.read<FavoritesBloc>().add(
                                FavoriteToggleRequested(
                                  userId: authState.user.id,
                                  itemId: restaurant.id,
                                  type: FavoriteType.restaurant,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const EmptyState(
              icon: Icons.restaurant,
              title: 'Restoranlar',
              subtitle:
                  'Restoranları görüntülemek için konum bilginizi paylaşın.',
            );
          },
        ),
      ),
    );
  }
}
