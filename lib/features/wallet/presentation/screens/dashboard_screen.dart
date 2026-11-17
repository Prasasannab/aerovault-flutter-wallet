import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/glass_decorations.dart';
import '../../../../core/widgets/bounce_button.dart';
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
import '../widgets/floating_glass_nav_bar.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/virtual_card_widget.dart';
import '../widgets/wallet_header.dart';
import '../widgets/multi_currency_selector_bar.dart';
import '../../../transfers/presentation/widgets/receive_funds_sheet.dart';
import '../../../transfers/presentation/widgets/send_money_sheet.dart';
import '../../../transfers/presentation/widgets/swap_crypto_sheet.dart';
import '../../../transfers/presentation/widgets/top_up_sheet.dart';
import '../../../cards/presentation/screens/cards_screen.dart';
import '../../../analytics/presentation/screens/growth_screen.dart';
import '../../../transfers/presentation/screens/transfers_screen.dart';
import '../../../notifications/presentation/widgets/notifications_sheet.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../governance/presentation/screens/governance_screen.dart';

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

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int _selectedNavIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    HapticFeedback.lightImpact();
    context.read<WalletBloc>().add(const LoadWalletEvent());
    context.read<TransactionBloc>().add(const LoadTransactionsEvent());
    context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent());
  }

  void _onNavItemSelected(int index) {
    if (index == 4) {
      // Security
      _showSecurityAuditDialog(context);
      return;
    }

    setState(() {
      _selectedNavIndex = index;
    });

    if (index == 0) {
      // Vault / Home
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      bottomNavigationBar: FloatingGlassNavBar(
        selectedIndex: _selectedNavIndex,
        onItemSelected: _onNavItemSelected,
      ),
      body: IndexedStack(
        index: _selectedNavIndex.clamp(0, 3),
        children: [
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              color: colors.primary,
              backgroundColor: colors.surfaceElevated,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // 1. Top Header Bar
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    final userName = (state is WalletLoaded)
                        ? state.account.holderName
                        : 'Prasanna B.';
                    return WalletHeader(
                      userName: userName,
                      onProfileTap: () => ProfileScreen.navigate(context),
                      onSecurityTap: () => _showSecurityAuditDialog(context),
                      onNotificationTap: () => _showNotifications(context),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. 3D Flippable Platinum Virtual Card (Strict ISO 1.586:1 Ratio)
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
                    return _buildCardSkeleton(context);
                  },
                ),
                const SizedBox(height: 12),

                // Multi-Currency Sub-Account Selector & Portfolio Drawer
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    if (state is WalletLoaded) {
                      return MultiCurrencySelectorBar(account: state.account);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 12),

                // 3. Proportional Quick Action Cards
                QuickActionsBar(
                  onSend: () => SendMoneySheet.show(context),
                  onReceive: () => ReceiveFundsSheet.show(context),
                  onSwap: () => SwapCryptoSheet.show(context),
                  onTopUp: () => TopUpSheet.show(context),
                ),
                const SizedBox(height: 14),

                // Corporate Dual-Control Governance Action Banner
                _buildGovernancePendingBanner(context, colors),
                const SizedBox(height: 14),

                // 4. Portfolio Growth Curve (Interactive fl_chart with Live Tip Dot)
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
                    return _buildChartSkeleton(context);
                  },
                ),
                const SizedBox(height: 20),

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
                    return _buildTransactionsSkeleton(context);
                  },
                ),
                const SizedBox(height: 100), // Clearance for floating glass bottom dock
              ],
            ),
          ),
        ),
      ),
      const CardsScreen(isStandalone: false),
      const TransfersScreen(isStandalone: false),
      const GrowthScreen(isStandalone: false),
    ],
  ),
);
}

  Widget _buildCardSkeleton(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: context.colors.border),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildChartSkeleton(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.colors.primary,
        ),
      ),
    );
  }

  Widget _buildTransactionsSkeleton(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
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

  Widget _buildGovernancePendingBanner(BuildContext context, AeroVaultColors colors) {
    return BounceButton(
      scaleAmount: 0.98,
      onTap: () => GovernanceScreen.navigate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surface,
              colors.surfaceElevated,
              AppColors.warning.withValues(alpha: 0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'DUAL-CONTROL ACTION REQUIRED',
                        style: AppTextStyles.label(
                          color: AppColors.warning,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '2 PENDING',
                          style: AppTextStyles.monospace(
                            color: Colors.black,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '2 corporate wires await your cryptographic signature',
                    style: AppTextStyles.bodySmall(color: colors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.warning,
              size: 13,
            ),
          ],
        ),
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
    NotificationsSheet.show(context);
  }
}
