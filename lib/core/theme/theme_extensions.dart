import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tema Extension'ları - Glass efekt ve gradyanlar için
class GlassTheme extends ThemeExtension<GlassTheme> {
  final List<Color> gradient;
  final Color glassTint;
  final Color glassShadow;

  const GlassTheme({
    required this.gradient,
    required this.glassTint,
    required this.glassShadow,
  });

  @override
  GlassTheme copyWith({
    List<Color>? gradient,
    Color? glassTint,
    Color? glassShadow,
  }) {
    return GlassTheme(
      gradient: gradient ?? this.gradient,
      glassTint: glassTint ?? this.glassTint,
      glassShadow: glassShadow ?? this.glassShadow,
    );
  }

  @override
  ThemeExtension<GlassTheme> lerp(
    covariant ThemeExtension<GlassTheme>? other,
    double t,
  ) {
    if (other is! GlassTheme) return this;
    return GlassTheme(
      gradient: [
        Color.lerp(gradient[0], other.gradient[0], t)!,
        Color.lerp(gradient[1], other.gradient[1], t)!,
      ],
      glassTint: Color.lerp(glassTint, other.glassTint, t)!,
      glassShadow: Color.lerp(glassShadow, other.glassShadow, t)!,
    );
  }

  static const light = GlassTheme(
    gradient: AppColors.gradientPrimary,
    glassTint: AppColors.glassTint,
    glassShadow: AppColors.glassShadow,
  );

  static const dark = GlassTheme(
    gradient: AppColors.gradientPrimary,
    glassTint: Color(0x33FFFFFF),
    glassShadow: Color(0x33000000),
  );
}

/// Theme context extension - Kolay erişim için
extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  GlassTheme? get glassTheme => Theme.of(this).extension<GlassTheme>();
}
