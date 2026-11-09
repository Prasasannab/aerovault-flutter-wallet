import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/portfolio_performance.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_mock_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsDataSource _dataSource;

  AnalyticsRepositoryImpl(this._dataSource);

  @override
  Future<Result<PortfolioPerformance>> getHistoricalPerformance({required String timeframe}) async {
    try {
      final performance = await _dataSource.getHistoricalPerformance(timeframe: timeframe);
      return Result.success(performance);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to retrieve analytics: $e'));
    }
  }
}
