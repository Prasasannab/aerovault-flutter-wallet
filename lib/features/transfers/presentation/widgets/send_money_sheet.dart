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
import '../../../wallet/presentation/bloc/wallet_state.dart';
import 'transaction_success_sheet.dart';

/// Interactive Send Money Bottom Sheet
/// Supports Contact quick-selection, dynamic currency keypad, balance validation,
/// and hardware FaceID / Biometric authorization.
class SendMoneySheet extends StatefulWidget {
  const SendMoneySheet({super.key});

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
        child: const SendMoneySheet(),
      ),
    );
  }

  @override
  State<SendMoneySheet> createState() => _SendMoneySheetState();
}

class _SendMoneySheetState extends State<SendMoneySheet> {
  final List<Map<String, String>> _contacts = [
    {
      'name': 'Elena Rostova',
      'role': 'VP Finance',
      'avatar': 'ER',
      'iban': 'CH93 **** 5295',
    },
    {
      'name': 'Alexander Wright',
      'role': 'Angel Syndicate',
      'avatar': 'AW',
      'iban': 'US02 **** 9102',
    },
    {
      'name': 'Sophie Dubois',
      'role': 'Family Office',
      'avatar': 'SD',
      'iban': 'FR76 **** 4410',
    },
    {
      'name': 'Marcus Vance',
      'role': 'Venture Partner',
      'avatar': 'MV',
      'iban': 'GB82 **** 8831',
    },
  ];

  int _selectedContactIndex = 0;
  String _amountString = '500';
  bool _isAuthorizing = false;

  void _onKeyPress(String value) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_amountString == '0') {
        _amountString = value;
      } else if (_amountString.length < 7) {
        _amountString += value;
      }
    });
  }

  void _onBackspace() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_amountString.length > 1) {
        _amountString = _amountString.substring(0, _amountString.length - 1);
      } else {
        _amountString = '0';
      }
    });
  }

  void _onQuickAmount(int amount) {
    HapticFeedback.selectionClick();
    setState(() {
      _amountString = amount.toString();
    });
  }

  Future<void> _handleTransfer(double currentBalance) async {
    final amount = double.tryParse(_amountString) ?? 0.0;
    if (amount <= 0) {
      _showErrorSnackbar('Please enter a valid transfer amount.');
      return;
    }

    if (amount > currentBalance) {
      _showErrorSnackbar('Insufficient funds. Available: \$${currentBalance.toStringAsFixed(2)}');
      return;
    }

    setState(() => _isAuthorizing = true);

    try {
      final selectedContact = _contacts[_selectedContactIndex];
      final security = sl<SecurityService>();

      // Prompt Biometric / FaceID Authorization
      final authenticated = await security.authenticateBiometric(
        localizedReason: 'Authorize transfer of \$${amount.toStringAsFixed(2)} to ${selectedContact['name']}',
      );

      if (!mounted) return;

      if (!authenticated) {
        setState(() => _isAuthorizing = false);
        _showErrorSnackbar('Biometric verification cancelled or unavailable.');
        return;
      }

      // Create Immutable Ledger Transaction
      final transaction = LedgerTransaction(
        id: const Uuid().v4(),
        title: selectedContact['name']!,
        subtitle: 'Institutional Wire • Cleared',
        amount: -amount,
        currency: 'USD',
        timestamp: DateTime.now(),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        category: 'Transfer',
        counterparty: selectedContact['name']!,
        fee: 0.0,
        referenceCode: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      );

      // Dispatch to BLoCs
      context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
      context.read<WalletBloc>().add(AdjustWalletBalanceEvent(fiatDelta: -amount));

      // Close this sheet and display luxury confirmation receipt
      Navigator.of(context).pop();
      TransactionSuccessSheet.show(context, transaction);
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthorizing = false);
        _showErrorSnackbar('Security Exception: ${e.toString()}');
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
    final currentFiatBalance = (walletState is WalletLoaded)
        ? walletState.account.fiatBalance
        : 148250.00;

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
                        Icons.arrow_upward_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send Money',
                          style: AppTextStyles.heading2(color: colors.textPrimary).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Available: \$${currentFiatBalance.toStringAsFixed(2)}',
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
                  // Contact Selector Title
                  Text(
                    'SELECT RECIPIENT',
                    style: AppTextStyles.label(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Contacts List
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _contacts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        final isSelected = index == _selectedContactIndex;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedContactIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 110,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary.withValues(alpha: 0.12)
                                  : colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : colors.cardBorder,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isSelected
                                      ? colors.primary
                                      : colors.surfaceElevated,
                                  child: Text(
                                    contact['avatar']!,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  contact['name']!.split(' ').first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.label(
                                    color: isSelected
                                        ? colors.primary
                                        : colors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Big Currency Amount Display
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'ENTER AMOUNT',
                          style: AppTextStyles.label(
                            color: colors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                    children: [100, 500, 1000, 2500].map((amt) {
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
                                color: isCurrent
                                    ? colors.primary
                                    : colors.cardBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '\$$amt',
                              style: TextStyle(
                                color: isCurrent
                                    ? colors.primary
                                    : colors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Custom Numeric Keypad
                  _buildNumericKeypad(context),
                  const SizedBox(height: 20),

                  // Transfer Guarantee Pill
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: colors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Institutional SEPA/Fedwire • Zero Fee • Instant',
                            style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Authorize CTA
                  BounceButton(
                    onTap: _isAuthorizing
                        ? null
                        : () => _handleTransfer(currentFiatBalance),
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
                      child: _isAuthorizing
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
                                  'Authorize \$$_amountString.00 Transfer',
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

  Widget _buildNumericKeypad(BuildContext context) {
    final colors = context.colors;

    Widget buildKey(String val) {
      return Expanded(
        child: BounceButton(
          onTap: () => _onKeyPress(val),
          child: Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.cardBorder.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              val,
              style: AppTextStyles.heading2(color: colors.textPrimary).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [buildKey('1'), buildKey('2'), buildKey('3')],
        ),
        Row(
          children: [buildKey('4'), buildKey('5'), buildKey('6')],
        ),
        Row(
          children: [buildKey('7'), buildKey('8'), buildKey('9')],
        ),
        Row(
          children: [
            Expanded(
              child: BounceButton(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _amountString = '0');
                },
                child: Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.cardBorder.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'C',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            buildKey('0'),
            Expanded(
              child: BounceButton(
                onTap: _onBackspace,
                child: Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.cardBorder.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.backspace_outlined,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
