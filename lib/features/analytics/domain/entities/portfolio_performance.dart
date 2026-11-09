import 'package:equatable/equatable.dart';

/// Single historical performance point for chart curves
class PerformancePoint extends Equatable {
  final double x;
  final double y;
  final String dateLabel;

  const PerformancePoint({
    required this.x,
    required this.y,
    required this.dateLabel,
  });

  @override
  List<Object?> get props => [x, y, dateLabel];
}

/// Portfolio performance aggregate over a given timeframe (1W, 1M, 1Y, ALL)
class PortfolioPerformance extends Equatable {
  final String timeframe;
  final List<PerformancePoint> points;
  final double netGrowthUsd;
  final double percentageGrowth;
  final bool isPositive;

  const PortfolioPerformance({
    required this.timeframe,
    required this.points,
    required this.netGrowthUsd,
    required this.percentageGrowth,
    required this.isPositive,
  });

  double get minValue => points.isEmpty
      ? 0.0
      : points.map((p) => p.y).reduce((a, b) => a < b ? a : b);

  double get maxValue => points.isEmpty
      ? 0.0
      : points.map((p) => p.y).reduce((a, b) => a > b ? a : b);

  @override
  List<Object?> get props => [
        timeframe,
        points,
        netGrowthUsd,
        percentageGrowth,
        isPositive,
      ];
}
