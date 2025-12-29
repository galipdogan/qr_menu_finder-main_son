import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'typography.dart';
import 'theme_extensions.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surfaceDark,
    error: AppColors.error,
    onPrimary: AppColors.textOnPrimary,
    onSecondary: AppColors.textOnPrimary,
    onSurface: AppColors.textOnDark,
  ),
  textTheme: AppTypography.textTheme.apply(
    bodyColor: AppColors.textOnDark,
    displayColor: AppColors.textOnDark,
  ),
  extensions: const [GlassTheme.dark],
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textOnDark,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 4,
    shadowColor: const Color(0x40000000),
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
      shadowColor: const Color(0x40000000),
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
    fillColor: const Color(0xFF2C2C2C),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20), // Daha yuvarlak input
      borderSide: const BorderSide(color: AppColors.borderDark),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.borderDark),
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
    color: AppColors.borderDark,
    thickness: 1,
  ),
);
