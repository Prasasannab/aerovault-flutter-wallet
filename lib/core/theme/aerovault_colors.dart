import 'package:flutter/material.dart';

/// AeroVault Enterprise Theme Extension for Material 3
/// Provides unified dynamic color tokens across Luxury Obsidian Dark and Swiss Platinum Light
class AeroVaultColors extends ThemeExtension<AeroVaultColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDim;
  final Color cardBackground;
  final Color dockBackground;
  final LinearGradient cardGradient;
  final bool isDark;

  const AeroVaultColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDim,
    required this.cardBackground,
    required this.dockBackground,
    required this.cardGradient,
    required this.isDark,
  });

  /// Luxury Obsidian Dark Mode Theme Tokens
  static const AeroVaultColors dark = AeroVaultColors(
    background: Color(0xFF090D16),
    surface: Color(0xFF101726),
    surfaceElevated: Color(0xFF1F2B44),
    border: Color(0xFF1E293B),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFE2E8F0),
    textMuted: Color(0xFF94A3B8),
    textDim: Color(0xFF64748B),
    cardBackground: Color(0xFF101726),
    dockBackground: Color(0xE60D131F),
    cardGradient: LinearGradient(
      begin: Alignment(-0.9, -1.0),
      end: Alignment(0.9, 1.0),
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      colors: [
        Color(0xFF1D2635),
        Color(0xFF0D141F),
        Color(0xFF172230),
        Color(0xFF090E17),
        Color(0xFF141F2B),
      ],
    ),
    isDark: true,
  );

  /// Swiss/Apple Minimalist Platinum Light Mode Theme Tokens
  static const AeroVaultColors light = AeroVaultColors(
    background: Color(0xFFF6F8FC), // Scandinavian frost pearl white
    surface: Color(0xFFFFFFFF),    // Crisp white cards
    surfaceElevated: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),     // Subtle platinum hairline
    textPrimary: Color(0xFF0F172A), // Slate 900
    textSecondary: Color(0xFF334155),
    textMuted: Color(0xFF64748B),
    textDim: Color(0xFF94A3B8),
    cardBackground: Color(0xFFFFFFFF),
    dockBackground: Color(0xF2FFFFFF),
    cardGradient: LinearGradient(
      begin: Alignment(-0.9, -1.0),
      end: Alignment(0.9, 1.0),
      stops: [0.0, 0.3, 0.6, 1.0],
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFF8FAFC),
        Color(0xFFF1F5F9),
        Color(0xFFE2E8F0),
      ],
    ),
    isDark: false,
  );

  @override
  AeroVaultColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDim,
    Color? cardBackground,
    Color? dockBackground,
    LinearGradient? cardGradient,
    bool? isDark,
  }) {
    return AeroVaultColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDim: textDim ?? this.textDim,
      cardBackground: cardBackground ?? this.cardBackground,
      dockBackground: dockBackground ?? this.dockBackground,
      cardGradient: cardGradient ?? this.cardGradient,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AeroVaultColors lerp(ThemeExtension<AeroVaultColors>? other, double t) {
    if (other is! AeroVaultColors) return this;
    return AeroVaultColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      dockBackground: Color.lerp(dockBackground, other.dockBackground, t)!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Convenience BuildContext extension for dynamic theme resolution
extension AeroVaultThemeContext on BuildContext {
  AeroVaultColors get colors =>
      Theme.of(this).extension<AeroVaultColors>() ?? AeroVaultColors.dark;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
