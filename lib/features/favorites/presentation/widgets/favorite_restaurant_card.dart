import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routing/app_navigation.dart';
import '../../../restaurant/domain/entities/restaurant.dart';
import '../../domain/entities/favorite_item.dart';
import '../blocs/favorites_bloc.dart';
import '../blocs/favorites_event.dart';

/// Restaurant card widget for favorites list
/// 
/// Displays restaurant information with favorite button
class FavoriteRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final FavoriteItem favorite;

  const FavoriteRestaurantCard({
    super.key,
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
              _buildRestaurantImage(),
              const SizedBox(width: AppConstants.defaultSpacing),
              
              // Restaurant info
              Expanded(
                child: _buildRestaurantInfo(),
              ),
              
              // Favorite button
              _buildFavoriteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: restaurant.imageUrls.isNotEmpty
            ? restaurant.imageUrls.first
            : 'https://via.placeholder.com/80',
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
    );
  }

  Widget _buildRestaurantInfo() {
    return Column(
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
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.favorite, color: Colors.red),
      onPressed: () {
        context.read<FavoritesBloc>().add(
          FavoriteRemoveRequested(favoriteId: favorite.id),
        );
      },
    );
  }
}
