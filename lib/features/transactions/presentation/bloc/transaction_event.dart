import 'package:equatable/equatable.dart';
import '../../domain/entities/ledger_transaction.dart';


abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionEvent {
  final String category;
  const LoadTransactionsEvent({this.category = 'All'});

  @override
  List<Object?> get props => [category];
}

class FilterTransactionsEvent extends TransactionEvent {
  final String category;
  const FilterTransactionsEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class AddTransactionEvent extends TransactionEvent {
  final LedgerTransaction transaction;
  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

