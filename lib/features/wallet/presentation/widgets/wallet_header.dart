import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Top App Header with User Avatar, Security Badge, and Notifications
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
                      border: Border.all(color: AppColors.background, width: 2),
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
                        color: AppColors.textMuted,
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
                          color: AppColors.emerald,
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
                  ),
                ),
              ],
            ),
          ],
        ),

        // Action Badges (Security Shield & Notifications)
        Row(
          children: [
            BounceButton(
              scaleAmount: 0.95,
              onTap: onSecurityTap,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.emerald,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'SECURE',
                      style: AppTextStyles.label(
                        color: AppColors.emerald,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            BounceButton(
              scaleAmount: 0.95,
              onTap: onNotificationTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
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
