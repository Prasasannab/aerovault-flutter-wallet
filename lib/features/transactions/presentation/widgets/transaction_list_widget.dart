import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/aerovault_colors.dart';
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
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final primaryAccent = colors.primary;

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
                Text(
                  'Recent Transactions',
                  style: AppTextStyles.heading3().copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Real-Time Settled Ledger',
                  style: AppTextStyles.label(color: colors.textDim),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryAccent.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: primaryAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: AppTextStyles.label(color: primaryAccent, fontSize: 10).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                    color: isSelected
                        ? (isDark ? colors.surfaceElevated : colors.primaryContainer)
                        : colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryAccent : colors.border,
                      width: isSelected ? 1.4 : 1.0,
                    ),
                    boxShadow: isDark
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x0C0F172A),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: AppTextStyles.label(
                        color: isSelected ? primaryAccent : colors.textMuted,
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
                Icon(Icons.inbox_outlined, color: colors.textDim, size: 36),
                const SizedBox(height: 8),
                Text(
                  'No transactions found in "$selectedCategory"',
                  style: AppTextStyles.bodyMedium(color: colors.textDim),
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
