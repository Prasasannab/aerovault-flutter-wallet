import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/currency_holding.dart';
import '../../domain/entities/wallet_account.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import 'multi_currency_sheet.dart';

class MultiCurrencySelectorBar extends StatelessWidget {
  final WalletAccount account;

  const MultiCurrencySelectorBar({
    super.key,
    required this.account,
  });

  String _formatCompact(CurrencyHolding holding) {
    if (holding.isCrypto) {
      return '${holding.balance.toStringAsFixed(holding.code == 'BTC' ? 3 : 2)} ${holding.code}';
    }
    final compact = NumberFormat.compact().format(holding.balance);
    if (holding.code == 'CHF') return '$compact CHF';
    return '${holding.symbol}$compact';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final holdings = account.holdings;
    final selectedCode = account.selectedCurrencyCode;

    if (holdings.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: holdings.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == holdings.length) {
            return BounceButton(
              onTap: () => MultiCurrencySheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune_rounded, size: 13, color: colors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'All Accounts',
                      style: AppTextStyles.label(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final holding = holdings[index];
          final isSelected = holding.code == selectedCode;

          return BounceButton(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<WalletBloc>().add(SwitchCurrencyHoldingEvent(holding.code));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.emerald : colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.emerald : colors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.emeraldGlow,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    holding.flagEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    holding.code,
                    style: AppTextStyles.label(
                      color: isSelected ? AppColors.background : colors.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatCompact(holding),
                    style: AppTextStyles.monospace(
                      color: isSelected ? AppColors.background : colors.textMuted,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
