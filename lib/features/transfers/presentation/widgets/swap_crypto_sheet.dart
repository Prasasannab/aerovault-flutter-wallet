import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/security/security_service.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../../transactions/domain/entities/ledger_transaction.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../wallet/domain/entities/wallet_account.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../wallet/presentation/bloc/wallet_event.dart';
import '../../../wallet/presentation/bloc/wallet_state.dart';
import 'transaction_success_sheet.dart';

/// Instant Multi-Currency & Crypto Swap Engine Sheet
/// Supports live conversion between USD, BTC, and ETH with animated flip rotation
/// and biometric trade execution.
class SwapCryptoSheet extends StatefulWidget {
  const SwapCryptoSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    final walletBloc = context.read<WalletBloc>();
    final transactionBloc = context.read<TransactionBloc>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: walletBloc),
          BlocProvider.value(value: transactionBloc),
        ],
        child: const SwapCryptoSheet(),
      ),
    );
  }

  @override
  State<SwapCryptoSheet> createState() => _SwapCryptoSheetState();
}

class _SwapCryptoSheetState extends State<SwapCryptoSheet> {
  String _fromAsset = 'USD';
  String _toAsset = 'BTC';
  String _fromAmountString = '5000';
  bool _isSwapping = false;
  double _flipAngle = 0.0;

  // Live conversion rates
  final double _btcRate = 96450.00;
  final double _ethRate = 3420.00;

  double get _inputAmount => double.tryParse(_fromAmountString) ?? 0.0;

  double get _calculatedOutputAmount {
    if (_fromAsset == 'USD' && _toAsset == 'BTC') {
      return _inputAmount / _btcRate;
    } else if (_fromAsset == 'USD' && _toAsset == 'ETH') {
      return _inputAmount / _ethRate;
    } else if (_fromAsset == 'BTC' && _toAsset == 'USD') {
      return _inputAmount * _btcRate;
    } else if (_fromAsset == 'ETH' && _toAsset == 'USD') {
      return _inputAmount * _ethRate;
    } else if (_fromAsset == 'BTC' && _toAsset == 'ETH') {
      return (_inputAmount * _btcRate) / _ethRate;
    } else if (_fromAsset == 'ETH' && _toAsset == 'BTC') {
      return (_inputAmount * _ethRate) / _btcRate;
    }
    return _inputAmount;
  }

  void _flipAssets() {
    HapticFeedback.mediumImpact();
    setState(() {
      _flipAngle += 0.5; // Half turn (180 degrees)
      final temp = _fromAsset;
      _fromAsset = _toAsset;
      _toAsset = temp;

      // Adjust input amount default for readability
      if (_fromAsset == 'BTC') {
        _fromAmountString = '0.05';
      } else if (_fromAsset == 'ETH') {
        _fromAmountString = '1.5';
      } else {
        _fromAmountString = '5000';
      }
    });
  }

  void _onQuickPercentage(double fraction, double availableBalance) {
    HapticFeedback.selectionClick();
    setState(() {
      final amt = availableBalance * fraction;
      if (_fromAsset == 'USD') {
        _fromAmountString = amt.toInt().toString();
      } else {
        _fromAmountString = amt.toStringAsFixed(4);
      }
    });
  }

  Future<void> _executeSwap(WalletAccount account) async {
    final inputVal = _inputAmount;
    if (inputVal <= 0) {
      _showErrorSnackbar('Please enter a valid amount.');
      return;
    }

    // Balance verification
    double availableBalance = account.fiatBalance;
    if (_fromAsset == 'BTC') availableBalance = account.btcBalance;
    if (_fromAsset == 'ETH') availableBalance = account.ethBalance;

    if (inputVal > availableBalance) {
      _showErrorSnackbar('Insufficient $_fromAsset balance.');
      return;
    }

    setState(() => _isSwapping = true);

    try {
      final security = sl<SecurityService>();
      final authenticated = await security.authenticateBiometric(
        localizedReason:
            'Authorize swap of $inputVal $_fromAsset for ${_calculatedOutputAmount.toStringAsFixed(4)} $_toAsset',
      );

      if (!mounted) return;

      if (!authenticated) {
        setState(() => _isSwapping = false);
        _showErrorSnackbar('Biometric verification cancelled.');
        return;
      }

      // Calculate deltas
      double fiatDelta = 0.0;
      double btcDelta = 0.0;
      double ethDelta = 0.0;

      if (_fromAsset == 'USD') {
        fiatDelta -= inputVal;
      } else if (_fromAsset == 'BTC') {
        btcDelta -= inputVal;
      } else if (_fromAsset == 'ETH') {
        ethDelta -= inputVal;
      }

      final outVal = _calculatedOutputAmount;
      if (_toAsset == 'USD') {
        fiatDelta += outVal;
      } else if (_toAsset == 'BTC') {
        btcDelta += outVal;
      } else if (_toAsset == 'ETH') {
        ethDelta += outVal;
      }

      // Create Ledger Record
      final tx = LedgerTransaction(
        id: const Uuid().v4(),
        title: 'Swap $_fromAsset → $_toAsset',
        subtitle: 'Institutional AMM • Executed',
        amount: _toAsset == 'USD' ? outVal : -inputVal,
        currency: _toAsset,
        timestamp: DateTime.now(),
        type: TransactionType.swap,
        status: TransactionStatus.completed,
        category: 'Swap',
        counterparty: 'AeroVault Liquidity Pool',
        fee: 0.0,
        referenceCode: 'SWAP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      );

      // Dispatch to BLoCs
      context.read<TransactionBloc>().add(AddTransactionEvent(tx));
      context.read<WalletBloc>().add(
            AdjustWalletBalanceEvent(
              fiatDelta: fiatDelta,
              btcDelta: btcDelta,
              ethDelta: ethDelta,
            ),
          );

      Navigator.of(context).pop();
      TransactionSuccessSheet.show(context, tx);
    } catch (e) {
      if (mounted) {
        setState(() => _isSwapping = false);
        _showErrorSnackbar('Swap Error: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final walletState = context.watch<WalletBloc>().state;
    final account = (walletState is WalletLoaded)
        ? walletState.account
        : const WalletAccount(
            id: 'mock',
            holderName: 'Pasindu G.',
            fiatBalance: 148250.0,
            btcBalance: 1.842,
            ethBalance: 24.5,
            btcPriceUsd: 96450.0,
            ethPriceUsd: 3420.0,
          );

    double availableFrom = account.fiatBalance;
    if (_fromAsset == 'BTC') availableFrom = account.btcBalance;
    if (_fromAsset == 'ETH') availableFrom = account.ethBalance;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: colors.cardBorder.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 36,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instant Swap',
                          style: AppTextStyles.heading2(color: colors.textPrimary).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Zero Gas Slippage Protected',
                          style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.cardBorder.withValues(alpha: 0.5)),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // 1. "You Pay" Card
                  _buildAssetCard(
                    context,
                    label: 'YOU PAY',
                    asset: _fromAsset,
                    amountText: _fromAmountString,
                    isEditable: true,
                    availableBalance: availableFrom,
                    onAssetChange: (newAsset) {
                      if (newAsset != _toAsset) {
                        setState(() => _fromAsset = newAsset);
                      }
                    },
                    onAmountChange: (val) {
                      setState(() => _fromAmountString = val);
                    },
                  ),

                  // 2. Flip Button (180deg animated rotation)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: BounceButton(
                        onTap: _flipAssets,
                        child: AnimatedRotation(
                          turns: _flipAngle,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutBack,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.primary,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primaryGlow.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.swap_vert_rounded,
                              color: colors.primary,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. "You Receive" Card
                  _buildAssetCard(
                    context,
                    label: 'YOU RECEIVE (ESTIMATED)',
                    asset: _toAsset,
                    amountText: _toAsset == 'USD'
                        ? _calculatedOutputAmount.toStringAsFixed(2)
                        : _calculatedOutputAmount.toStringAsFixed(5),
                    isEditable: false,
                    availableBalance: _toAsset == 'BTC'
                        ? account.btcBalance
                        : (_toAsset == 'ETH'
                            ? account.ethBalance
                            : account.fiatBalance),
                    onAssetChange: (newAsset) {
                      if (newAsset != _fromAsset) {
                        setState(() => _toAsset = newAsset);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quick Percentage Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPercentChip('25%', 0.25, availableFrom),
                      _buildPercentChip('50%', 0.50, availableFrom),
                      _buildPercentChip('75%', 0.75, availableFrom),
                      _buildPercentChip('MAX', 1.00, availableFrom),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Trade Execution Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Exchange Rate',
                          '1 BTC ≈ \$${_btcRate.toStringAsFixed(2)}',
                        ),
                        Divider(
                          height: 16,
                          thickness: 0.6,
                          color: colors.cardBorder.withValues(alpha: 0.4),
                        ),
                        _buildSummaryRow(
                          'Slippage Protection',
                          '0.1% (Guaranteed Exec)',
                          valueColor: colors.primary,
                        ),
                        Divider(
                          height: 16,
                          thickness: 0.6,
                          color: colors.cardBorder.withValues(alpha: 0.4),
                        ),
                        _buildSummaryRow(
                          'Protocol Gas Fee',
                          '\$0.00 (Zero Gas Prime)',
                          valueColor: colors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confirm Swap CTA
                  BounceButton(
                    onTap: _isSwapping ? null : () => _executeSwap(account),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.primary,
                            colors.primary.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primaryGlow,
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _isSwapping
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.fingerprint_rounded,
                                  color: Colors.black,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Confirm Instant Swap',
                                  style: AppTextStyles.label(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentChip(String label, double fraction, double balance) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () => _onQuickPercentage(fraction, balance),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetCard(
    BuildContext context, {
    required String label,
    required String asset,
    required String amountText,
    required bool isEditable,
    required double availableBalance,
    required ValueChanged<String> onAssetChange,
    ValueChanged<String>? onAmountChange,
  }) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.label(
                  color: colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Bal: ${availableBalance.toStringAsFixed(asset == 'USD' ? 2 : 4)} $asset',
                style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Asset Dropdown Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: asset,
                    dropdownColor: colors.surfaceElevated,
                    isDense: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.textSecondary,
                      size: 18,
                    ),
                    items: ['USD', 'BTC', 'ETH'].map((code) {
                      return DropdownMenuItem<String>(
                        value: code,
                        child: Text(
                          code,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onAssetChange(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Amount Input / Display
              Expanded(
                child: isEditable
                    ? TextFormField(
                        initialValue: amountText,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.end,
                        style: AppTextStyles.balanceDisplay(
                          color: colors.textPrimary,
                          fontSize: 26,
                        ).copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: onAmountChange,
                      )
                    : Text(
                        amountText,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.balanceDisplay(
                          color: colors.primary,
                          fontSize: 26,
                        ).copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium(
            color: valueColor ?? colors.textPrimary,
          ).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
