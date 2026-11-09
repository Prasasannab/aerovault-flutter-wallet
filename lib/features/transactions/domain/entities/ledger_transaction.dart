import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit, swap, transfer }
enum TransactionStatus { completed, pending, failed }

/// Domain Entity representing an immutable real-time ledger entry
class LedgerTransaction extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final String currency;
  final DateTime timestamp;
  final TransactionType type;
  final TransactionStatus status;
  final String category;
  final String counterparty;
  final double fee;
  final String referenceCode;

  const LedgerTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.currency,
    required this.timestamp,
    required this.type,
    required this.status,
    required this.category,
    required this.counterparty,
    this.fee = 0.0,
    required this.referenceCode,
  });

  bool get isIncome => amount > 0 || type == TransactionType.credit;

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        amount,
        currency,
        timestamp,
        type,
        status,
        category,
        counterparty,
        fee,
        referenceCode,
      ];
}
