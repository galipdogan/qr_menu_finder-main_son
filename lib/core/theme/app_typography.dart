import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 🍊 Modern, rounded typography inspired by food delivery apps
class AppTypography {
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: 48,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 32,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    titleLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    labelLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: AppColors.textOnPrimary,
      letterSpacing: 0.5,
    ),
  );
}
