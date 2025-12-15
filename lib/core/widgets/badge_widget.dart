import 'package:flutter/material.dart';

/// Küçük etiket/badge widget'ı
class BadgeWidget extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const BadgeWidget({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final txtColor = textColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: txtColor,
          fontSize: fontSize ?? 10,
        ),
      ),
    );
  }
}
