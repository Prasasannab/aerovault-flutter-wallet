import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/bounce_button.dart';
import 'vault_theme_customizer_sheet.dart';

/// Top App Header with User Avatar, Security Badge, Theme & Accent Studio, and Notifications
class WalletHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onSecurityTap;
  final VoidCallback? onNotificationTap;

  const WalletHeader({
    super.key,
    required this.userName,
    this.onSecurityTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final primary = colors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Profile Info with Double Ring Glow Avatar
        Expanded(
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF3B82F6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                          blurRadius: 10,
                          spreadRadius: -2,
                        ),
                      ],
                      border: Border.all(color: const Color(0x55FFFFFF), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                        style: AppTextStyles.heading3(color: Colors.white).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primaryGlow,
                            blurRadius: 5,
                          ),
                        ],
                        border: Border.all(color: colors.background, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Welcome back,',
                          style: AppTextStyles.label(
                            color: colors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: primary.withValues(alpha: 0.35), width: 0.6),
                          ),
                          child: Text(
                            'VIP',
                            style: AppTextStyles.label(
                              color: primary,
                              fontSize: 7.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading3().copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 6),

        // Action Badges (Security Shield, Theme Switcher, Palette Studio & Notifications)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Security Badge
            BounceButton(
              scaleAmount: 0.95,
              onTap: onSecurityTap,
              child: Container(
                height: 33,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primary.withValues(alpha: 0.4), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primaryGlow,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: primary,
                      size: 13.5,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SECURE',
                      style: AppTextStyles.label(
                        color: primary,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),

            // 2. Dynamic Dark/Light Theme Switcher (☀️ / 🌙)
            BounceButton(
              scaleAmount: 0.95,
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<ThemeCubit>().toggleTheme();
              },
              child: Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border, width: 1),
                  boxShadow: isDark
                      ? null
                      : const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    key: ValueKey(isDark),
                    color: isDark ? const Color(0xFFFFD700) : const Color(0xFF6366F1),
                    size: 15.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),

            // 3. Brand & Accent Studio Palette Switcher (🎨)
            BounceButton(
              scaleAmount: 0.95,
              onTap: () => VaultThemeCustomizerSheet.show(context),
              child: Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primaryGlow,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: primary,
                  size: 15.5,
                ),
              ),
            ),
            const SizedBox(width: 5),

            // 4. Notification Bell
            BounceButton(
              scaleAmount: 0.95,
              onTap: onNotificationTap,
              child: Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border, width: 1),
                  boxShadow: isDark
                      ? null
                      : const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: colors.textPrimary,
                      size: 16.5,
                    ),
                    Positioned(
                      top: 7,
                      right: 8,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
