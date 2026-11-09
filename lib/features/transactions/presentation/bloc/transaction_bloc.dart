import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;

  TransactionBloc({required this.getTransactionsUseCase})
      : super(const TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<FilterTransactionsEvent>(_onFilterTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    final result = await getTransactionsUseCase(
      categoryFilter: event.category == 'All' ? null : event.category,
    );

    result.fold(
      onSuccess: (transactions) => emit(
        TransactionLoaded(
          transactions: transactions,
          selectedCategory: event.category,
        ),
      ),
      onError: (failure) => emit(TransactionError(failure.message)),
    );
  }

  Future<void> _onFilterTransactions(
    FilterTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    final result = await getTransactionsUseCase(
      categoryFilter: event.category == 'All' ? null : event.category,
    );

    result.fold(
      onSuccess: (transactions) => emit(
        TransactionLoaded(
          transactions: transactions,
          selectedCategory: event.category,
        ),
      ),
      onError: (failure) => emit(TransactionError(failure.message)),
    );
  }
}
