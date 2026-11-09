import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/ledger_transaction.dart';
import 'transaction_receipt_sheet.dart';

/// Single Ledger Transaction Row with Micro-interactions and Dual Theme Support
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
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final incomeColor = isDark ? AppColors.emerald : AppColors.emeraldDark;

    return BounceButton(
      scaleAmount: 0.98,
      onTap: () => TransactionReceiptSheet.show(context, transaction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
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
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.subtitle,
                    style: AppTextStyles.bodySmall(color: colors.textMuted),
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
                    color: isIncome ? incomeColor : colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.referenceCode,
                  style: AppTextStyles.label(color: colors.textDim, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'income':
        return AppColors.emerald;
      case 'tech':
        return AppColors.cyan;
      case 'crypto':
        return AppColors.violet;
      case 'cloud':
        return const Color(0xFF38BDF8);
      case 'travel':
        return const Color(0xFFFFB020);
      default:
        return AppColors.textMuted;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'income':
        return Icons.account_balance_wallet_rounded;
      case 'tech':
        return Icons.devices_rounded;
      case 'crypto':
        return Icons.currency_bitcoin_rounded;
      case 'cloud':
        return Icons.cloud_done_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
