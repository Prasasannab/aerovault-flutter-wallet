import 'package:equatable/equatable.dart';
import '../../domain/entities/ledger_transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<LedgerTransaction> transactions;
  final String selectedCategory;

  const TransactionLoaded({
    required this.transactions,
    this.selectedCategory = 'All',
  });

  @override
  List<Object?> get props => [transactions, selectedCategory];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
