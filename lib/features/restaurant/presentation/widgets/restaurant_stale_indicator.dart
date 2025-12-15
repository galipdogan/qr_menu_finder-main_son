import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class RestaurantStaleDataIndicator extends StatelessWidget {
  const RestaurantStaleDataIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: kToolbarHeight,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.amber.withValues(alpha: 0.9),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)?.loadingMoreRecentData ??
                    'Loading more recent data...',
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
