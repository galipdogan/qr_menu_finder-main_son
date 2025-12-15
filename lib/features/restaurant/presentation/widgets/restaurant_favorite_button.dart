import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../../../favorites/presentation/blocs/favorites_bloc.dart';
import '../../../favorites/domain/entities/favorite_item.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantFavoriteButton extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantFavoriteButton({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 16,
      child: BlocConsumer<FavoritesBloc, FavoritesState>(
        listener: (context, favState) {
          if (favState is FavoriteToggled && favState.itemId == restaurant.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  favState.isFavorited
                      ? (AppLocalizations.of(context)?.addedToFavorites ??
                            'Added to favorites')
                      : (AppLocalizations.of(context)?.removedFromFavorites ??
                            'Removed from favorites'),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, favState) {
          final authState = context.read<AuthBloc>().state;

          if (authState is AuthAuthenticated &&
              favState is! FavoritesLoaded &&
              favState is! FavoriteToggling) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<FavoritesBloc>().add(
                FavoritesLoadRequested(
                  userId: authState.user.id,
                  type: FavoriteType.restaurant,
                ),
              );
            });
          }

          bool isFavorite = false;

          if (favState is FavoritesLoaded) {
            isFavorite = favState.favorites.any(
              (fav) => fav.itemId == restaurant.id,
            );
          } else if (favState is FavoriteToggling) {
            isFavorite = favState.currentFavorites.any(
              (fav) => fav.itemId == restaurant.id,
            );
          } else if (favState is FavoriteToggled &&
              favState.itemId == restaurant.id) {
            isFavorite = favState.isFavorited;
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey.shade600,
                size: 28,
              ),
              onPressed: favState is FavoriteToggling
                  ? null
                  : () {
                      if (authState is! AuthAuthenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)?.loginRequired ??
                                  'Login required',
                            ),
                          ),
                        );
                        return;
                      }

                      context.read<FavoritesBloc>().add(
                        FavoriteToggleRequested(
                          userId: authState.user.id,
                          itemId: restaurant.id,
                          type: FavoriteType.restaurant,
                        ),
                      );
                    },
            ),
          );
        },
      ),
    );
  }
}
