import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/portfolio_performance.dart';
import '../models/portfolio_performance_model.dart';

abstract class AnalyticsDataSource {
  Future<PortfolioPerformanceModel> getHistoricalPerformance({required String timeframe});
}

class AnalyticsDataSourceImpl implements AnalyticsDataSource {
  @override
  Future<PortfolioPerformanceModel> getHistoricalPerformance({required String timeframe}) async {
    // 350ms network latency simulation
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );

    return switch (timeframe.toUpperCase()) {
      '1W' => const PortfolioPerformanceModel(
          timeframe: '1W',
          netGrowthUsd: 2840.00,
          percentageGrowth: 3.48,
          isPositive: true,
          points: [
            PerformancePoint(x: 0, y: 81550.00, dateLabel: 'Mon'),
            PerformancePoint(x: 1, y: 82100.00, dateLabel: 'Tue'),
            PerformancePoint(x: 2, y: 80900.00, dateLabel: 'Wed'),
            PerformancePoint(x: 3, y: 83400.00, dateLabel: 'Thu'),
            PerformancePoint(x: 4, y: 82800.00, dateLabel: 'Fri'),
            PerformancePoint(x: 5, y: 84100.00, dateLabel: 'Sat'),
            PerformancePoint(x: 6, y: 84392.50, dateLabel: 'Sun'),
          ],
        ),
      '1Y' => const PortfolioPerformanceModel(
          timeframe: '1Y',
          netGrowthUsd: 27400.00,
          percentageGrowth: 48.12,
          isPositive: true,
          points: [
            PerformancePoint(x: 0, y: 56992.50, dateLabel: 'Jan'),
            PerformancePoint(x: 1, y: 61200.00, dateLabel: 'Mar'),
            PerformancePoint(x: 2, y: 59800.00, dateLabel: 'May'),
            PerformancePoint(x: 3, y: 68400.00, dateLabel: 'Jul'),
            PerformancePoint(x: 4, y: 74200.00, dateLabel: 'Sep'),
            PerformancePoint(x: 5, y: 84392.50, dateLabel: 'Nov'),
          ],
        ),
      'ALL' => const PortfolioPerformanceModel(
          timeframe: 'ALL',
          netGrowthUsd: 54900.00,
          percentageGrowth: 186.45,
          isPositive: true,
          points: [
            PerformancePoint(x: 0, y: 29492.50, dateLabel: '2023'),
            PerformancePoint(x: 1, y: 41200.00, dateLabel: '2024'),
            PerformancePoint(x: 2, y: 63000.00, dateLabel: '2025'),
            PerformancePoint(x: 3, y: 84392.50, dateLabel: '2026'),
          ],
        ),
      // Default: 1M (Matching ROADMAP: +14.8% growth)
      _ => const PortfolioPerformanceModel(
          timeframe: '1M',
          netGrowthUsd: 10892.50,
          percentageGrowth: 14.82,
          isPositive: true,
          points: [
            PerformancePoint(x: 0, y: 73500.00, dateLabel: 'Day 1'),
            PerformancePoint(x: 1, y: 74200.00, dateLabel: 'Day 5'),
            PerformancePoint(x: 2, y: 73800.00, dateLabel: 'Day 10'),
            PerformancePoint(x: 3, y: 76900.00, dateLabel: 'Day 15'),
            PerformancePoint(x: 4, y: 79100.00, dateLabel: 'Day 20'),
            PerformancePoint(x: 5, y: 81400.00, dateLabel: 'Day 25'),
            PerformancePoint(x: 6, y: 84392.50, dateLabel: 'Day 30'),
          ],
        ),
    };
  }
}
