import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/glass_decorations.dart';
import '../../domain/entities/ledger_transaction.dart';

/// Bank-Grade Detailed Transaction Receipt Sheet with Printable PDF Export Mock
class TransactionReceiptSheet extends StatelessWidget {
  final LedgerTransaction transaction;

  const TransactionReceiptSheet({
    super.key,
    required this.transaction,
  });

  static void show(BuildContext context, LedgerTransaction transaction) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionReceiptSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('MMM dd, yyyy • HH:mm:ss');
    final isIncome = transaction.isIncome;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x3300E599), width: 1.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Success Badge Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isIncome ? AppColors.emeraldGlow : const Color(0x2600D2FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isIncome ? AppColors.emerald : AppColors.cyan,
                  width: 1.5,
                ),
              ),
              child: Icon(
                isIncome ? Icons.check_circle_outline : Icons.receipt_long_outlined,
                color: isIncome ? AppColors.emerald : AppColors.cyan,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),

            Text(
              isIncome ? 'Payment Received' : 'Payment Dispatched',
              style: AppTextStyles.label(
                color: isIncome ? AppColors.emerald : AppColors.cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              '${isIncome ? '+' : ''}${currencyFormatter.format(transaction.amount)}',
              style: AppTextStyles.balanceDisplay(
                fontSize: 32,
                color: isIncome ? AppColors.emerald : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.title,
              style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // Ledger Metadata Container
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                children: [
                  _buildReceiptRow('Status', 'Completed (Settled)'),
                  const Divider(),
                  _buildReceiptRow('Counterparty', transaction.counterparty),
                  const Divider(),
                  _buildReceiptRow('Reference Code', transaction.referenceCode),
                  const Divider(),
                  _buildReceiptRow('Timestamp', dateFormatter.format(transaction.timestamp)),
                  const Divider(),
                  _buildReceiptRow('Payment Method', 'AeroVault Visa •••• 8842'),
                  const Divider(),
                  _buildReceiptRow('Network Ledger Fee', '\$${transaction.fee.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      _showFeedback(context, 'PDF Receipt generated & saved to downloads.');
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('EXPORT PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      _showFeedback(context, 'Transaction link copied to clipboard.');
                    },
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('SHARE RECEIPT'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall(color: AppColors.textDim)),
          Text(
            value,
            style: AppTextStyles.bodySmall(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        content: Text(
          message,
          style: AppTextStyles.bodySmall(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
