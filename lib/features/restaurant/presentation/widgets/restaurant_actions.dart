import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/restaurant.dart';
import '../../../../routing/app_navigation.dart';

class RestaurantActions extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantActions({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  (restaurant.latitude != null && restaurant.longitude != null)
                  ? () {
                      AppNavigation.openDirections(
                        lat: restaurant.latitude!,
                        lon: restaurant.longitude!,
                        name: restaurant.name,
                      );
                    }
                  : null,
              icon: const Icon(Icons.directions, size: 20),
              label: Text(
                AppLocalizations.of(context)?.getDirections ?? 'Get Directions',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  AppNavigation.pushComments(context, restaurant.id),
              icon: const Icon(Icons.comment, size: 20),
              label: Text(AppLocalizations.of(context)?.reviews ?? 'Reviews'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
