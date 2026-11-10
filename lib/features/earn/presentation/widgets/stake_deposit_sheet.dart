import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/staking_vault.dart';
import '../bloc/earn_bloc.dart';
import '../bloc/earn_event.dart';

class StakeDepositSheet extends StatefulWidget {
  final StakingVault vault;
  final bool isUnstake;

  const StakeDepositSheet({
    super.key,
    required this.vault,
    this.isUnstake = false,
  });

  static Future<void> show(BuildContext context, StakingVault vault, {bool isUnstake = false}) {
    HapticFeedback.lightImpact();
    final earnBloc = context.read<EarnBloc>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: earnBloc,
        child: StakeDepositSheet(vault: vault, isUnstake: isUnstake),
      ),
    );
  }

  @override
  State<StakeDepositSheet> createState() => _StakeDepositSheetState();
}

class _StakeDepositSheetState extends State<StakeDepositSheet> {
  late double _amount;
  late double _maxAmount;

  @override
  void initState() {
    super.initState();
    if (widget.isUnstake) {
      _maxAmount = widget.vault.stakedBalance;
      _amount = (_maxAmount * 0.5).clamp(0.01, _maxAmount);
    } else {
      _maxAmount = widget.vault.assetCode == 'ETH'
          ? 25.0
          : (widget.vault.assetCode == 'BTC'
              ? 2.5
              : (widget.vault.assetCode == 'SOL' ? 100.0 : 100000.0));
      _amount = widget.vault.assetCode == 'ETH'
          ? 2.0
          : (widget.vault.assetCode == 'BTC'
              ? 0.2
              : (widget.vault.assetCode == 'SOL' ? 10.0 : 5000.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final vault = widget.vault;
    final currencyFormatter = NumberFormat('#,##0.0000');

    final yearlyRewards = _amount * (vault.apyPercentage / 100);
    final monthlyRewards = yearlyRewards / 12;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: colors.border),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(vault.colorHex).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(vault.colorHex).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    vault.symbol,
                    style: TextStyle(
                      color: Color(vault.colorHex),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isUnstake ? 'Unstake ${vault.assetCode}' : 'Deposit to ${vault.assetCode} Vault',
                        style: AppTextStyles.heading2(color: colors.textPrimary).copyWith(fontSize: 17),
                      ),
                      Text(
                        '${vault.apyPercentage.toStringAsFixed(2)}% APY • ${vault.termLabel}',
                        style: AppTextStyles.label(color: AppColors.emerald, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount Input Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.isUnstake ? 'UNSTAKE AMOUNT' : 'STAKE AMOUNT',
                        style: AppTextStyles.label(color: colors.textMuted, fontSize: 9),
                      ),
                      Text(
                        'Max Available: ${currencyFormatter.format(_maxAmount)} ${vault.assetCode}',
                        style: AppTextStyles.label(color: AppColors.emerald, fontSize: 9.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currencyFormatter.format(_amount)} ${vault.assetCode}',
                        style: AppTextStyles.balanceDisplay(color: colors.textPrimary, fontSize: 24),
                      ),
                      BounceButton(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _amount = _maxAmount);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGlow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'MAX',
                            style: AppTextStyles.label(color: AppColors.emerald, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.emerald,
                      inactiveTrackColor: colors.surface,
                      thumbColor: AppColors.emerald,
                      overlayColor: AppColors.emeraldGlow,
                    ),
                    child: Slider(
                      value: _amount.clamp(0.0, _maxAmount),
                      min: 0.0,
                      max: _maxAmount > 0 ? _maxAmount : 1.0,
                      divisions: 20,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _amount = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Projected Earnings Card (if Staking)
            if (!widget.isUnstake) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PROJECTED MONTHLY REWARD', style: AppTextStyles.label(color: colors.textMuted, fontSize: 8.5)),
                        const SizedBox(height: 3),
                        Text(
                          '+${currencyFormatter.format(monthlyRewards)} ${vault.assetCode}',
                          style: AppTextStyles.monospace(color: AppColors.emerald, fontSize: 12).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('PROJECTED ANNUAL APY', style: AppTextStyles.label(color: colors.textMuted, fontSize: 8.5)),
                        const SizedBox(height: 3),
                        Text(
                          '+${currencyFormatter.format(yearlyRewards)} ${vault.assetCode}',
                          style: AppTextStyles.monospace(color: colors.textPrimary, fontSize: 12).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Button
            BounceButton(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (widget.isUnstake) {
                  context.read<EarnBloc>().add(
                        UnstakeAssetEvent(vaultId: vault.id, amount: _amount),
                      );
                } else {
                  context.read<EarnBloc>().add(
                        StakeAssetEvent(vaultId: vault.id, amount: _amount),
                      );
                }
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: widget.isUnstake ? AppColors.error : AppColors.emerald,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isUnstake
                          ? AppColors.errorGlow
                          : AppColors.emeraldGlow,
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.isUnstake
                        ? 'Confirm Unstake & Return to Wallet'
                        : 'Confirm & Deposit to ${vault.assetCode} Vault',
                    style: AppTextStyles.bodyMedium(color: Colors.black).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
