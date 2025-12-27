import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../routing/app_navigation.dart';
import '../../../restaurant/domain/entities/restaurant.dart';
import '../../../restaurant/presentation/blocs/restaurant_bloc.dart';
import '../../../restaurant/presentation/blocs/restaurant_event.dart';
import '../../../restaurant/presentation/blocs/restaurant_state.dart';
import '../../domain/entities/favorite_item.dart';
import 'favorite_restaurant_card.dart';

/// Widget to display list of favorite restaurants
/// 
/// Handles loading restaurant details and displaying them in a list
class FavoriteRestaurantsList extends StatefulWidget {
  final List<FavoriteItem> favorites;
  final String userId;

  const FavoriteRestaurantsList({
    super.key,
    required this.favorites,
    required this.userId,
  });

  @override
  State<FavoriteRestaurantsList> createState() =>
      _FavoriteRestaurantsListState();
}

class _FavoriteRestaurantsListState extends State<FavoriteRestaurantsList> {
  final Map<String, Restaurant?> _restaurantsCache = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void didUpdateWidget(FavoriteRestaurantsList oldWidget) {
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
          await _loadSingleRestaurant(favorite.itemId);
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

  Future<void> _loadSingleRestaurant(String restaurantId) async {
    // Trigger restaurant load via BLoC
    context.read<RestaurantBloc>().add(
      RestaurantDetailRequested(id: restaurantId),
    );

    // Wait for the specific restaurant to load
    try {
      await context
          .read<RestaurantBloc>()
          .stream
          .firstWhere((state) {
            if (state is RestaurantDetailLoaded) {
              _restaurantsCache[state.restaurant.id] = state.restaurant;
              return state.restaurant.id == restaurantId;
            } else if (state is RestaurantError) {
              // Restaurant not found, mark as null
              _restaurantsCache[restaurantId] = null;
              AppLogger.w(
                'Restaurant $restaurantId not found: ${state.message}',
              );
              return true;
            }
            return false;
          })
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      // Timeout or error loading restaurant
      _restaurantsCache[restaurantId] = null;
      AppLogger.w('Error loading restaurant $restaurantId: $e');
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
      return _buildErrorState();
    }

    final restaurants = widget.favorites
        .map((fav) => _restaurantsCache[fav.itemId])
        .whereType<Restaurant>()
        .toList();

    if (restaurants.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        title: ErrorMessages.favoritesEmptyTitle,
        subtitle: ErrorMessages.favoritesEmptySubtitle,
        action: ElevatedButton(
          onPressed: () => AppNavigation.goHome(context),
          child: const Text(ErrorMessages.exploreRestaurants),
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

        return FavoriteRestaurantCard(
          restaurant: restaurant,
          favorite: favorite,
        );
      },
    );
  }

  Widget _buildErrorState() {
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
              child: const Text(ErrorMessages.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
