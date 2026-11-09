import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/errors/failures.dart';
import 'package:aerovault/core/utils/result.dart';
import 'package:aerovault/features/transactions/domain/entities/ledger_transaction.dart';
import 'package:aerovault/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:aerovault/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:aerovault/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:aerovault/features/transactions/presentation/bloc/transaction_state.dart';

class MockGetTransactionsUseCase extends Mock implements GetTransactionsUseCase {}

void main() {
  late TransactionBloc transactionBloc;
  late MockGetTransactionsUseCase mockGetTransactionsUseCase;

  final testTransactions = [
    LedgerTransaction(
      id: 'TX-1',
      title: 'Upwork Global Escrow',
      subtitle: 'Payout',
      amount: 4500.0,
      currency: 'USD',
      timestamp: DateTime(2026, 11, 8),
      type: TransactionType.credit,
      status: TransactionStatus.completed,
      category: 'Income',
      counterparty: 'Upwork',
      referenceCode: 'REF-1',
    ),
  ];

  setUp(() {
    mockGetTransactionsUseCase = MockGetTransactionsUseCase();
    transactionBloc = TransactionBloc(getTransactionsUseCase: mockGetTransactionsUseCase);
  });

  tearDown(() {
    transactionBloc.close();
  });

  group('TransactionBloc', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] when LoadTransactionsEvent succeeds',
      build: () {
        when(() => mockGetTransactionsUseCase(categoryFilter: null))
            .thenAnswer((_) async => Result.success(testTransactions));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactionsEvent()),
      expect: () => [
        const TransactionLoading(),
        TransactionLoaded(transactions: testTransactions, selectedCategory: 'All'),
      ],
      verify: (_) {
        verify(() => mockGetTransactionsUseCase(categoryFilter: null)).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] with filtered category when FilterTransactionsEvent is added',
      build: () {
        when(() => mockGetTransactionsUseCase(categoryFilter: 'Income'))
            .thenAnswer((_) async => Result.success(testTransactions));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const FilterTransactionsEvent('Income')),
      expect: () => [
        const TransactionLoading(),
        TransactionLoaded(transactions: testTransactions, selectedCategory: 'Income'),
      ],
      verify: (_) {
        verify(() => mockGetTransactionsUseCase(categoryFilter: 'Income')).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionError] when use case fails',
      build: () {
        when(() => mockGetTransactionsUseCase(categoryFilter: null)).thenAnswer(
          (_) async => Result.error(const ServerFailure(message: 'Database error')),
        );
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactionsEvent()),
      expect: () => [
        const TransactionLoading(),
        const TransactionError('Database error'),
      ],
    );
  });
}
