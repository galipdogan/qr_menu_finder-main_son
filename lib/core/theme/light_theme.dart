import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'typography.dart';
import 'theme_extensions.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: AppColors.textOnPrimary,
    onSecondary: AppColors.textOnPrimary,
    onSurface: AppColors.textPrimary,
  ),
  textTheme: AppTypography.textTheme.apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  ),
  extensions: const [GlassTheme.light],
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 4,
    shadowColor: AppColors.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24), // Daha yuvarlak kartlar
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 6,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // Pill-shaped butonlar
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // Pill-shaped
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20), // Daha yuvarlak input
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.error),
    ),
  ),
  iconTheme: const IconThemeData(
    color: AppColors.textSecondary,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
  ),
);
