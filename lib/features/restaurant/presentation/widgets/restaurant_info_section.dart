import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantInfoSection extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantInfoSection({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (restaurant.rating != null) ...[
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  restaurant.rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)?.googleRating ?? 'Rating',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (restaurant.address != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restaurant.address!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (restaurant.phoneNumber != null &&
              restaurant.phoneNumber!.isNotEmpty)
            GestureDetector(
              onTap: () =>
                  launchUrl(Uri.parse('tel:${restaurant.phoneNumber!}')),
              child: Row(
                children: [
                  Icon(Icons.phone, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    restaurant.phoneNumber!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
