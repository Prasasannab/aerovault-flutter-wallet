import '../../../../core/utils/result.dart';
import '../entities/portfolio_performance.dart';
import '../repositories/analytics_repository.dart';

/// Single responsibility use case: Retrieve portfolio growth curves for a timeframe
class GetPortfolioPerformanceUseCase {
  final AnalyticsRepository _repository;

  GetPortfolioPerformanceUseCase(this._repository);

  Future<Result<PortfolioPerformance>> call({required String timeframe}) async {
    return await _repository.getHistoricalPerformance(timeframe: timeframe);
  }
}
