import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Quick Action Buttons (Send, Receive, Swap, Top-up) with micro-interactions
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          context,
          icon: Icons.arrow_upward_rounded,
          label: 'Send',
          color: AppColors.emerald,
          onTap: onSend ?? () => _showActionNotice(context, 'Send Multi-Currency / Crypto Transfer'),
        ),
        _buildActionButton(
          context,
          icon: Icons.arrow_downward_rounded,
          label: 'Receive',
          color: AppColors.cyan,
          onTap: onReceive ?? () => _showActionNotice(context, 'Display Deposit QR & IBAN Details'),
        ),
        _buildActionButton(
          context,
          icon: Icons.swap_horiz_rounded,
          label: 'Swap',
          color: AppColors.violet,
          onTap: onSwap ?? () => _showActionNotice(context, 'Instant USD ↔ BTC / ETH Swap Engine'),
        ),
        _buildActionButton(
          context,
          icon: Icons.add_rounded,
          label: 'Top-up',
          color: const Color(0xFFFFB020),
          onTap: onTopUp ?? () => _showActionNotice(context, 'Add Funds via Apple Pay or Bank Wire'),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BounceButton(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.18),
                  blurRadius: 16,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall().copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
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
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
