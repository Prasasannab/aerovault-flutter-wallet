import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../../transactions/domain/entities/ledger_transaction.dart';

/// Bank-Grade Transaction Confirmation & Digital Receipt Bottom Sheet
class TransactionSuccessSheet extends StatelessWidget {
  final LedgerTransaction transaction;

  const TransactionSuccessSheet({
    super.key,
    required this.transaction,
  });

  static Future<void> show(BuildContext context, LedgerTransaction transaction) {
    HapticFeedback.heavyImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransactionSuccessSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isIncome = transaction.isIncome;
    final amountSign = isIncome ? '+' : '-';
    final formattedAmount =
        '$amountSign\$${transaction.amount.abs().toStringAsFixed(2)}';

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: colors.cardBorder.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 36,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Animated Glowing Checkmark Shield
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.15),
              border: Border.all(
                color: colors.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primaryGlow,
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: colors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Transfer Successful',
            style: AppTextStyles.heading2(color: colors.textPrimary).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cleared instantly via AeroVault Ledger',
            style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Amount Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.cardBorder,
                width: 1,
              ),
            ),
            child: Text(
              formattedAmount,
              style: AppTextStyles.balanceDisplay(
                color: isIncome ? colors.primary : colors.textPrimary,
                fontSize: 32,
              ).copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Receipt Breakdown Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.cardBorder,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildReceiptRow(
                  context,
                  label: 'Counterparty',
                  value: transaction.counterparty,
                ),
                Divider(
                  height: 20,
                  thickness: 0.6,
                  color: colors.cardBorder.withValues(alpha: 0.4),
                ),
                _buildReceiptRow(
                  context,
                  label: 'Transaction ID',
                  value: transaction.referenceCode,
                  isMonospace: true,
                  canCopy: true,
                ),
                Divider(
                  height: 20,
                  thickness: 0.6,
                  color: colors.cardBorder.withValues(alpha: 0.4),
                ),
                _buildReceiptRow(
                  context,
                  label: 'Time',
                  value: 'Just now',
                ),
                Divider(
                  height: 20,
                  thickness: 0.6,
                  color: colors.cardBorder.withValues(alpha: 0.4),
                ),
                _buildReceiptRow(
                  context,
                  label: 'Network Fee',
                  value: '\$0.00 (Zero Fee Prime)',
                  valueColor: colors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Done CTA Button
          BounceButton(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primary.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.primaryGlow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Done',
                style: AppTextStyles.label(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isMonospace = false,
    bool canCopy = false,
    Color? valueColor,
  }) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
            fontSize: 13,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: isMonospace
                  ? AppTextStyles.monospace(
                      color: valueColor ?? colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )
                  : AppTextStyles.bodyMedium(
                      color: valueColor ?? colors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
            ),
            if (canCopy) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied $value to clipboard'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: colors.surfaceElevated,
                    ),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: colors.primary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
