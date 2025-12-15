import 'package:flutter/material.dart';
import '../../../../core/error/error.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class RestaurantErrorView extends StatelessWidget {
  final String message;
  final String restaurantId;
  final VoidCallback onRetry;

  const RestaurantErrorView({
    super.key,
    required this.message,
    required this.restaurantId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ErrorMessages.getErrorIcon(message),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: Text(AppLocalizations.of(context)?.tryAgain ?? 'Try Again'),
          ),
        ],
      ),
    );
  }
}
