import 'package:flutter/material.dart';

/// Bilgi satırı widget'ı (icon + text)
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final double iconSize;
  final TextStyle? textStyle;
  final int? maxLines;
  final double spacing;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.iconSize = 16,
    this.textStyle,
    this.maxLines,
    this.spacing = 4,
  });

  factory InfoRow.location(String address, {Color? color}) {
    return InfoRow(
      icon: Icons.location_on,
      text: address,
      iconColor: color,
      maxLines: 2,
    );
  }

  factory InfoRow.rating(double rating, {Color? color}) {
    return InfoRow(
      icon: Icons.star,
      text: rating.toStringAsFixed(1),
      iconColor: color,
    );
  }

  factory InfoRow.distance(String distance, {Color? color}) {
    return InfoRow(
      icon: Icons.location_on,
      text: distance,
      iconColor: color,
    );
  }

  factory InfoRow.time(String time, {Color? color}) {
    return InfoRow(
      icon: Icons.access_time,
      text: time,
      iconColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? Theme.of(context).colorScheme.secondary,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            text,
            style: textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
            ),
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }
}
