import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../routing/app_navigation.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import '../../../restaurant/domain/entities/restaurant.dart';
import '../../../restaurant/presentation/widgets/restaurant_list_item.dart';
import '../../domain/entities/location.dart';
import '../blocs/home_bloc.dart';
import '../widgets/home_app_bar_actions.dart';
import '../widgets/modular_search_bar.dart';
import '../blocs/search/search_bloc.dart';
import '../../domain/usecases/search_places.dart';
import '../../../../injection_container.dart' as sl;
import '../../../auth/presentation/blocs/auth_state.dart';

/// Clean Architecture Home Page
/// UI Layer - Only handles UI events and state display
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ UI → Event: Request location
    context.read<HomeBloc>().add(HomeLocationRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ UI → Event: Search performed
  void _performSearch(String query, Location location) {
    // Navigate to the dedicated search page with the query
    context.push('${RouteNames.search}?q=${Uri.encodeComponent(query)}');
  }

  // ✅ UI → Event: Favorite toggled
  void _toggleFavorite(String restaurantId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorilere eklemek için giriş yapmalısınız'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    context.read<HomeBloc>().add(
      HomeFavoriteToggled(
        restaurantId: restaurantId,
        userId: authState.user.id,
      ),
    );
  }

  // ✅ UI → Event: Retry location
  void _retryLocation() {
    context.read<HomeBloc>().add(HomeLocationRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Column(
            children: [
              // Search Bar - only show when location is loaded
              if (state is HomeLoaded) _buildSearchBar(state),
              // Main Content
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.addRestaurant),
        tooltip: 'Restoran Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          String locationName = 'Konum alınıyor...';

          if (state is HomeLoaded) {
            locationName = state.locationName;
          } else if (state is HomeLocationError) {
            locationName = 'Konum seçin';
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('QR Menu Finder'),
              Text(
                locationName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
      actions: [_buildUserMenu(), _buildAppBarActions()],
    );
  }

  Widget _buildUserMenu() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                authState.user.email.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push(RouteNames.profile);
                  break;
                case 'favorites':
                  context.push(RouteNames.favorites);
                  break;
                case 'owner':
                  context.push(RouteNames.ownerPanel);
                  break;
                case 'logout':
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(authState.user.email),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'favorites',
                child: Row(
                  children: [
                    Icon(Icons.favorite),
                    SizedBox(width: 8),
                    Text('Favorilerim'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'owner',
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu),
                    SizedBox(width: 8),
                    Text('İşletme Paneli'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          );
        } else {
          return TextButton.icon(
            onPressed: () => context.push(RouteNames.login),
            icon: const Icon(Icons.login),
            label: const Text('Giriş Yap'),
          );
        }
      },
    );
  }

  Widget _buildAppBarActions() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          return HomeAppBarActions(
            currentRestaurants: state.restaurants,
            userLatitude: state.location.latitude,
            userLongitude: state.location.longitude,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchBar(HomeLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocProvider(
        create: (context) => SearchBloc(searchPlaces: sl.sl<SearchPlaces>()),
        child: ModularSearchBar(
          controller: _searchController,
          onSearch: (query) => _performSearch(query, state.location),
          onClear: () {
            _searchController.clear();
            context.read<HomeBloc>().add(
              HomeRestaurantsRequested(state.location),
            );
          },
          onSuggestionSelected: (suggestion) {
            // If this is a restaurant, navigate to detail page
            if (suggestion.type?.toLowerCase().contains('restaurant') ?? false) {
              // Create minimal Restaurant entity for initialRestaurant
              final initialRestaurant = Restaurant(
                id: 'osm_${suggestion.id}',
                name: suggestion.name,
                description: null,
                address: suggestion.address,
                latitude: suggestion.latitude,
                longitude: suggestion.longitude,
                imageUrls: const [],
                rating: null,
                reviewCount: 0,
                categories: [suggestion.type ?? 'restaurant'],
                openingHours: const {},
                isActive: true,
                createdAt: DateTime.now(),
              );
              
              AppNavigation.pushRestaurantDetail(
                context,
                'osm_${suggestion.id}',
                initialRestaurant: initialRestaurant,
              );
            } else {
              // For non-restaurant places, update location
              if (suggestion.latitude != null && suggestion.longitude != null) {
                final location = Location(
                  latitude: suggestion.latitude!,
                  longitude: suggestion.longitude!,
                  name: suggestion.name,
                );
                context.read<HomeBloc>().add(
                  HomeLocationSelected(
                    location: location,
                    locationName: suggestion.name,
                  ),
                );
              }
            }
          },
          latitude: state.location.latitude,
          longitude: state.location.longitude,
        ),
      ),
    );
  }

  Widget _buildBody(HomeState state) {
    if (state is HomeLocationLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (state is HomeLocationError) {
      return _buildLocationError(state.message);
    }

    if (state is HomeLoaded) {
      return _buildLoadedContent(state);
    }

    return const Center(child: LoadingIndicator());
  }

  Widget _buildLocationError(String message) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.location_off, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            'Konum İzni Gerekli',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Yakınızdaki restoranları görmek için konum izni vermeniz gerekmektedir.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _retryLocation,
            icon: const Icon(Icons.refresh),
            label: const Text('Konum İznini Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Open app settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lütfen uygulama ayarlarından konum iznini açın'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text('Ayarları Aç'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(HomeLoaded state) {
    if (state.isLoadingRestaurants) {
      return const Center(child: LoadingIndicator());
    }

    if (state.restaurantError != null) {
      return ErrorView(
        message: state.restaurantError!,
        onRetry: () => context.read<HomeBloc>().add(
          HomeRestaurantsRequested(state.location),
        ),
      );
    }

    if (state.restaurants.isEmpty) {
      return const Center(child: Text('Yakınızda restoran bulunamadı'));
    }

    return ListView.builder(
      itemCount: state.restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = state.restaurants[index];
        final isFavorite = state.favoriteIds.contains(restaurant.id);

        return RestaurantListItem(
          restaurant: restaurant,
          onTap: () {
            AppNavigation.pushRestaurantDetail(
              context,
              restaurant.id,
              initialRestaurant: restaurant,
            );
          },
          isFavorite: isFavorite,
          onFavoriteToggle: () => _toggleFavorite(restaurant.id),
        );
      },
    );
  }
}
