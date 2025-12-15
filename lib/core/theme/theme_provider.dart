import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'theme_extensions.dart';

/// Merkezi Tema Sağlayıcı
/// Tüm uygulama genelinde tutarlı tema erişimi için tek kaynak
class ThemeProvider {
  ThemeProvider._();

  // ============ Renk Erişimi ============
  
  static Color primary(BuildContext context) => 
      context.colorScheme.primary;
  
  static Color secondary(BuildContext context) => 
      context.colorScheme.secondary;
  
  static Color surface(BuildContext context) => 
      context.colorScheme.surface;
  
  static Color background(BuildContext context) => 
      context.theme.scaffoldBackgroundColor;
  
  static Color error(BuildContext context) => 
      context.colorScheme.error;
  
  static Color onPrimary(BuildContext context) => 
      context.colorScheme.onPrimary;
  
  static Color onSurface(BuildContext context) => 
      context.colorScheme.onSurface;
  
  static Color textPrimary(BuildContext context) => 
      context.isDarkMode ? AppColors.textOnDark : AppColors.textPrimary;
  
  static Color textSecondary(BuildContext context) => 
      AppColors.textSecondary;
  
  static Color textMuted(BuildContext context) => 
      AppColors.textMuted;
  
  static Color border(BuildContext context) => 
      context.isDarkMode ? AppColors.borderDark : AppColors.border;
  
  static Color divider(BuildContext context) => 
      context.isDarkMode ? AppColors.borderDark : AppColors.divider;

  // ============ Durum Renkleri ============
  
  static Color success(BuildContext context) => AppColors.success;
  static Color warning(BuildContext context) => AppColors.warning;
  static Color info(BuildContext context) => AppColors.info;
  
  static Color statusColor(String status) {
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

  // ============ Özel Renkler ============
  
  static Color ratingColor(double rating) => AppColors.ratingColor(rating);
  static Color ratingStar(BuildContext context) => AppColors.ratingStar;
  static Color sentimentColor(String sentiment) => AppColors.sentimentColor(sentiment);

  // ============ Tema Kontrolleri ============
  
  static bool isDarkMode(BuildContext context) => context.isDarkMode;
  static Brightness brightness(BuildContext context) => context.theme.brightness;

  // ============ Dekorasyon Yardımcıları ============
  
  static BoxDecoration cardDecoration(
    BuildContext context, {
    Color? color,
    double borderRadius = 16,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? surface(context),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: context.isDarkMode 
                    ? const Color(0x40000000) 
                    : AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  static InputDecoration inputDecoration(
    BuildContext context, {
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surface(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary(context), width: 2),
      ),
    );
  }

  // ============ Gradient ============
  
  static LinearGradient primaryGradient(BuildContext context) {
    return const LinearGradient(
      colors: AppColors.gradientPrimary,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ============ Glass Theme ============
  
  static GlassTheme? glassTheme(BuildContext context) {
    return context.glassTheme;
  }
}
