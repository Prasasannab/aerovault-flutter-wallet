import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/ledger_transaction.dart';
import 'transaction_receipt_sheet.dart';

/// Single Ledger Transaction Row with Micro-interactions
class TransactionTile extends StatelessWidget {
  final LedgerTransaction transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isIncome = transaction.isIncome;

    return BounceButton(
      scaleAmount: 0.98,
      onTap: () => TransactionReceiptSheet.show(context, transaction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getCategoryColor(transaction.category).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _getCategoryColor(transaction.category).withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: _getCategoryColor(transaction.category),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.subtitle,
                    style: AppTextStyles.bodySmall(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Amount & Currency
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : ''}${currencyFormatter.format(transaction.amount)}',
                  style: AppTextStyles.balanceDisplay(
                    fontSize: 16,
                    color: isIncome ? AppColors.emerald : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.referenceCode,
                  style: AppTextStyles.label(color: AppColors.textDim, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    return switch (category.toLowerCase()) {
      'income' => AppColors.emerald,
      'tech' => AppColors.cyan,
      'crypto' => AppColors.violet,
      'cloud' => const Color(0xFFFFB020),
      'travel' => const Color(0xFFFF7043),
      _ => AppColors.textMuted,
    };
  }

  IconData _getCategoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'income' => Icons.arrow_downward_rounded,
      'tech' => Icons.devices_rounded,
      'crypto' => Icons.currency_bitcoin_rounded,
      'cloud' => Icons.cloud_outlined,
      'travel' => Icons.electric_bolt_rounded,
      _ => Icons.receipt_outlined,
    };
  }
}
