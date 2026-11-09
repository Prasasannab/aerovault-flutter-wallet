import '../../../../core/utils/result.dart';
import '../entities/ledger_transaction.dart';
import '../repositories/transaction_repository.dart';

/// Single responsibility use case: Retrieve filtered or complete ledger transactions
class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  Future<Result<List<LedgerTransaction>>> call({String? categoryFilter}) async {
    return await _repository.getTransactions(categoryFilter: categoryFilter);
  }
}
