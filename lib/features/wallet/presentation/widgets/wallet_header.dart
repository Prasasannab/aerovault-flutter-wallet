import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Top App Header with User Avatar, Security Badge, Theme Switcher, and Notifications
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Profile Info with Double Ring Glow Avatar
        Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
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
                        blurRadius: 12,
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
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                      border: Border.all(color: colors.background, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Welcome back,',
                      style: AppTextStyles.label(
                        color: colors.textMuted,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0x1F00E599),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0x3300E599), width: 0.6),
                      ),
                      child: Text(
                        'VIP',
                        style: AppTextStyles.label(
                          color: AppColors.emeraldDark,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  userName,
                  style: AppTextStyles.heading3().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Action Badges (Security Shield, Theme Switcher & Notifications)
        Row(
          children: [
            // 1. Security Badge
            BounceButton(
              scaleAmount: 0.95,
              onTap: onSecurityTap,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: isDark ? 0.1 : 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.emeraldDark,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'SECURE',
                      style: AppTextStyles.label(
                        color: AppColors.emeraldDark,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 2. Dynamic Dark/Light Theme Switcher (☀️ / 🌙)
            BounceButton(
              scaleAmount: 0.95,
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<ThemeCubit>().toggleTheme();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border, width: 1),
                  boxShadow: isDark
                      ? null
                      : const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
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
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 3. Notification Bell
            BounceButton(
              scaleAmount: 0.95,
              onTap: onNotificationTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border, width: 1),
                  boxShadow: isDark
                      ? null
                      : const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
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
                      size: 18,
                    ),
                    Positioned(
                      top: 8,
                      right: 9,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.emerald,
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
