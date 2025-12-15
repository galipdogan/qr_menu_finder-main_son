import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/restaurant.dart';
import 'restaurant_detail_view.dart';

class RestaurantFallbackView extends StatelessWidget {
  final Restaurant restaurant;
  final String message;

  const RestaurantFallbackView({
    super.key,
    required this.restaurant,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RestaurantDetailView(restaurant: restaurant),
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Card(
            color: Colors.white.withValues(alpha: 0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)?.couldNotFetchRecentData ??
                            'Could not fetch recent data',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(message),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
