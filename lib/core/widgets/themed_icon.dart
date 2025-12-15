import 'package:flutter/material.dart';

/// Tema uyumlu icon widget'ı
class ThemedIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final bool useSecondaryColor;

  const ThemedIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.useSecondaryColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? (useSecondaryColor 
        ? Theme.of(context).colorScheme.secondary 
        : Theme.of(context).colorScheme.primary),
    );
  }
}
