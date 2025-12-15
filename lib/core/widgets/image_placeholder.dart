import 'package:flutter/material.dart';

/// Resim yüklenemediğinde gösterilecek placeholder widget
class ImagePlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;

  const ImagePlaceholder({
    super.key,
    this.width = 80,
    this.height = 80,
    this.icon = Icons.image,
    this.iconSize = 40,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 8,
  });

  factory ImagePlaceholder.restaurant({
    double? width,
    double? height,
  }) {
    return ImagePlaceholder(
      width: width ?? 80,
      height: height ?? 80,
      icon: Icons.restaurant,
      iconSize: 40,
      borderRadius: 8,
    );
  }

  factory ImagePlaceholder.menuItem({
    double? width,
    double? height,
  }) {
    return ImagePlaceholder(
      width: width ?? 60,
      height: height ?? 60,
      icon: Icons.restaurant_menu,
      iconSize: 30,
      borderRadius: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? 
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final icColor = iconColor ?? 
        Theme.of(context).colorScheme.primary;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: icColor,
      ),
    );
  }
}

/// Ağ üzerinden resim yükleyen widget (hata durumunda placeholder gösterir)
class NetworkImageWithPlaceholder extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final double borderRadius;

  const NetworkImageWithPlaceholder({
    super.key,
    required this.imageUrl,
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return placeholder ?? ImagePlaceholder(
            width: width,
            height: height,
            borderRadius: borderRadius,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
