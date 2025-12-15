import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qr_menu_finder/features/auth/presentation/blocs/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../restaurant/domain/entities/restaurant.dart';
import '../../../restaurant/presentation/blocs/restaurant_bloc.dart';
import '../../../restaurant/presentation/blocs/restaurant_event.dart';
import '../../../restaurant/presentation/blocs/restaurant_state.dart';
import '../../domain/entities/favorite_item.dart';
import '../blocs/favorites_bloc.dart';
import '../../../../routing/app_navigation.dart';
import '../../../../injection_container.dart' as di;

/// Favorites page - Clean Architecture implementation
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorilerim'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Giriş Yapmalısınız',
          subtitle: 'Favorilerinizi görmek için lütfen giriş yapın.',
        ),
      );
    }

    return BlocProvider(
      create: (context) => di.sl<RestaurantBloc>(),
      child: BlocConsumer<FavoritesBloc, FavoritesState>(
        listenWhen: (previous, current) {
          // Always listen to FavoriteToggled and FavoritesError states
          return current is FavoriteToggled || current is FavoritesError;
        },
        listener: (context, state) {
          if (state is FavoriteToggled) {
            AppLogger.i(
              '📱 FavoritesPage: FavoriteToggled state received - isFavorited: ${state.isFavorited}, itemId: ${state.itemId}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isFavorited
                      ? 'Favorilere eklendi'
                      : 'Favorilerden çıkarıldı',
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is FavoritesError) {
            AppLogger.e(
              '📱 FavoritesPage: FavoritesError state received',
              error: state.message,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // Load favorites on first build
          if (state is FavoritesInitial) {
            context.read<FavoritesBloc>().add(
              FavoritesLoadRequested(
                userId: userId,
                type: FavoriteType.restaurant,
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Favorilerim'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: _buildBody(context, state, userId),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FavoritesState state, String userId) {
    if (state is FavoritesLoading || state is FavoriteToggling) {
      return const LoadingIndicator(message: 'Favoriler yükleniyor...');
    }

    if (state is FavoritesLoaded) {
      if (state.favorites.isEmpty) {
        return EmptyState(
          icon: Icons.favorite_border,
          title: 'Henüz Favori Yok',
          subtitle:
              'Beğendiğiniz restoranları favorilere ekleyerek buradan kolayca ulaşabilirsiniz',
          action: ElevatedButton(
            onPressed: () => AppNavigation.goHome(context),
            child: const Text('Restoranları Keşfet'),
          ),
        );
      }

      // Fetch restaurant details using RestaurantBloc
      return RefreshIndicator(
        onRefresh: () async {
          context.read<FavoritesBloc>().add(
            FavoritesLoadRequested(
              userId: userId,
              type: FavoriteType.restaurant,
            ),
          );
          // Wait for reload
          await context.read<FavoritesBloc>().stream.firstWhere(
            (state) => state is! FavoritesLoading,
          );
        },
        child: _FavoriteRestaurantsList(
          favorites: state.favorites,
          userId: userId,
        ),
      );
    }

    // Default/Error state
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'Henüz Favori Yok',
      subtitle:
          'Beğendiğiniz restoranları favorilere ekleyerek buradan kolayca ulaşabilirsiniz',
      action: ElevatedButton(
        onPressed: () => AppNavigation.goHome(context),
        child: const Text('Restoranları Keşfet'),
      ),
    );
  }
}

/// Widget to display list of favorite restaurants
class _FavoriteRestaurantsList extends StatefulWidget {
  final List<FavoriteItem> favorites;
  final String userId;

  const _FavoriteRestaurantsList({
    required this.favorites,
    required this.userId,
  });

  @override
  State<_FavoriteRestaurantsList> createState() =>
      _FavoriteRestaurantsListState();
}

class _FavoriteRestaurantsListState extends State<_FavoriteRestaurantsList> {
  final Map<String, Restaurant?> _restaurantsCache = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void didUpdateWidget(_FavoriteRestaurantsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favorites != widget.favorites) {
      _loadRestaurants();
    }
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all restaurants sequentially
      for (final favorite in widget.favorites) {
        if (!_restaurantsCache.containsKey(favorite.itemId)) {
          // Trigger restaurant load via BLoC
          context.read<RestaurantBloc>().add(
            RestaurantDetailRequested(id: favorite.itemId),
          );

          // Wait for the specific restaurant to load
          try {
            await context
                .read<RestaurantBloc>()
                .stream
                .firstWhere((state) {
                  if (state is RestaurantDetailLoaded) {
                    _restaurantsCache[state.restaurant.id] = state.restaurant;
                    return state.restaurant.id == favorite.itemId;
                  } else if (state is RestaurantError) {
                    // Restaurant not found, mark as null
                    _restaurantsCache[favorite.itemId] = null;
                    AppLogger.w(
                      'Restaurant ${favorite.itemId} not found: ${state.message}',
                    );
                    return true;
                  }
                  return false;
                })
                .timeout(const Duration(seconds: 10));
          } catch (e) {
            // Timeout or error loading restaurant
            _restaurantsCache[favorite.itemId] = null;
            AppLogger.w('Error loading restaurant ${favorite.itemId}: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.e('Error loading restaurants', error: e);
      if (mounted) {
        setState(() {
          _error = 'Restoran bilgileri yüklenirken hata oluştu';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator(
        message: 'Restoran bilgileri yükleniyor...',
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRestaurants,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    final restaurants = widget.favorites
        .map((fav) => _restaurantsCache[fav.itemId])
        .whereType<Restaurant>()
        .toList();

    if (restaurants.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        title: 'Henüz Favori Yok',
        subtitle:
            'Beğendiğiniz restoranları favorilere ekleyerek buradan kolayca ulaşabilirsiniz',
        action: ElevatedButton(
          onPressed: () => AppNavigation.goHome(context),
          child: const Text('Restoranları Keşfet'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.defaultSpacing,
      ),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        final favorite = widget.favorites.firstWhere(
          (f) => f.itemId == restaurant.id,
        );

        return _RestaurantFavoriteCard(
          restaurant: restaurant,
          favorite: favorite,
        );
      },
    );
  }
}

/// Restaurant card widget for favorites
class _RestaurantFavoriteCard extends StatelessWidget {
  final Restaurant restaurant;
  final FavoriteItem favorite;

  const _RestaurantFavoriteCard({
    required this.restaurant,
    required this.favorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultSpacing,
        vertical: AppConstants.defaultSpacing / 2,
      ),
      child: InkWell(
        onTap: () {
          AppNavigation.goRestaurantDetail(
            context,
            restaurant.id,
            initialRestaurant: restaurant,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultSpacing),
          child: Row(
            children: [
              // Restaurant image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: restaurant.imageUrls.isNotEmpty
                      ? restaurant.imageUrls.first
                      : 'https://via.placeholder.com/80', // Fallback URL
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surface,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surface,
                    child: const Icon(Icons.restaurant, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.defaultSpacing),
              // Restaurant info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (restaurant.address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        restaurant.address!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (restaurant.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${restaurant.reviewCount} değerlendirme)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Favorite button
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  context.read<FavoritesBloc>().add(
                    FavoriteRemoveRequested(favoriteId: favorite.id),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
