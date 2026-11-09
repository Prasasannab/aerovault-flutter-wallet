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
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../wallet/presentation/bloc/wallet_event.dart';
import 'transaction_success_sheet.dart';

/// Interactive Top-Up / Deposit Sheet
/// Supports Apple Pay, Institutional Bank Wire, and Debit Cards
/// with instantaneous balance credit and biometric authorization.
class TopUpSheet extends StatefulWidget {
  const TopUpSheet({super.key});

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
        child: const TopUpSheet(),
      ),
    );
  }

  @override
  State<TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<TopUpSheet> {
  int _selectedMethodIndex = 0; // 0: Apple Pay, 1: Bank Wire, 2: Debit Card
  String _amountString = '1000';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _methods = [
    {
      'title': 'Apple Pay',
      'subtitle': 'Instant deposit • Zero fee',
      'icon': Icons.apple_rounded,
      'badge': 'INSTANT',
    },
    {
      'title': 'Institutional Fedwire',
      'subtitle': 'Zero limit • Clears same day',
      'icon': Icons.account_balance_rounded,
      'badge': 'ZERO FEE',
    },
    {
      'title': 'Debit / Credit Card',
      'subtitle': 'Visa & Mastercard • Instant',
      'icon': Icons.credit_card_rounded,
      'badge': 'INSTANT',
    },
  ];

  void _onQuickAmount(int amount) {
    HapticFeedback.selectionClick();
    setState(() => _amountString = amount.toString());
  }

  Future<void> _handleTopUp() async {
    final amount = double.tryParse(_amountString) ?? 0.0;
    if (amount <= 0) {
      _showErrorSnackbar('Please enter a valid deposit amount.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final selectedMethod = _methods[_selectedMethodIndex];
      final security = sl<SecurityService>();

      final authenticated = await security.authenticateBiometric(
        localizedReason:
            'Authorize instant deposit of \$${amount.toStringAsFixed(2)} via ${selectedMethod['title']}',
      );

      if (!mounted) return;

      if (!authenticated) {
        setState(() => _isProcessing = false);
        _showErrorSnackbar('Deposit authorization cancelled.');
        return;
      }

      // Create Immutable Ledger Record
      final tx = LedgerTransaction(
        id: const Uuid().v4(),
        title: '${selectedMethod['title']} Deposit',
        subtitle: 'Institutional Liquidity • Cleared',
        amount: amount,
        currency: 'USD',
        timestamp: DateTime.now(),
        type: TransactionType.credit,
        status: TransactionStatus.completed,
        category: 'Deposit',
        counterparty: selectedMethod['title'] as String,
        fee: 0.0,
        referenceCode: 'DEP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      );

      // Dispatch to BLoCs
      context.read<TransactionBloc>().add(AddTransactionEvent(tx));
      context.read<WalletBloc>().add(AdjustWalletBalanceEvent(fiatDelta: amount));

      Navigator.of(context).pop();
      TransactionSuccessSheet.show(context, tx);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorSnackbar('Deposit Failed: ${e.toString()}');
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
                        color: const Color(0xFFFFB020).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Color(0xFFFFB020),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Funds',
                          style: AppTextStyles.heading2(color: colors.textPrimary).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Instant USD Liquidity Injection',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Display
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'DEPOSIT AMOUNT',
                          style: AppTextStyles.label(
                            color: colors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\$',
                              style: AppTextStyles.balanceDisplay(
                                color: colors.primary,
                                fontSize: 32,
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _amountString,
                              style: AppTextStyles.balanceDisplay(
                                color: colors.textPrimary,
                                fontSize: 44,
                              ).copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              '.00',
                              style: AppTextStyles.heading2(
                                color: colors.textSecondary,
                              ).copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick Amount Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [250, 1000, 5000, 25000].map((amt) {
                      final isCurrent = _amountString == amt.toString();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _onQuickAmount(amt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? colors.primary.withValues(alpha: 0.15)
                                  : colors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isCurrent ? colors.primary : colors.cardBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '+ \$$amt',
                              style: TextStyle(
                                color: isCurrent ? colors.primary : colors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Method Selection Title
                  Text(
                    'CHOOSE PAYMENT METHOD',
                    style: AppTextStyles.label(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Method Cards List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _methods.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final method = _methods[index];
                      final isSelected = index == _selectedMethodIndex;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedMethodIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary.withValues(alpha: 0.12)
                                : colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? colors.primary : colors.cardBorder,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: colors.surfaceElevated,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? colors.primary : colors.cardBorder,
                                  ),
                                ),
                                child: Icon(
                                  method['icon'] as IconData,
                                  color: isSelected ? colors.primary : colors.textPrimary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method['title'] as String,
                                      style: AppTextStyles.heading3(color: colors.textPrimary).copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      method['subtitle'] as String,
                                      style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  method['badge'] as String,
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Top Up CTA
                  BounceButton(
                    onTap: _isProcessing ? null : _handleTopUp,
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
                      child: _isProcessing
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
                                  'Deposit \$$_amountString.00 Instantly',
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
}
