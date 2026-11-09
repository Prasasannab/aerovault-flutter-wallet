import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/ledger_transaction.dart';
import 'transaction_tile.dart';

/// Real-time Ledger Transaction List with Category Filter Pills
class TransactionListWidget extends StatelessWidget {
  final List<LedgerTransaction> transactions;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const TransactionListWidget({
    super.key,
    required this.transactions,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<String> categories = ['All', 'Income', 'Tech', 'Crypto', 'Cloud', 'Travel'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Transactions', style: AppTextStyles.heading3()),
                const SizedBox(height: 2),
                Text(
                  'Real-Time Settled Ledger',
                  style: AppTextStyles.label(color: AppColors.textDim),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emeraldGlow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: AppTextStyles.label(color: AppColors.emerald, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Horizontal Category Filter Pills
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == selectedCategory;

              return BounceButton(
                scaleAmount: 0.95,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onCategorySelected(cat);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.emerald : AppColors.border,
                      width: isSelected ? 1.2 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: AppTextStyles.label(
                        color: isSelected ? AppColors.emerald : AppColors.textMuted,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Transaction Rows
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Icon(Icons.inbox_outlined, color: AppColors.textDim, size: 36),
                const SizedBox(height: 8),
                Text(
                  'No transactions found in "$selectedCategory"',
                  style: AppTextStyles.bodyMedium(color: AppColors.textDim),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return TransactionTile(transaction: transactions[index]);
            },
          ),
      ],
    );
  }
}
