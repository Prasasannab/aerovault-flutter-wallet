import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AeroVault Typography System
class AppTextStyles {
  const AppTextStyles._();

  // Balance & Big Currency Display (Tabular monospace feel)
  static TextStyle balanceDisplay({
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.5,
    );
  }

  // Headings
  static TextStyle heading1({Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.4,
    );
  }

  static TextStyle heading2({Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle heading3({Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: -0.2,
    );
  }

  // Body Text
  static TextStyle bodyLarge({Color color = AppColors.textSecondary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.45,
    );
  }

  static TextStyle bodyMedium({Color color = AppColors.textSecondary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle bodySmall({Color color = AppColors.textMuted}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.35,
    );
  }

  // Labels & Badges
  static TextStyle label({
    Color color = AppColors.textMuted,
    FontWeight fontWeight = FontWeight.w600,
    double fontSize = 11,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.8,
    );
  }

  // Card Numbers (Monospace look)
  static TextStyle cardNumber({Color color = AppColors.textPrimary}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: 2.0,
    );
  }

  // Monospace code & identifiers
  static TextStyle monospace({
    Color color = AppColors.textPrimary,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
