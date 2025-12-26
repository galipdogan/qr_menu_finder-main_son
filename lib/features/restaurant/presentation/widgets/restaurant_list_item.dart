import 'package:flutter/material.dart';
import '../../../../core/error/error_messages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../../domain/entities/restaurant.dart';

/// Modern Restaurant Card with Liquid Glass Design
class RestaurantListItem extends StatelessWidget {
  final Restaurant restaurant;
  final double? userLatitude;
  final double? userLongitude;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const RestaurantListItem({
    super.key,
    required this.restaurant,
    this.userLatitude,
    this.userLongitude,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  void _handleFavoriteToggle(BuildContext context) {
    // Check if user is authenticated
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      // Show login dialog
      _showLoginDialog(context);
      return;
    }

    // User is authenticated, toggle favorite
    if (onFavoriteToggle != null) {
      onFavoriteToggle!();
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.login, color: AppColors.primary),
              SizedBox(width: 12),
              Text(ErrorMessages.loginRequired),
            ],
          ),
          content: const Text(
            'Favorilere eklemek için giriş yapmalısınız. Şimdi giriş yapmak ister misiniz?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('İptal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(RouteNames.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(ErrorMessages.login),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final distance =
        (userLatitude != null &&
            userLongitude != null &&
            restaurant.latitude != null &&
            restaurant.longitude != null)
        ? DistanceCalculator.calculateDistance(
            lat1: userLatitude!,
            lng1: userLongitude!,
            lat2: restaurant.latitude!,
            lng2: restaurant.longitude!,
          )
        : null;

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: AppColors.shadow,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name, Rating & Favorite
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (restaurant.rating != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ratingStar.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.ratingStar.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.ratingStar,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              restaurant.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Favorite button
                    IconButton(
                      onPressed: () => _handleFavoriteToggle(context),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 22,
                        color: isFavorite
                            ? Colors.red
                            : AppColors.textSecondary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Address
                if (restaurant.address != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          restaurant.address!,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Categories & Distance Row
                Row(
                  children: [
                    // Categories
                    if (restaurant.categories.isNotEmpty) ...[
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: restaurant.categories.take(2).map((
                            category,
                          ) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    // Distance Badge
                    if (distance != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.navigation,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DistanceCalculator.formatDistance(distance),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
