import 'package:equatable/equatable.dart';

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
