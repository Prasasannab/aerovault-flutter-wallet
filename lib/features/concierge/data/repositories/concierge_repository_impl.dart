import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/concierge_session.dart';
import '../../domain/repositories/concierge_repository.dart';
import '../datasources/concierge_data_source.dart';

class ConciergeRepositoryImpl implements ConciergeRepository {
  final ConciergeDataSource _dataSource;

  ConciergeRepositoryImpl(this._dataSource);

  @override
  Future<Result<ConciergeSession>> getSession() async {
    try {
      final session = await _dataSource.getSession();
      return Result.success(session);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to connect to Geneva Concierge: $e'));
    }
  }

  @override
  Future<Result<ConciergeSession>> sendMessage(String text) async {
    try {
      final session = await _dataSource.sendMessage(text);
      return Result.success(session);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to send message: $e'));
    }
  }

  @override
  Future<Result<ConciergeSession>> resetSession() async {
    try {
      final session = await _dataSource.resetSession();
      return Result.success(session);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to reset concierge session: $e'));
    }
  }
}
