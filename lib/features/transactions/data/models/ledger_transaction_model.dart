import '../../domain/entities/ledger_transaction.dart';

/// Data Model for Ledger Transaction with JSON mapping
class LedgerTransactionModel extends LedgerTransaction {
  const LedgerTransactionModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.amount,
    required super.currency,
    required super.timestamp,
    required super.type,
    required super.status,
    required super.category,
    required super.counterparty,
    super.fee = 0.0,
    required super.referenceCode,
  });

  factory LedgerTransactionModel.fromJson(Map<String, dynamic> json) {
    return LedgerTransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.debit,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      category: json['category'] as String,
      counterparty: json['counterparty'] as String,
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      referenceCode: json['reference_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'currency': currency,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'category': category,
      'counterparty': counterparty,
      'fee': fee,
      'reference_code': referenceCode,
    };
  }
}
