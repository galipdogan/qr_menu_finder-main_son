import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_menu_finder/features/auth/presentation/blocs/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/error/error_messages.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../restaurant/presentation/blocs/restaurant_bloc.dart';
import '../../domain/entities/favorite_item.dart';
import '../blocs/favorites_bloc.dart';
import '../blocs/favorites_event.dart';
import '../blocs/favorites_state.dart';
import '../widgets/favorite_restaurants_list.dart';
import '../../../../routing/app_navigation.dart';
import '../../../../injection_container.dart' as di;

/// Favorites page - Clean Architecture implementation
/// 
/// Refactored for better organization and maintainability
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null) {
      return _buildUnauthenticatedState();
    }

    return BlocProvider(
      create: (context) => di.sl<RestaurantBloc>(),
      child: BlocConsumer<FavoritesBloc, FavoritesState>(
        listenWhen: (previous, current) {
          return current is FavoriteActionSuccess || current is FavoritesError;
        },
        listener: _handleStateChanges,
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

  Widget _buildUnauthenticatedState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ErrorMessages.favoritesTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const EmptyState(
        icon: Icons.error_outline,
        title: ErrorMessages.mustLogin,
        subtitle: ErrorMessages.mustLoginForFavorites,
      ),
    );
  }

  void _handleStateChanges(BuildContext context, FavoritesState state) {
    if (state is FavoriteActionSuccess) {
      AppLogger.i(
        '📱 FavoritesPage: FavoriteActionSuccess - ${state.message}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
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
  }

  Widget _buildBody(BuildContext context, FavoritesState state, String userId) {
    if (state is FavoritesLoading) {
      return LoadingIndicator(message: ErrorMessages.favoritesLoading);
    }

    if (state is FavoritesLoaded) {
      if (state.favorites.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () => _refreshFavorites(context, userId),
        child: FavoriteRestaurantsList(
          favorites: state.favorites,
          userId: userId,
        ),
      );
    }

    // Default/Error state
    return _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Future<void> _refreshFavorites(BuildContext context, String userId) async {
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
  }
}
