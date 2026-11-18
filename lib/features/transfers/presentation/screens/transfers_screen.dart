import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/glass_decorations.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/fx_rate.dart';
import '../../domain/entities/scheduled_transfer.dart';
import '../../domain/entities/wire_routing_info.dart';
import '../bloc/transfers_bloc.dart';
import '../bloc/transfers_event.dart';
import '../bloc/transfers_state.dart';
import '../widgets/receive_funds_sheet.dart';
import '../widgets/send_money_sheet.dart';
import '../widgets/swap_crypto_sheet.dart';
import '../widgets/top_up_sheet.dart';
import '../../../earn/presentation/screens/earn_vaults_screen.dart';

class TransfersScreen extends StatelessWidget {
  final bool isStandalone;
  final ScrollController? scrollController;

  const TransfersScreen({
    super.key,
    this.isStandalone = false,
    this.scrollController,
  });

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransfersScreen(isStandalone: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransfersBloc>(
      create: (_) => sl<TransfersBloc>()..add(const LoadTransfersHubEvent()),
      child: _TransfersScreenContent(
        isStandalone: isStandalone,
        scrollController: scrollController,
      ),
    );
  }
}

class _TransfersScreenContent extends StatefulWidget {
  final bool isStandalone;
  final ScrollController? scrollController;

  const _TransfersScreenContent({
    required this.isStandalone,
    this.scrollController,
  });

  @override
  State<_TransfersScreenContent> createState() => _TransfersScreenContentState();
}

class _TransfersScreenContentState extends State<_TransfersScreenContent> {
  final TextEditingController _amountController = TextEditingController(text: '1000');

  String _selectedFrom = 'USD';
  String _selectedTo = 'EUR';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _triggerConversion(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 1000.0;
    context.read<TransfersBloc>().add(
          ConvertCurrencyEvent(
            amount: amount,
            fromCurrency: _selectedFrom,
            toCurrency: _selectedTo,
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

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<TransfersBloc, TransfersState>(
          builder: (context, state) {
            if (state is TransfersLoading) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.emerald),
                    const SizedBox(height: 16),
                    Text(
                      'Accessing Global Interbank Feeds...',
                      style: AppTextStyles.bodySmall(color: colors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            if (state is TransfersError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: AppTextStyles.bodyMedium(color: colors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          context.read<TransfersBloc>().add(const LoadTransfersHubEvent());
                        },
                        child: const Text('Retry Connection'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TransfersLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  context.read<TransfersBloc>().add(const LoadTransfersHubEvent());
                },
                color: colors.primary,
                backgroundColor: colors.surfaceElevated,
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, colors),
                      const SizedBox(height: 18),
                      _buildLaunchpadSection(context, colors),
                      const SizedBox(height: 18),
                      _buildEarnVaultsBanner(context, colors),
                      const SizedBox(height: 24),
                      _buildFxTickerSection(context, colors, state.fxRates),
                      const SizedBox(height: 24),
                      _buildCurrencyCalculator(context, colors, state),
                      const SizedBox(height: 24),
                      _buildStandingOrdersSection(context, colors, state.scheduledTransfers),
                      const SizedBox(height: 24),
                      _buildWireRoutingCard(context, colors, state.wireRouting),
                      const SizedBox(height: 100), // Dock bottom clearance
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AeroVaultColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.isStandalone) ...[
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 16),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transfers & FX Hub',
                    style: AppTextStyles.heading2(color: colors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'INSTITUTIONAL SETTLEMENT & ROUTING',
                    style: AppTextStyles.label(color: AppColors.emerald, fontSize: 9.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.emeraldGlow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'INTERBANK 0.02%',
                    style: AppTextStyles.label(color: AppColors.emerald, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLaunchpadSection(BuildContext context, AeroVaultColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRANSFER ACTIONS',
          style: AppTextStyles.label(color: colors.textMuted),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildLaunchpadTile(
                context,
                colors,
                title: 'Send',
                subtitle: 'Wire Out',
                icon: Icons.arrow_upward_rounded,
                accentColor: AppColors.emerald,
                onTap: () => SendMoneySheet.show(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildLaunchpadTile(
                context,
                colors,
                title: 'Receive',
                subtitle: 'Wire In',
                icon: Icons.arrow_downward_rounded,
                accentColor: AppColors.cyan,
                onTap: () => ReceiveFundsSheet.show(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildLaunchpadTile(
                context,
                colors,
                title: 'Swap',
                subtitle: 'Crypto FX',
                icon: Icons.swap_horiz_rounded,
                accentColor: AppColors.violet,
                onTap: () => SwapCryptoSheet.show(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildLaunchpadTile(
                context,
                colors,
                title: 'Top-up',
                subtitle: 'Instant',
                icon: Icons.add_rounded,
                accentColor: const Color(0xFFFFB020),
                onTap: () => TopUpSheet.show(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarnVaultsBanner(BuildContext context, AeroVaultColors colors) {
    return BounceButton(
      onTap: () => EarnVaultsScreen.navigate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surface,
              AppColors.emerald.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.emerald,
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
                        'CRYPTO YIELD VAULTS',
                        style: AppTextStyles.label(
                          color: AppColors.emerald,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '6.80% APY',
                          style: AppTextStyles.label(
                            color: AppColors.emerald,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Stake ETH, BTC, USD & SOL with FINMA protection',
                    style: AppTextStyles.bodySmall(color: colors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.emerald),
          ],
        ),
      ),
    );
  }

  Widget _buildLaunchpadTile(
    BuildContext context,
    AeroVaultColors colors, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return BounceButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium(color: colors.textPrimary).copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall(color: colors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFxTickerSection(BuildContext context, AeroVaultColors colors, List<FxRate> rates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIVE INSTITUTIONAL FX RATES',
              style: AppTextStyles.label(color: colors.textMuted),
            ),
            Text(
              '24H CHANGE',
              style: AppTextStyles.label(color: colors.textMuted, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: rates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final rate = rates[index];
              return _buildFxCard(context, colors, rate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFxCard(BuildContext context, AeroVaultColors colors, FxRate rate) {
    final isCrypto = rate.baseCurrency == 'BTC' || rate.baseCurrency == 'ETH' || rate.baseCurrency == 'SOL';
    final rateString = isCrypto
        ? NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(rate.rate)
        : rate.rate.toStringAsFixed(4);

    return Container(
      width: 172,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  rate.pair,
                  style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: rate.isPositive
                      ? AppColors.emerald.withValues(alpha: 0.12)
                      : AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${rate.isPositive ? '+' : ''}${rate.change24h.toStringAsFixed(2)}%',
                  style: AppTextStyles.label(
                    color: rate.isPositive ? AppColors.emerald : AppColors.error,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),
          Text(
            rateString,
            style: AppTextStyles.monospace(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(
                rate.isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 14,
                color: rate.isPositive ? AppColors.emerald : AppColors.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  rate.isPositive ? 'Bullish liquidity' : 'Pullback flow',
                  style: AppTextStyles.bodySmall(color: colors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCalculator(
    BuildContext context,
    AeroVaultColors colors,
    TransfersLoaded state,
  ) {
    return GlassContainer(
      backgroundColor: colors.surface,
      borderColor: colors.border,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.currency_exchange_rounded, color: AppColors.emerald, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Instant Interbank Converter',
                    style: AppTextStyles.heading3(color: colors.textPrimary),
                  ),
                ],
              ),
              Text(
                '0% SPREAD',
                style: AppTextStyles.label(color: AppColors.emerald, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Preset Chips
          Row(
            children: [1000, 5000, 25000, 100000].map((preset) {
              final isSelected = _amountController.text == preset.toString();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: BounceButton(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _amountController.text = preset.toString();
                    });
                    _triggerConversion(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.emerald : colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.emerald : colors.border,
                      ),
                    ),
                    child: Text(
                      NumberFormat.compactCurrency(symbol: '\$').format(preset),
                      style: AppTextStyles.label(
                        color: isSelected ? AppColors.background : colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Input & Selectors
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.monospace(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter amount',
                    ),
                    onChanged: (_) => _triggerConversion(context),
                  ),
                ),
                _buildCurrencyDropdown(
                  value: _selectedFrom,
                  currencies: const ['USD', 'EUR', 'GBP', 'CHF', 'BTC'],
                  colors: colors,
                  onChanged: (newVal) {
                    if (newVal != null) {
                      setState(() => _selectedFrom = newVal);
                      _triggerConversion(context);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Output Conversion Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECEIVING AT GUARANTEED SPOT RATE',
                        style: AppTextStyles.label(color: colors.textMuted, fontSize: 9.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedTo == 'BTC' || _selectedTo == 'ETH'
                            ? '${state.convertedAmount.toStringAsFixed(6)} $_selectedTo'
                            : '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(state.convertedAmount)} $_selectedTo',
                        style: AppTextStyles.monospace(
                          color: AppColors.emerald,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildCurrencyDropdown(
                  value: _selectedTo,
                  currencies: const ['EUR', 'USD', 'GBP', 'CHF', 'BTC', 'ETH'],
                  colors: colors,
                  onChanged: (newVal) {
                    if (newVal != null) {
                      setState(() => _selectedTo = newVal);
                      _triggerConversion(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required List<String> currencies,
    required AeroVaultColors colors,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: colors.surfaceElevated,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary, size: 18),
          items: currencies.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                c,
                style: AppTextStyles.bodyMedium(color: colors.textPrimary).copyWith(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (v) {
            HapticFeedback.selectionClick();
            onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildStandingOrdersSection(
    BuildContext context,
    AeroVaultColors colors,
    List<ScheduledTransfer> transfers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'STANDING ORDERS & RECURRING TRANSFERS',
                style: AppTextStyles.label(color: colors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${transfers.where((t) => t.isActive).length} ACTIVE',
              style: AppTextStyles.label(color: AppColors.emerald, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transfers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final transfer = transfers[index];
            return _buildStandingOrderTile(context, colors, transfer);
          },
        ),
      ],
    );
  }

  Widget _buildStandingOrderTile(
    BuildContext context,
    AeroVaultColors colors,
    ScheduledTransfer transfer,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: transfer.isActive ? colors.border : colors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: transfer.isActive
                  ? AppColors.emerald.withValues(alpha: 0.12)
                  : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transfer.category.contains('Cloud')
                  ? Icons.cloud_outlined
                  : (transfer.category.contains('Wealth')
                      ? Icons.account_balance_outlined
                      : (transfer.category.contains('DCA')
                          ? Icons.currency_bitcoin_rounded
                          : Icons.terminal_rounded)),
              color: transfer.isActive ? AppColors.emerald : colors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transfer.title,
                  style: AppTextStyles.bodyMedium(
                    color: transfer.isActive ? colors.textPrimary : colors.textMuted,
                  ).copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${transfer.frequency} • Next: ${transfer.nextExecutionDate}',
                  style: AppTextStyles.bodySmall(color: colors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transfer.currency == 'USD' ? '\$' : (transfer.currency == 'CHF' ? 'CHF ' : '')}${NumberFormat('#,##0.00').format(transfer.amount)}',
                style: AppTextStyles.monospace(
                  color: transfer.isActive ? colors.textPrimary : colors.textMuted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Switch.adaptive(
                value: transfer.isActive,
                activeTrackColor: AppColors.emerald,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  context.read<TransfersBloc>().add(
                        ToggleStandingOrderEvent(
                          transferId: transfer.id,
                          isActive: val,
                        ),
                      );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWireRoutingCard(
    BuildContext context,
    AeroVaultColors colors,
    WireRoutingInfo routing,
  ) {
    return GlassContainer(
      backgroundColor: colors.surface,
      borderColor: colors.border,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: AppColors.cyan, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Swiss Wire Routing Specs',
                    style: AppTextStyles.heading3(color: colors.textPrimary),
                  ),
                ],
              ),
              Text(
                'FINMA TIER 1',
                style: AppTextStyles.label(color: AppColors.cyan, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCopyRow(context, colors, 'Institution', routing.institutionName),
          const Divider(height: 16),
          _buildCopyRow(context, colors, 'Swiss IBAN', routing.swissIban),
          const Divider(height: 16),
          _buildCopyRow(context, colors, 'SWIFT / BIC', routing.swiftBic),
          const Divider(height: 16),
          _buildCopyRow(context, colors, 'Fedwire Routing', routing.fedwireRouting),
          const Divider(height: 16),
          _buildCopyRow(context, colors, 'Clearing Code', routing.clearingCode),
        ],
      ),
    );
  }

  Widget _buildCopyRow(BuildContext context, AeroVaultColors colors, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall(color: colors.textMuted)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.monospace(
                  color: colors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _copyToClipboard(context, label, value),
          icon: Icon(Icons.copy_rounded, color: colors.textSecondary, size: 16),
          tooltip: 'Copy $label',
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(6),
        ),
      ],
    );
  }
}
