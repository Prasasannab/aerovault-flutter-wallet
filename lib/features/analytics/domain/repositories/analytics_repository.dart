import '../../../../core/utils/result.dart';
import '../entities/portfolio_performance.dart';
import '../entities/wealth_analytics.dart';

/// Contract interface for Portfolio Analytics
abstract class AnalyticsRepository {
  Future<Result<PortfolioPerformance>> getHistoricalPerformance({required String timeframe});
  Future<Result<WealthAnalytics>> getWealthAnalytics();
}
