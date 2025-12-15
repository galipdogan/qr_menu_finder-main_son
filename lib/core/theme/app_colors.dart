import 'package:flutter/material.dart';

/// Merkezi Tema Renk Paleti
/// Tüm uygulama genelinde kullanılacak renkler
class AppColors {
  AppColors._();

  // Ana Renkler
  static const Color primary = Color(0xFF4DB8AC);
  static const Color primaryLight = Color(0xFF6FD4C8);
  static const Color primaryDark = Color(0xFF3A9A8F);

  // İkincil Renkler
  static const Color secondary = Color(0xFF7F8C8D);
  static const Color secondaryLight = Color(0xFFBDC3C7);
  static const Color secondaryDark = Color(0xFF2C3E50);

  // Durum Renkleri
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Yüzey ve Arka Plan
  static const Color background = Color(0xFFE8F4F3);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF242424);
  static const Color overlay = Color(0x20000000);
  static const Color shadow = Color(0x15000000);

  // Metin Renkleri
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textMuted = Color(0xFFBDC3C7);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnDark = Colors.white;

  // UI Elemanları
  static const Color border = Color(0xFFECF0F1);
  static const Color borderDark = Color(0xFF3A3A3A);
  static const Color divider = Color(0xFFE0E6E8);
  static const Color ratingStar = Color(0xFFFFC300);

  // Gradyanlar
  static const List<Color> gradientPrimary = [primary, primaryLight];

  // Glass Efekt
  static const Color glassTint = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x15000000);

  // Yardımcı Metodlar
  static Color ratingColor(double rating) {
    if (rating >= 4.5) return success;
    if (rating >= 3.5) return ratingStar;
    if (rating >= 2.5) return warning;
    return error;
  }

  static Color sentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return success;
      case 'negative':
        return error;
      default:
        return warning;
    }
  }
}
