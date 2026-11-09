import 'package:flutter/material.dart';

/// Curated Luxury Brand Accent Palettes for AeroVault White-Label & VIP Tiers
enum VaultAccent {
  emerald(
    id: 'emerald',
    label: 'Neon Emerald',
    subtitle: 'Growth & Crypto Neobank',
    primaryDark: Color(0xFF00E599),
    primaryLight: Color(0xFF00B075),
    glowDark: Color(0x3300E599),
    glowLight: Color(0x2600B075),
    gradientEndDark: Color(0xFF00BFA5),
    gradientEndLight: Color(0xFF00897B),
  ),
  sapphire(
    id: 'sapphire',
    label: 'Electric Sapphire',
    subtitle: 'Institutional Swiss & Trust',
    primaryDark: Color(0xFF0070F3),
    primaryLight: Color(0xFF005AC1),
    glowDark: Color(0x330070F3),
    glowLight: Color(0x26005AC1),
    gradientEndDark: Color(0xFF00C6FF),
    gradientEndLight: Color(0xFF0091EA),
  ),
  violet(
    id: 'violet',
    label: 'Hyper-Violet',
    subtitle: 'Web3 & Digital Wealth',
    primaryDark: Color(0xFF8B5CF6),
    primaryLight: Color(0xFF6D28D9),
    glowDark: Color(0x338B5CF6),
    glowLight: Color(0x266D28D9),
    gradientEndDark: Color(0xFFC084FC),
    gradientEndLight: Color(0xFF7C3AED),
  ),
  gold(
    id: 'gold',
    label: 'Imperial Gold',
    subtitle: 'Private Banking & VIP Metal',
    primaryDark: Color(0xFFFFB020),
    primaryLight: Color(0xFFD97706),
    glowDark: Color(0x33FFB020),
    glowLight: Color(0x26D97706),
    gradientEndDark: Color(0xFFFFC555),
    gradientEndLight: Color(0xFFB45309),
  );

  final String id;
  final String label;
  final String subtitle;
  final Color primaryDark;
  final Color primaryLight;
  final Color glowDark;
  final Color glowLight;
  final Color gradientEndDark;
  final Color gradientEndLight;

  const VaultAccent({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.primaryDark,
    required this.primaryLight,
    required this.glowDark,
    required this.glowLight,
    required this.gradientEndDark,
    required this.gradientEndLight,
  });

  Color primary(bool isDark) => isDark ? primaryDark : primaryLight;
  Color glow(bool isDark) => isDark ? glowDark : glowLight;
  LinearGradient gradient(bool isDark) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [primaryDark, gradientEndDark]
            : [primaryLight, gradientEndLight],
      );
}

/// AeroVault Enterprise Theme Extension for Material 3
/// Provides unified dynamic color tokens across Luxury Obsidian Dark and Swiss Platinum Light
/// with configurable Brand Accent Palettes (Emerald, Sapphire, Violet, Gold)
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

  // Dynamic Brand Accent Tokens
  final VaultAccent accent;
  final Color primary;
  final Color primaryGlow;
  final Color primaryContainer;
  final LinearGradient primaryGradient;

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
    required this.accent,
    required this.primary,
    required this.primaryGlow,
    required this.primaryContainer,
    required this.primaryGradient,
  });

  /// Luxury Obsidian Dark Mode Theme Tokens Factory
  factory AeroVaultColors.dark([VaultAccent accent = VaultAccent.emerald]) {
    final primary = accent.primary(true);
    return AeroVaultColors(
      background: const Color(0xFF090D16),
      surface: const Color(0xFF101726),
      surfaceElevated: const Color(0xFF1F2B44),
      border: const Color(0xFF1E293B),
      textPrimary: const Color(0xFFFFFFFF),
      textSecondary: const Color(0xFFE2E8F0),
      textMuted: const Color(0xFF94A3B8),
      textDim: const Color(0xFF64748B),
      cardBackground: const Color(0xFF101726),
      dockBackground: const Color(0xE60D131F),
      cardGradient: const LinearGradient(
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
      accent: accent,
      primary: primary,
      primaryGlow: accent.glow(true),
      primaryContainer: primary.withValues(alpha: 0.16),
      primaryGradient: accent.gradient(true),
    );
  }

  /// Swiss/Apple Minimalist Platinum Light Mode Theme Tokens Factory
  factory AeroVaultColors.light([VaultAccent accent = VaultAccent.emerald]) {
    final primary = accent.primary(false);
    return AeroVaultColors(
      background: const Color(0xFFEDF2F7), // Swiss Cool Slate Mist canvas
      surface: const Color(0xFFFFFFFF),    // Crisp pure white cards
      surfaceElevated: const Color(0xFFE2E8F0),
      border: const Color(0xFFCBD5E1),     // Crisp Slate-300 structural hairline
      textPrimary: const Color(0xFF0F172A), // Deep Slate 900
      textSecondary: const Color(0xFF334155),
      textMuted: const Color(0xFF64748B),
      textDim: const Color(0xFF94A3B8),
      cardBackground: const Color(0xFFFFFFFF),
      dockBackground: const Color(0xF5FFFFFF),
      cardGradient: const LinearGradient(
        begin: Alignment(-0.9, -1.0),
        end: Alignment(0.9, 1.0),
        stops: [0.0, 0.35, 0.7, 1.0],
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF8FAFC),
          Color(0xFFF1F5F9),
          Color(0xFFE2E8F0),
        ],
      ),
      isDark: false,
      accent: accent,
      primary: primary,
      primaryGlow: accent.glow(false),
      primaryContainer: primary.withValues(alpha: 0.12),
      primaryGradient: accent.gradient(false),
    );
  }

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
    VaultAccent? accent,
    Color? primary,
    Color? primaryGlow,
    Color? primaryContainer,
    LinearGradient? primaryGradient,
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
      accent: accent ?? this.accent,
      primary: primary ?? this.primary,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      primaryGradient: primaryGradient ?? this.primaryGradient,
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
      accent: t < 0.5 ? accent : other.accent,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
    );
  }
}

/// Convenience BuildContext extension for dynamic theme & accent resolution
extension AeroVaultThemeContext on BuildContext {
  AeroVaultColors get colors =>
      Theme.of(this).extension<AeroVaultColors>() ?? AeroVaultColors.dark();
  bool get isDarkMode => colors.isDark;
  Color get primaryColor => colors.primary;
  VaultAccent get currentAccent => colors.accent;
}
