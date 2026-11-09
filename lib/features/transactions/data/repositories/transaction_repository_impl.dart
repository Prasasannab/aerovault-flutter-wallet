import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/ledger_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_mock_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDataSource _dataSource;

  TransactionRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<LedgerTransaction>>> getTransactions({String? categoryFilter}) async {
    try {
      final list = await _dataSource.getTransactions(categoryFilter: categoryFilter);
      return Result.success(list);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to retrieve transactions: $e'));
    }
  }

  @override
  Future<Result<LedgerTransaction>> getTransactionById(String id) async {
    try {
      final tx = await _dataSource.getTransactionById(id);
      return Result.success(tx);
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to retrieve transaction details: $e'));
    }
  }
}
