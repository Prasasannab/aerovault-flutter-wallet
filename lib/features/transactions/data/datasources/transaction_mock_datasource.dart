import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/ledger_transaction.dart';
import '../models/ledger_transaction_model.dart';

abstract class TransactionDataSource {
  Future<List<LedgerTransactionModel>> getTransactions({String? categoryFilter});
  Future<LedgerTransactionModel> getTransactionById(String id);
}

class TransactionDataSourceImpl implements TransactionDataSource {
  @override
  Future<List<LedgerTransactionModel>> getTransactions({String? categoryFilter}) async {
    // 350ms network delay simulation
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );

    final now = DateTime.now();

    final allTransactions = <LedgerTransactionModel>[
      LedgerTransactionModel(
        id: 'TX-001-UPWORK',
        title: 'Upwork Global Escrow',
        subtitle: 'Direct Payout Deposit',
        amount: 4500.00,
        currency: 'USD',
        timestamp: now.subtract(const Duration(minutes: 42)),
        type: TransactionType.credit,
        status: TransactionStatus.completed,
        category: 'Income',
        counterparty: 'Upwork Escrow Inc.',
        fee: 0.0,
        referenceCode: 'UPW-8932014-USD',
      ),
      LedgerTransactionModel(
        id: 'TX-002-APPLE',
        title: 'Apple Store US',
        subtitle: 'Hardware Subscription',
        amount: -1299.00,
        currency: 'USD',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 15)),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        category: 'Tech',
        counterparty: 'Apple Inc.',
        fee: 0.0,
        referenceCode: 'APL-449102-USD',
      ),
      LedgerTransactionModel(
        id: 'TX-003-STRIPE',
        title: 'Stripe Connect Payout',
        subtitle: 'Fintech Consulting Revenue',
        amount: 8250.00,
        currency: 'USD',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        type: TransactionType.credit,
        status: TransactionStatus.completed,
        category: 'Income',
        counterparty: 'Stripe Payments LLC',
        fee: 15.0,
        referenceCode: 'STP-9021-TX',
      ),
      LedgerTransactionModel(
        id: 'TX-004-ETH',
        title: 'Ethereum Staking Node',
        subtitle: 'Validator Consensus Reward',
        amount: 184.20,
        currency: 'USD',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        type: TransactionType.credit,
        status: TransactionStatus.completed,
        category: 'Crypto',
        counterparty: 'Beacon Chain 0x71...f9',
        fee: 1.20,
        referenceCode: 'ETH-99201-REWARD',
      ),
      LedgerTransactionModel(
        id: 'TX-005-AWS',
        title: 'Amazon Web Services',
        subtitle: 'Enterprise Cloud Hosting',
        amount: -342.15,
        currency: 'USD',
        timestamp: now.subtract(const Duration(days: 3, hours: 8)),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        category: 'Cloud',
        counterparty: 'Amazon Web Services EMEA',
        fee: 0.0,
        referenceCode: 'AWS-INV-77319',
      ),
      LedgerTransactionModel(
        id: 'TX-006-TESLA',
        title: 'Tesla Supercharger',
        subtitle: 'Autonomous Transit Charging',
        amount: -48.50,
        currency: 'USD',
        timestamp: now.subtract(const Duration(days: 4, hours: 1)),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        category: 'Travel',
        counterparty: 'Tesla Motors Inc.',
        fee: 0.0,
        referenceCode: 'TSL-SC-3301',
      ),
    ];

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter != 'All') {
      return allTransactions
          .where((t) => t.category.toLowerCase() == categoryFilter.toLowerCase())
          .toList();
    }

    return allTransactions;
  }

  @override
  Future<LedgerTransactionModel> getTransactionById(String id) async {
    final list = await getTransactions();
    return list.firstWhere(
      (t) => t.id == id,
      orElse: () => list.first,
    );
  }
}
