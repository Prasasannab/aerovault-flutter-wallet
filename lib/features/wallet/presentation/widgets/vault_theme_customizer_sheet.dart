import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Modal Bottom Sheet for White-Label Neobank Brand Customization
/// Allows dynamic selection between Curated Luxury Accents (Emerald, Sapphire, Violet, Gold)
/// and Appearance Modes (Dark Obsidian vs Light Platinum)
class VaultThemeCustomizerSheet extends StatelessWidget {
  const VaultThemeCustomizerSheet({super.key});

  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VaultThemeCustomizerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final colors = context.colors;
        final isDark = themeState.isDark;
        final currentAccent = themeState.accent;

        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: colors.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.6) : const Color(0x1A0F172A),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header with Title & White-Label Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Brand & Theme Studio',
                              style: AppTextStyles.heading3(color: colors.textPrimary).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'WHITE-LABEL',
                                style: AppTextStyles.label(
                                  color: colors.primary,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Institutional Neobank Customization & Token System',
                          style: AppTextStyles.bodySmall(color: colors.textMuted),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Section 1: Appearance Mode Toggle (Obsidian Dark vs Platinum Light)
                Text(
                  'APPEARANCE MODE',
                  style: AppTextStyles.label(
                    color: colors.textMuted,
                    fontSize: 10.5,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeOption(
                        context,
                        title: 'Obsidian Dark',
                        icon: Icons.nightlight_round,
                        isSelected: isDark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildModeOption(
                        context,
                        title: 'Platinum Light',
                        icon: Icons.wb_sunny_rounded,
                        isSelected: !isDark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<ThemeCubit>().setThemeMode(ThemeMode.light);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Section 2: Curated Brand Accent Presets
                Text(
                  'CURATED BRAND ACCENT PALETTE',
                  style: AppTextStyles.label(
                    color: colors.textMuted,
                    fontSize: 10.5,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),

                // Accents List
                Column(
                  children: VaultAccent.values.map((accent) {
                    final isSelected = currentAccent == accent;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _buildAccentTile(
                        context,
                        accent: accent,
                        isSelected: isSelected,
                        isDark: isDark,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Done Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'APPLY BRAND ACCENT',
                      style: AppTextStyles.label(
                        color: isDark ? const Color(0xFF090D16) : Colors.white,
                      ).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return BounceButton(
      scaleAmount: 0.96,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: isDark ? 0.16 : 0.10)
              : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? colors.primary : colors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.label(
                color: isSelected ? colors.textPrimary : colors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentTile(
    BuildContext context, {
    required VaultAccent accent,
    required bool isSelected,
    required bool isDark,
  }) {
    final colors = context.colors;
    final accentPrimary = accent.primary(isDark);

    return BounceButton(
      scaleAmount: 0.98,
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<ThemeCubit>().setAccent(accent);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accentPrimary.withValues(alpha: isDark ? 0.14 : 0.08)
              : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentPrimary : colors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentPrimary.withValues(alpha: isDark ? 0.2 : 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Color Swatch with glowing indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: accent.gradient(isDark),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentPrimary.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: isDark ? Colors.black : Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Label & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accent.label,
                    style: AppTextStyles.bodyMedium(color: colors.textPrimary).copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  Text(
                    accent.subtitle,
                    style: AppTextStyles.bodySmall(color: colors.textMuted).copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentPrimary : colors.border,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
