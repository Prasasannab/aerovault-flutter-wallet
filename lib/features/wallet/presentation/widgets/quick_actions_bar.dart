import 'package:flutter/material.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Quick Action Cards (Send, Receive, Swap, Top-up)
/// 100% horizontally aligned with equal proportional width and zero empty dead-zones
class QuickActionsBar extends StatelessWidget {
  final VoidCallback? onSend;
  final VoidCallback? onReceive;
  final VoidCallback? onSwap;
  final VoidCallback? onTopUp;

  const QuickActionsBar({
    super.key,
    this.onSend,
    this.onReceive,
    this.onSwap,
    this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.arrow_upward_rounded,
            label: 'Send',
            color: AppColors.emerald,
            onTap: onSend ?? () => _showActionNotice(context, 'Send Multi-Currency / Crypto Transfer'),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.arrow_downward_rounded,
            label: 'Receive',
            color: AppColors.cyan,
            onTap: onReceive ?? () => _showActionNotice(context, 'Display Deposit QR & IBAN Details'),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.swap_horiz_rounded,
            label: 'Swap',
            color: AppColors.violet,
            onTap: onSwap ?? () => _showActionNotice(context, 'Instant USD ↔ BTC / ETH Swap Engine'),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.add_rounded,
            label: 'Top-up',
            color: const Color(0xFFFFB020),
            onTap: onTopUp ?? () => _showActionNotice(context, 'Add Funds via Apple Pay or Bank Wire'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return BounceButton(
      scaleAmount: 0.94,
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.38 : 0.35),
            width: 1.1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: isDark ? 0.16 : 0.09),
              color.withValues(alpha: isDark ? 0.04 : 0.01),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? color.withValues(alpha: 0.12)
                  : const Color(0x120F172A),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            if (!isDark)
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.45 : 0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label(
                color: colors.textPrimary,
                fontSize: 10.5,
              ).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        content: Text(
          message,
          style: AppTextStyles.bodySmall(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
