import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tema yardımcı fonksiyonları
class ThemeHelpers {
  ThemeHelpers._();

  /// Tarih formatla (Türkçe)
  static String formatDateTurkish(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Renk opacity ayarla
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Durum rengini al
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'başarılı':
        return AppColors.success;
      case 'error':
      case 'hata':
        return AppColors.error;
      case 'warning':
      case 'uyarı':
        return AppColors.warning;
      case 'info':
      case 'bilgi':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Rating rengini al
  static Color getRatingColor(double rating) {
    return AppColors.ratingColor(rating);
  }

  /// Fiyat trend rengini al
  static Color getPriceTrendColor(double currentPrice, double previousPrice) {
    if (currentPrice > previousPrice) {
      return AppColors.error; // Fiyat arttı
    } else if (currentPrice < previousPrice) {
      return AppColors.success; // Fiyat düştü
    }
    return AppColors.textSecondary; // Değişmedi
  }

  /// Fiyat trend ikonu al
  static IconData getPriceTrendIcon(double currentPrice, double previousPrice) {
    if (currentPrice > previousPrice) {
      return Icons.trending_up;
    } else if (currentPrice < previousPrice) {
      return Icons.trending_down;
    }
    return Icons.trending_flat;
  }
}
