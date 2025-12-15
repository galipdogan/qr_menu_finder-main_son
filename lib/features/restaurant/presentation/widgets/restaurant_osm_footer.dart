import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantOsmFooter extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantOsmFooter({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    if (restaurant.id.startsWith('user_')) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)?.osmAttribution ??
                    'Data from OpenStreetMap',
                style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
