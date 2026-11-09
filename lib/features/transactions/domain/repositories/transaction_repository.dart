import '../../../../core/utils/result.dart';
import '../entities/ledger_transaction.dart';

/// Contract interface for Ledger Transactions
abstract class TransactionRepository {
  Future<Result<List<LedgerTransaction>>> getTransactions({String? categoryFilter});
  Future<Result<LedgerTransaction>> getTransactionById(String id);
}
