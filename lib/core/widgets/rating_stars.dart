import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Yıldız rating gösterimi için widget
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showValue;
  final int maxStars;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.showValue = false,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxStars, (index) {
          return Icon(
            index < rating.floor() ? Icons.star : Icons.star_border,
            color: color ?? ThemeProvider.ratingStar(context),
            size: size,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// İnteraktif yıldız rating widget'ı
class InteractiveRatingStars extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;
  final Color? color;

  const InteractiveRatingStars({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: color ?? ThemeProvider.ratingStar(context),
          ),
          iconSize: size,
          onPressed: () => onRatingChanged(index + 1),
        );
      }),
    );
  }
}
