import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Bilgi mesajları için kart widget'ı
class InfoCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const InfoCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  factory InfoCard.info(BuildContext context, String message) {
    return InfoCard(
      message: message,
      icon: Icons.info_outline,
      backgroundColor: ThemeProvider.info(context).withValues(alpha: 0.1),
      iconColor: ThemeProvider.info(context),
    );
  }

  factory InfoCard.warning(BuildContext context, String message) {
    return InfoCard(
      message: message,
      icon: Icons.warning_amber_outlined,
      backgroundColor: ThemeProvider.warning(context).withValues(alpha: 0.1),
      iconColor: ThemeProvider.warning(context),
    );
  }

  factory InfoCard.success(BuildContext context, String message) {
    return InfoCard(
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: ThemeProvider.success(context).withValues(alpha: 0.1),
      iconColor: ThemeProvider.success(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? ThemeProvider.info(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor ?? ThemeProvider.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
