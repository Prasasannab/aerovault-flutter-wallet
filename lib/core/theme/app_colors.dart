import 'package:flutter/material.dart';

/// AeroVault Brand Luxury Dark Palette
class AppColors {
  const AppColors._();

  // Primary Backgrounds
  static const Color background = Color(0xFF090D16); // Deep Obsidian
  static const Color surface = Color(0xFF101726);    // Rich Slate
  static const Color surfaceLight = Color(0xFF172033);
  static const Color surfaceElevated = Color(0xFF1F2B44);

  // Brand Accents
  static const Color emerald = Color(0xFF00E599);       // Neon Emerald Growth
  static const Color emeraldGlow = Color(0x3300E599);
  static const Color emeraldDark = Color(0xFF00B075);

  static const Color violet = Color(0xFF7B61FF);        // Hyper-Violet
  static const Color violetSoft = Color(0xFF9D8BFF);
  static const Color violetGlow = Color(0x337B61FF);

  static const Color cyan = Color(0xFF00D2FF);          // Electric Cyan
  static const Color cyanGlow = Color(0x3300D2FF);

  // Card Gradients
  static const LinearGradient platinumCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
      Color(0xFF0A0F1D),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00E599),
      Color(0xFF00B075),
    ],
  );

  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7B61FF),
      Color(0xFF5A3EE0),
    ],
  );

  // Functional Status Colors
  static const Color success = Color(0xFF00E599);
  static const Color error = Color(0xFFFF4D4F);
  static const Color errorGlow = Color(0x33FF4D4F);
  static const Color warning = Color(0xFFFFB020);
  static const Color info = Color(0xFF00D2FF);

  // Neutral & Typography Colors
  static const Color textPrimary = Color(0xFFFFFFFF);     // Pure White
  static const Color textSecondary = Color(0xFFE2E8F0);   // Platinum
  static const Color textMuted = Color(0xFF94A3B8);       // Slate Muted
  static const Color textDim = Color(0xFF64748B);         // Dark Slate
  static const Color border = Color(0xFF1E293B);          // Subtle Border
  static const Color borderGlow = Color(0x4D00E599);

  // Glassmorphic Overlays
  static const Color glassWhite = Color(0x0FFFFFFF);
  static const Color glassBorder = Color(0x1FFFFFFF);
}
