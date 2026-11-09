import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/glass_decorations.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_event.dart';
import '../../../analytics/presentation/bloc/analytics_state.dart';
import '../../../analytics/presentation/widgets/portfolio_growth_card.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../../transactions/presentation/widgets/transaction_list_widget.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/virtual_card_widget.dart';
import '../widgets/wallet_header.dart';

import '../../../../main.dart';

/// The Master Neobank & Crypto Wallet Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WalletBloc>(
          create: (_) => sl<WalletBloc>()..add(const LoadWalletEvent()),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => sl<TransactionBloc>()..add(const LoadTransactionsEvent()),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (_) => sl<AnalyticsBloc>()..add(const LoadAnalyticsEvent()),
        ),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Future<void> _onRefresh(BuildContext context) async {
    HapticFeedback.lightImpact();
    context.read<WalletBloc>().add(const LoadWalletEvent());
    context.read<TransactionBloc>().add(const LoadTransactionsEvent());
    context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          color: AppColors.emerald,
          backgroundColor: AppColors.surfaceElevated,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Bar
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    final userName = (state is WalletLoaded)
                        ? state.account.holderName
                        : 'Pasindu G.';
                    return WalletHeader(
                      userName: userName,
                      onSecurityTap: () => _showSecurityAuditDialog(context),
                      onNotificationTap: () => _showNotifications(context),
                    );
                  },
                ),
                const SizedBox(height: 22),

                // 2. 3D Flippable Platinum Virtual Card
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    if (state is WalletLoaded) {
                      return VirtualCardWidget(
                        account: state.account,
                        card: state.card,
                        onToggleBalanceVisibility: () {
                          context.read<WalletBloc>().add(
                                ToggleBalanceVisibilityEvent(
                                  hide: !state.account.isBalanceHidden,
                                ),
                              );
                        },
                        onToggleCardFreeze: (freeze) {
                          context.read<WalletBloc>().add(
                                ToggleCardFreezeEvent(freeze: freeze),
                              );
                        },
                      );
                    } else if (state is WalletError) {
                      return _buildErrorCard(context, state.message);
                    }
                    return _buildCardSkeleton();
                  },
                ),
                const SizedBox(height: 24),

                // 3. Quick Actions Bar
                const QuickActionsBar(),
                const SizedBox(height: 26),

                // 4. Portfolio Growth Curve (Interactive fl_chart)
                BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  builder: (context, state) {
                    if (state is AnalyticsLoaded) {
                      return PortfolioGrowthCard(
                        performance: state.performance,
                        onTimeframeChanged: (tf) {
                          context.read<AnalyticsBloc>().add(ChangeTimeframeEvent(tf));
                        },
                      );
                    } else if (state is AnalyticsError) {
                      return _buildErrorCard(context, state.message);
                    }
                    return _buildChartSkeleton();
                  },
                ),
                const SizedBox(height: 28),

                // 5. Real-Time Transactions Ledger
                BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionLoaded) {
                      return TransactionListWidget(
                        transactions: state.transactions,
                        selectedCategory: state.selectedCategory,
                        onCategorySelected: (cat) {
                          context.read<TransactionBloc>().add(FilterTransactionsEvent(cat));
                        },
                      );
                    } else if (state is TransactionError) {
                      return _buildErrorCard(context, state.message);
                    }
                    return _buildTransactionsSkeleton();
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      height: 215,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.emerald,
        ),
      ),
    );
  }

  Widget _buildChartSkeleton() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.emerald,
        ),
      ),
    );
  }

  Widget _buildTransactionsSkeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          height: 68,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return GlassContainer(
      borderColor: AppColors.error.withValues(alpha: 0.5),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSecurityAuditDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SecurityAuditScreen(),
      ),
    );
  }


  void _showNotifications(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        content: Text(
          'Security alert: New direct deposit from Upwork Global Escrow confirmed.',
          style: AppTextStyles.bodySmall(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
