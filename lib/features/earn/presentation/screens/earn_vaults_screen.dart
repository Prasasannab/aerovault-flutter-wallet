import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/staking_vault.dart';
import '../../domain/entities/yield_summary.dart';
import '../bloc/earn_bloc.dart';
import '../bloc/earn_event.dart';
import '../bloc/earn_state.dart';
import '../widgets/stake_deposit_sheet.dart';
import '../widgets/yield_calculator_card.dart';

class EarnVaultsScreen extends StatelessWidget {
  const EarnVaultsScreen({super.key});

  static Future<void> navigate(BuildContext context) {
    HapticFeedback.lightImpact();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<EarnBloc>(
          create: (_) => sl<EarnBloc>()..add(const LoadEarnVaultsEvent()),
          child: const EarnVaultsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 18),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yield Vaults & Staking',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading3(
                color: colors.textPrimary,
              ).copyWith(fontSize: 15),
            ),
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.emerald,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'VALIDATOR POOL',
                  style: AppTextStyles.label(
                    color: AppColors.emerald,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.emerald, size: 14),
                const SizedBox(width: 4),
                Text(
                  'FINMA AUDITED',
                  style: AppTextStyles.label(
                    color: AppColors.emerald,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocConsumer<EarnBloc, EarnState>(
        listener: (context, state) {
          if (state is EarnLoaded && state.toastMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.toastMessage!,
                  style: AppTextStyles.bodyMedium(
                    color: Colors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppColors.surfaceElevated,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.emerald, width: 1),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EarnLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.emerald),
            );
          }

          if (state is EarnError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load earn vaults',
                      style: AppTextStyles.heading3(color: colors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium(color: colors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    BounceButton(
                      onTap: () {
                        context.read<EarnBloc>().add(const LoadEarnVaultsEvent());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Retry Connection',
                          style: AppTextStyles.heading3(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is EarnLoaded) {
            return RefreshIndicator(
              color: AppColors.emerald,
              backgroundColor: colors.surface,
              onRefresh: () async {
                context.read<EarnBloc>().add(const LoadEarnVaultsEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Staking Overview Card
                    _StakingHeroCard(
                      summary: state.summary,
                      onClaimAll: () {
                        HapticFeedback.heavyImpact();
                        context.read<EarnBloc>().add(const ClaimAllYieldEvent());
                      },
                    ),

                    const SizedBox(height: 16),

                    // Multi-Horizon Projections Row
                    _ProjectionsRow(summary: state.summary),

                    const SizedBox(height: 28),

                    // Active Staking Vaults Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACTIVE PROTOCOL VAULTS',
                              style: AppTextStyles.label(
                                color: colors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Proof-of-Stake & Fixed Cold Reserves',
                              style: AppTextStyles.bodySmall(
                                color: colors.textMuted.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.border),
                          ),
                          child: Text(
                            '${state.vaults.length} Vaults Active',
                            style: AppTextStyles.monospace(
                              color: AppColors.emerald,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Vault Cards List
                    ...state.vaults.map((vault) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _VaultCard(
                          vault: vault,
                          onStake: () => StakeDepositSheet.show(context, vault, isUnstake: false),
                          onUnstake: () => StakeDepositSheet.show(context, vault, isUnstake: true),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Institutional APY Calculator
                    YieldCalculatorCard(vaults: state.vaults),

                    const SizedBox(height: 24),

                    // Institutional Security & Slashing Guarantee Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_outlined, color: AppColors.emerald, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Enterprise Custody & Slashing Guarantee',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.heading3(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'All staking validator nodes run in Tier IV Zurich data centers under FINMA oversight. 100% principal slashing coverage underwritten by Swiss Re consortium.',
                            style: AppTextStyles.bodySmall(
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            alignment: WrapAlignment.spaceBetween,
                            children: const [
                              _GuaranteeBadge(label: 'Zero Co-Mingling', icon: Icons.lock_clock_outlined),
                              _GuaranteeBadge(label: 'MPC Private Keys', icon: Icons.vpn_key_outlined),
                              _GuaranteeBadge(label: 'Quarterly Audits', icon: Icons.assessment_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StakingHeroCard extends StatelessWidget {
  final YieldSummary summary;
  final VoidCallback onClaimAll;

  const _StakingHeroCard({
    required this.summary,
    required this.onClaimAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final usdFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            AppColors.surfaceElevated,
            AppColors.emerald.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL STAKED CAPITAL',
                style: AppTextStyles.label(
                  color: colors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.emerald, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'ETA: ${summary.nextPayoutEta}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label(
                            color: AppColors.emerald,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            usdFormatter.format(summary.totalStakedUsd),
            style: AppTextStyles.monospace(
              color: colors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceElevated.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACCRUED UNCLAIMED YIELD',
                      style: AppTextStyles.label(
                        color: colors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${usdFormatter.format(summary.totalAccruedYieldUsd)}',
                      style: AppTextStyles.monospace(
                        color: AppColors.emerald,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                BounceButton(
                  onTap: summary.totalAccruedYieldUsd > 0 ? onClaimAll : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: summary.totalAccruedYieldUsd > 0
                          ? AppColors.emeraldGradient
                          : null,
                      color: summary.totalAccruedYieldUsd > 0 ? null : colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: summary.totalAccruedYieldUsd > 0
                          ? [
                              BoxShadow(
                                color: AppColors.emerald.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.currency_exchange_rounded,
                          size: 16,
                          color: summary.totalAccruedYieldUsd > 0 ? Colors.black : colors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Claim All',
                          style: AppTextStyles.heading3(
                            color: summary.totalAccruedYieldUsd > 0 ? Colors.black : colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionsRow extends StatelessWidget {
  final YieldSummary summary;

  const _ProjectionsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Row(
      children: [
        _ProjectionCard(
          title: 'Daily Projected',
          value: '+${formatter.format(summary.dailyProjectedYieldUsd)}',
          colors: colors,
        ),
        const SizedBox(width: 10),
        _ProjectionCard(
          title: 'Monthly Run-Rate',
          value: '+${formatter.format(summary.monthlyProjectedYieldUsd)}',
          colors: colors,
        ),
        const SizedBox(width: 10),
        _ProjectionCard(
          title: 'Annual APY Output',
          value: '+${formatter.format(summary.yearlyProjectedYieldUsd)}',
          colors: colors,
          isHighlight: true,
        ),
      ],
    );
  }
}

class _ProjectionCard extends StatelessWidget {
  final String title;
  final String value;
  final dynamic colors;
  final bool isHighlight;

  const _ProjectionCard({
    required this.title,
    required this.value,
    required this.colors,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isHighlight
              ? AppColors.emerald.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlight
                ? AppColors.emerald.withValues(alpha: 0.35)
                : colors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label(
                color: colors.textMuted,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.monospace(
                color: isHighlight ? AppColors.emerald : colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultCard extends StatelessWidget {
  final StakingVault vault;
  final VoidCallback onStake;
  final VoidCallback onUnstake;

  const _VaultCard({
    required this.vault,
    required this.onStake,
    required this.onUnstake,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currencyFormatter = NumberFormat('#,##0.0000');
    final usdFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Asset Name, Risk Badge, APY
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(vault.colorHex).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(vault.colorHex).withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  vault.symbol,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(vault.colorHex),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vault.assetName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.heading3(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            vault.assetCode,
                            style: AppTextStyles.label(
                              color: colors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.shield_rounded, size: 12, color: AppColors.emerald),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vault.clearingAuditor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall(
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${vault.apyPercentage.toStringAsFixed(2)}%',
                    style: AppTextStyles.monospace(
                      color: AppColors.emerald,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'NET APY',
                    style: AppTextStyles.label(
                      color: colors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: colors.border.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: 14),

          // Staked Balance & Accrued Yield Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENTLY STAKED',
                      style: AppTextStyles.label(
                        color: colors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormatter.format(vault.stakedBalance)} ${vault.assetCode}',
                      style: AppTextStyles.monospace(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      usdFormatter.format(vault.stakedBalanceUsd),
                      style: AppTextStyles.bodySmall(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 42, color: colors.border.withValues(alpha: 0.5)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACCRUED EARNINGS',
                      style: AppTextStyles.label(
                        color: colors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${currencyFormatter.format(vault.accruedYield)} ${vault.assetCode}',
                      style: AppTextStyles.monospace(
                        color: AppColors.emerald,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '+${usdFormatter.format(vault.accruedYieldUsd)}',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.emerald.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Term badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceElevated.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_clock_outlined, size: 14, color: AppColors.emerald),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Term: ${vault.termLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall(
                      color: colors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    vault.riskLevel,
                    style: AppTextStyles.label(
                      color: AppColors.emerald,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: Stake / Deposit & Unstake
          Row(
            children: [
              Expanded(
                child: BounceButton(
                  onTap: onStake,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.emeraldGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.black),
                        const SizedBox(width: 6),
                        Text(
                          'Stake / Deposit',
                          style: AppTextStyles.heading3(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (vault.stakedBalance > 0)
                Expanded(
                  child: BounceButton(
                    onTap: onUnstake,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_circle_outline_rounded, size: 16, color: colors.textPrimary),
                          const SizedBox(width: 6),
                          Text(
                            'Unstake',
                            style: AppTextStyles.bodyMedium(
                              color: colors.textPrimary,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuaranteeBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _GuaranteeBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.emerald),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.label(
            color: colors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
