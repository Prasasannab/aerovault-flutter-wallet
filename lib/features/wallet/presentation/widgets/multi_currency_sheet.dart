import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../../transfers/presentation/widgets/swap_crypto_sheet.dart';
import '../../domain/entities/currency_holding.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class MultiCurrencySheet extends StatelessWidget {
  const MultiCurrencySheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    final walletBloc = context.read<WalletBloc>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: walletBloc,
        child: const MultiCurrencySheet(),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String label, String value) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.colors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colors.border),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$label copied to clipboard',
                style: AppTextStyles.bodySmall(color: context.colors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Drag handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGlow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.account_balance_outlined, color: AppColors.emerald, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multi-Currency Studio',
                          style: AppTextStyles.heading2(color: colors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'GLOBAL DEDICATED IBANS & HOLDINGS',
                          style: AppTextStyles.label(color: AppColors.emerald, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                  BounceButton(
                    onTap: () {
                      Navigator.pop(context);
                      SwapCryptoSheet.show(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.emerald),
                          const SizedBox(width: 4),
                          Text(
                            'Exchange',
                            style: AppTextStyles.label(color: AppColors.emerald, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: colors.border),

            // Holdings List
            Expanded(
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state is! WalletLoaded) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.emerald),
                    );
                  }

                  final holdings = state.account.holdings;
                  final selectedCode = state.account.selectedCurrencyCode;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: holdings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final holding = holdings[index];
                      final isSelected = holding.code == selectedCode;
                      return _buildHoldingTile(context, colors, holding, isSelected);
                    },
                  );
                },
              ),
            ),

            // Security note footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 14, color: AppColors.emerald),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All accounts backed by Swiss & US Tier 1 Clearing Facilities',
                      style: AppTextStyles.bodySmall(color: colors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingTile(
    BuildContext context,
    AeroVaultColors colors,
    CurrencyHolding holding,
    bool isSelected,
  ) {
    final balanceFormatted = holding.isCrypto
        ? '${NumberFormat('#,##0.0000').format(holding.balance)} ${holding.code}'
        : (holding.code == 'CHF'
            ? '${NumberFormat('#,##0.00').format(holding.balance)} CHF'
            : '${holding.symbol}${NumberFormat('#,##0.00').format(holding.balance)}');

    return BounceButton(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<WalletBloc>().add(SwitchCurrencyHoldingEvent(holding.code));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceElevated : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.emerald : colors.border,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.emeraldGlow,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Flag / Crypto Badge
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    holding.flagEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Clearing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            holding.name,
                            style: AppTextStyles.bodyMedium(color: colors.textPrimary).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.emerald,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: AppTextStyles.label(
                                  color: AppColors.background,
                                  fontSize: 8.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        holding.clearingNetwork,
                        style: AppTextStyles.bodySmall(color: colors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Balance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balanceFormatted,
                      style: AppTextStyles.monospace(
                        color: colors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '≈ \$${NumberFormat('#,##0.00').format(holding.balanceUsdEquivalent)}',
                      style: AppTextStyles.bodySmall(color: colors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: colors.border.withValues(alpha: 0.5)),
            const SizedBox(height: 8),

            // IBAN / Account Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tag_rounded, size: 14, color: colors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'IBAN:',
                      style: AppTextStyles.label(color: colors.textMuted, fontSize: 10),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      holding.iban,
                      style: AppTextStyles.monospace(
                        color: colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                BounceButton(
                  onTap: () => _copyToClipboard(context, '${holding.code} IBAN', holding.iban),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.copy_rounded, size: 14, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
