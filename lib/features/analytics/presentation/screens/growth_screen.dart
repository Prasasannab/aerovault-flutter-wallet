import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/wealth_analytics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../../earn/presentation/screens/earn_vaults_screen.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/portfolio_growth_card.dart';
import '../widgets/statement_pdf_generator.dart';

class GrowthScreen extends StatelessWidget {
  final bool isStandalone;

  const GrowthScreen({super.key, this.isStandalone = false});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GrowthScreen(isStandalone: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsBloc>(
      create: (_) => sl<AnalyticsBloc>()..add(const LoadAnalyticsEvent()),
      child: _GrowthScreenContent(isStandalone: isStandalone),
    );
  }
}

class _GrowthScreenContent extends StatelessWidget {
  final bool isStandalone;

  const _GrowthScreenContent({required this.isStandalone});

  void _exportStatement(BuildContext context, WealthAnalytics wealth) {
    HapticFeedback.mediumImpact();
    StatementPdfGenerator.showStatementPreview(
      context,
      wealth: wealth,
      holderName: 'Prasanna Buddhika',
      accountNumber: 'ACC-8842-ENTERPRISE',
      iban: 'CH93 0076 2011 6238 5295 7',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading || state is AnalyticsInitial) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            if (state is AnalyticsError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 36),
                    const SizedBox(height: 12),
                    Text(state.message, style: AppTextStyles.bodyMedium(color: colors.textPrimary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent()),
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              );
            }

            final loaded = state as AnalyticsLoaded;
            final wealth = loaded.wealthAnalytics ??
                const WealthAnalytics(
                  totalNetWorth: 246553.25,
                  monthlyInflow: 18450.00,
                  monthlyOutflow: 6200.00,
                  financialHealthScore: 94,
                  ratingTier: 'Tier 1 Prime',
                  allocations: [
                    AssetAllocation(
                      symbol: 'USD',
                      name: 'US Treasury & Cash',
                      valueUsd: 84392.50,
                      percentage: 0.342,
                      colorHex: 0xFF00E599,
                    ),
                    AssetAllocation(
                      symbol: 'BTC',
                      name: 'Bitcoin Cold Reserve',
                      valueUsd: 97780.75,
                      percentage: 0.397,
                      colorHex: 0xFFF59E0B,
                    ),
                    AssetAllocation(
                      symbol: 'ETH',
                      name: 'Ethereum Smart Liquidity',
                      valueUsd: 64380.00,
                      percentage: 0.261,
                      colorHex: 0xFF8B5CF6,
                    ),
                  ],
                  spendingBreakdown: [
                    SpendingCategoryBreakdown(
                      category: 'Tech & Infrastructure',
                      amount: 2604.0,
                      percentage: 0.42,
                      colorHex: 0xFF00E599,
                    ),
                    SpendingCategoryBreakdown(
                      category: 'Travel & Concierge',
                      amount: 1736.0,
                      percentage: 0.28,
                      colorHex: 0xFF0070F3,
                    ),
                    SpendingCategoryBreakdown(
                      category: 'Cloud Operations',
                      amount: 1116.0,
                      percentage: 0.18,
                      colorHex: 0xFF8B5CF6,
                    ),
                    SpendingCategoryBreakdown(
                      category: 'Escrow & Wire Fees',
                      amount: 744.0,
                      percentage: 0.12,
                      colorHex: 0xFFFFB020,
                    ),
                  ],
                );

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent());
              },
              color: colors.primary,
              backgroundColor: colors.surfaceElevated,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (isStandalone)
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Wealth Growth',
                                      style: AppTextStyles.heading1(color: colors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Audited portfolio performance & analytics',
                                      style: AppTextStyles.bodySmall(color: colors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _exportStatement(context, wealth),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary.withValues(alpha: 0.15),
                            foregroundColor: colors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                          label: const Text('PDF STMT'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Net Worth & Financial Health Score Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.surface,
                            colors.surfaceElevated,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'TOTAL CONSOLIDATED NET WORTH',
                                  style: AppTextStyles.label(color: colors.textSecondary, fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded, size: 14, color: colors.primary),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${wealth.financialHealthScore}/100 • ${wealth.ratingTier}',
                                      style: AppTextStyles.label(
                                        color: colors.primary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${wealth.totalNetWorth.toStringAsFixed(2)}',
                            style: AppTextStyles.balanceDisplay(color: colors.textPrimary, fontSize: 32),
                          ),
                          const SizedBox(height: 16),

                          // Inflow vs Outflow Cashflow Tiles
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.arrow_downward_rounded, color: Color(0xFF00E599), size: 14),
                                          const SizedBox(width: 4),
                                          Text('Inflow (MOM)', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 9.5)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '+\$${wealth.monthlyInflow.toStringAsFixed(2)}',
                                        style: AppTextStyles.heading3(color: const Color(0xFF00E599)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.arrow_upward_rounded, color: Color(0xFFEF4444), size: 14),
                                          const SizedBox(width: 4),
                                          Text('Outflow (Burn)', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 9.5)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '-\$${wealth.monthlyOutflow.toStringAsFixed(2)}',
                                        style: AppTextStyles.heading3(color: colors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Interactive Portfolio Growth fl_chart Card
                    PortfolioGrowthCard(
                      performance: loaded.performance,
                      onTimeframeChanged: (timeframe) {
                        context.read<AnalyticsBloc>().add(ChangeTimeframeEvent(timeframe));
                      },
                    ),
                    const SizedBox(height: 18),

                    // Institutional Staking & Yield Vaults Studio Banner
                    BounceButton(
                      onTap: () => EarnVaultsScreen.navigate(context),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.surface,
                              AppColors.surfaceElevated,
                              AppColors.emerald.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.35)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emerald.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.emerald.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_wallet_rounded,
                                        color: AppColors.emerald,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'YIELD VAULTS & STAKING',
                                          style: AppTextStyles.label(
                                            color: AppColors.emerald,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          'Proof-of-Stake & Cold Reserves',
                                          style: AppTextStyles.bodySmall(color: colors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.emerald.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'UP TO 6.80% APY',
                                    style: AppTextStyles.label(
                                      color: AppColors.emerald,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ACTIVE STAKED CAPITAL',
                                      style: AppTextStyles.label(color: colors.textSecondary, fontSize: 10),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\$212,160.82',
                                      style: AppTextStyles.monospace(
                                        color: colors.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.emerald,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Open Vaults',
                                        style: AppTextStyles.label(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.black),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Asset Allocation Multi-Segment Stacked Bar Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ASSET ALLOCATION PROFILE',
                                style: AppTextStyles.label(color: colors.textSecondary, fontSize: 11),
                              ),
                              Text(
                                '3 Holdings',
                                style: AppTextStyles.label(color: colors.primary, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Multi-color Stacked Segmented Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 12,
                              child: Row(
                                children: wealth.allocations.map((a) {
                                  return Expanded(
                                    flex: (a.percentage * 100).round(),
                                    child: Container(
                                      color: Color(a.colorHex),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Asset rows
                          ...wealth.allocations.map((a) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(a.colorHex),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        a.name,
                                        style: AppTextStyles.bodyMedium(color: colors.textPrimary),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${a.valueUsd.toStringAsFixed(2)}',
                                        style: AppTextStyles.monospace(
                                          color: colors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${(a.percentage * 100).toStringAsFixed(1)}%)',
                                        style: AppTextStyles.label(color: colors.textSecondary, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Top Spending Categories Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPENDITURE BREAKDOWN',
                            style: AppTextStyles.label(color: colors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 16),

                          ...wealth.spendingBreakdown.map((s) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(s.category, style: AppTextStyles.bodySmall(color: colors.textPrimary)),
                                      Text(
                                        '\$${s.amount.toStringAsFixed(2)} (${(s.percentage * 100).toStringAsFixed(0)}%)',
                                        style: AppTextStyles.monospace(
                                          color: colors.textPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: s.percentage,
                                      minHeight: 5,
                                      backgroundColor: colors.border,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(s.colorHex)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
