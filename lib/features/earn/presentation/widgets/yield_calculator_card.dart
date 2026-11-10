import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/staking_vault.dart';

class YieldCalculatorCard extends StatefulWidget {
  final List<StakingVault> vaults;

  const YieldCalculatorCard({
    super.key,
    required this.vaults,
  });

  @override
  State<YieldCalculatorCard> createState() => _YieldCalculatorCardState();
}

class _YieldCalculatorCardState extends State<YieldCalculatorCard> {
  late StakingVault _selectedVault;
  double _depositAmount = 50000.0;

  final List<double> _presetAmounts = [10000, 25000, 50000, 100000, 250000];

  @override
  void initState() {
    super.initState();
    _selectedVault = widget.vaults.isNotEmpty
        ? widget.vaults.first
        : const StakingVault(
            id: 'mock',
            assetCode: 'ETH',
            assetName: 'Ethereum',
            symbol: '⟠',
            apyPercentage: 4.5,
            stakedBalance: 0,
            stakedBalanceUsd: 0,
            accruedYield: 0,
            accruedYieldUsd: 0,
            term: StakingTerm.flexible,
            clearingAuditor: 'Consensys Diligence',
            riskLevel: 'Low Risk',
            colorHex: 0xFF627EEA,
          );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final returnFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final annualYield = _depositAmount * (_selectedVault.apyPercentage / 100);
    final monthlyYield = annualYield / 12;
    final dailyYield = annualYield / 365;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  size: 20,
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INSTITUTIONAL YIELD SIMULATOR',
                      style: AppTextStyles.label(
                        color: AppColors.emerald,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-Time APY Projections',
                      style: AppTextStyles.heading3(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '+${_selectedVault.apyPercentage.toStringAsFixed(2)}% APY',
                  style: AppTextStyles.label(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Asset Selector Chips
          Text(
            'SELECT ASSET VAULT',
            style: AppTextStyles.label(
              color: colors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.vaults.map((vault) {
                final isSelected = vault.id == _selectedVault.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedVault = vault;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(vault.colorHex).withValues(alpha: 0.2)
                            : colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Color(vault.colorHex)
                              : colors.border.withValues(alpha: 0.5),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            vault.symbol,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(vault.colorHex),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vault.assetCode,
                            style: AppTextStyles.bodyMedium(
                              color: isSelected ? colors.textPrimary : colors.textMuted,
                            ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${vault.apyPercentage}%',
                            style: AppTextStyles.bodySmall(
                              color: isSelected ? AppColors.emerald : colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 22),

          // Deposit Principal Amount Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRINCIPAL CAPITAL',
                style: AppTextStyles.label(
                  color: colors.textMuted,
                  fontSize: 10,
                ),
              ),
              Text(
                currencyFormatter.format(_depositAmount),
                style: AppTextStyles.monospace(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.emerald,
              inactiveTrackColor: colors.border,
              thumbColor: AppColors.emerald,
              overlayColor: AppColors.emerald.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              value: _depositAmount,
              min: 5000,
              max: 500000,
              divisions: 99,
              onChanged: (val) {
                setState(() {
                  _depositAmount = val;
                });
              },
            ),
          ),

          // Preset Capital Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _presetAmounts.map((preset) {
              final isPresetSelected = (_depositAmount - preset).abs() < 100;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _depositAmount = preset;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPresetSelected
                        ? AppColors.emerald.withValues(alpha: 0.2)
                        : colors.surfaceElevated.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPresetSelected
                          ? AppColors.emerald
                          : colors.border.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '\$${(preset / 1000).toInt()}k',
                    style: AppTextStyles.monospace(
                      color: isPresetSelected ? AppColors.emerald : colors.textMuted,
                      fontSize: 12,
                      fontWeight: isPresetSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Projected Yield Matrix Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceElevated.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _YieldMetricTile(
                      label: 'DAILY RETURN',
                      value: returnFormatter.format(dailyYield),
                      subLabel: 'Automated compound',
                      colors: colors,
                    ),
                    Container(width: 1, height: 44, color: colors.border),
                    _YieldMetricTile(
                      label: 'MONTHLY RETURN',
                      value: returnFormatter.format(monthlyYield),
                      subLabel: 'Settled to vault',
                      colors: colors,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: colors.border.withValues(alpha: 0.4), height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ESTIMATED ANNUAL YIELD',
                          style: AppTextStyles.label(
                            color: colors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Based on ${_selectedVault.termLabel}',
                          style: AppTextStyles.bodySmall(
                            color: colors.textMuted.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      returnFormatter.format(annualYield),
                      style: AppTextStyles.monospace(
                        color: AppColors.emerald,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YieldMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String subLabel;
  final dynamic colors;

  const _YieldMetricTile({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label(
              color: colors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.monospace(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: AppTextStyles.bodySmall(
              color: colors.textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
