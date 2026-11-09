import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Quick Action Buttons (Send, Receive, Swap, Top-up) with tactile micro-interactions
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
          gradientColors: const [Color(0x2600E599), Color(0x0D00E599)],
          onTap: onSend ?? () => _showActionNotice(context, 'Send Multi-Currency / Crypto Transfer'),
        ),
        _buildActionButton(
          context,
          icon: Icons.arrow_downward_rounded,
          label: 'Receive',
          color: AppColors.cyan,
          gradientColors: const [Color(0x2600D8F6), Color(0x0D00D8F6)],
          onTap: onReceive ?? () => _showActionNotice(context, 'Display Deposit QR & IBAN Details'),
        ),
        _buildActionButton(
          context,
          icon: Icons.swap_horiz_rounded,
          label: 'Swap',
          color: AppColors.violet,
          gradientColors: const [Color(0x267B61FF), Color(0x0D7B61FF)],
          onTap: onSwap ?? () => _showActionNotice(context, 'Instant USD ↔ BTC / ETH Swap Engine'),
        ),
        _buildActionButton(
          context,
          icon: Icons.add_rounded,
          label: 'Top-up',
          color: const Color(0xFFFFB020),
          gradientColors: const [Color(0x26FFB020), Color(0x0DFFB020)],
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
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return BounceButton(
      scaleAmount: 0.94,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.45),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 14,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
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
      ),
    );
  }
}
