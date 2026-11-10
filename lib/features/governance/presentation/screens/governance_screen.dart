import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../bloc/governance_bloc.dart';
import '../bloc/governance_event.dart';
import '../bloc/governance_state.dart';
import '../widgets/governance_request_card.dart';

class GovernanceScreen extends StatelessWidget {
  const GovernanceScreen({super.key});

  static Future<void> navigate(BuildContext context) {
    HapticFeedback.lightImpact();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<GovernanceBloc>(
          create: (_) => sl<GovernanceBloc>()..add(const LoadGovernanceRequestsEvent()),
          child: const GovernanceScreen(),
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
              'Corporate Governance',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading3(
                color: colors.textPrimary,
              ).copyWith(fontSize: 16),
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
                  'DUAL-CONTROL DUAL-SIGNATURE ENGINE',
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.emerald, size: 13),
                const SizedBox(width: 4),
                Text(
                  'FINMA ART. 47',
                  style: AppTextStyles.label(
                    color: AppColors.emerald,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocConsumer<GovernanceBloc, GovernanceState>(
        listener: (context, state) {
          if (state is GovernanceLoaded && state.toastMessage != null) {
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
          if (state is GovernanceLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.emerald),
            );
          }

          if (state is GovernanceError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to access corporate governance pool',
                      style: AppTextStyles.heading3(color: colors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall(color: colors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    BounceButton(
                      onTap: () {
                        context.read<GovernanceBloc>().add(const LoadGovernanceRequestsEvent());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Retry Connection',
                          style: AppTextStyles.heading3(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is GovernanceLoaded) {
            final activeList = state.selectedTab == 0 ? state.pendingRequests : state.historyRequests;

            return RefreshIndicator(
              color: AppColors.emerald,
              backgroundColor: colors.surface,
              onRefresh: () async {
                context.read<GovernanceBloc>().add(const LoadGovernanceRequestsEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Institutional Governance Telemetry Banner
                    _buildQuorumHeaderBanner(colors, state),

                    const SizedBox(height: 18),

                    // Segmented Tabs: Pending Actions vs Executed Audit Trail
                    _buildSegmentedTabSelector(context, colors, state),

                    const SizedBox(height: 18),

                    // Requests List or Empty State
                    if (activeList.isEmpty)
                      _buildEmptyState(colors, state.selectedTab)
                    else
                      ...activeList.map((req) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GovernanceRequestCard(request: req),
                        );
                      }),
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

  Widget _buildQuorumHeaderBanner(AeroVaultColors colors, GovernanceLoaded state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.surfaceElevated,
            AppColors.emerald.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.emerald,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOVEREIGN TREASURY DUAL-CONTROL',
                      style: AppTextStyles.label(
                        color: AppColors.emerald,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '4 Key Custodians Registered',
                      style: AppTextStyles.heading3(
                        color: colors.textPrimary,
                      ).copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${state.pendingCount} Pending Wires',
                  style: AppTextStyles.label(
                    color: AppColors.warning,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Under Swiss Banking Act Art. 47 & FINMA dual-control mandates, all outbound corporate wires exceeding \$50,000 USD or 1.0 BTC require M-of-N executive hardware enclave authorizations before interbank settlement.',
            style: AppTextStyles.bodySmall(color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabSelector(
    BuildContext context,
    AeroVaultColors colors,
    GovernanceLoaded state,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<GovernanceBloc>().add(const FilterGovernanceTabEvent(0));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: state.selectedTab == 0 ? colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: state.selectedTab == 0 ? Border.all(color: colors.border) : null,
                  boxShadow: state.selectedTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Action Required',
                      style: AppTextStyles.label(
                        color: state.selectedTab == 0 ? colors.textPrimary : colors.textMuted,
                        fontSize: 11,
                        fontWeight: state.selectedTab == 0 ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    if (state.pendingCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${state.pendingCount}',
                          style: AppTextStyles.monospace(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<GovernanceBloc>().add(const FilterGovernanceTabEvent(1));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: state.selectedTab == 1 ? colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: state.selectedTab == 1 ? Border.all(color: colors.border) : null,
                  boxShadow: state.selectedTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Audit Trail (${state.historyRequests.length})',
                  style: AppTextStyles.label(
                    color: state.selectedTab == 1 ? colors.textPrimary : colors.textMuted,
                    fontSize: 11,
                    fontWeight: state.selectedTab == 1 ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AeroVaultColors colors, int selectedTab) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 36,
                color: AppColors.emerald,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              selectedTab == 0
                  ? 'All Quorums Settled'
                  : 'Zero Executed Transactions In Period',
              style: AppTextStyles.heading3(color: colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              selectedTab == 0
                  ? 'There are currently no corporate wires pending your cryptographic hardware signature.'
                  : 'Historical authorizations will appear here once executed by quorum.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
