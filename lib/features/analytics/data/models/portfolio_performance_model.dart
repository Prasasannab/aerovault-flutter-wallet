import '../../domain/entities/portfolio_performance.dart';

/// Data Model for Portfolio Performance with JSON mapping
class PortfolioPerformanceModel extends PortfolioPerformance {
  const PortfolioPerformanceModel({
    required super.timeframe,
    required super.points,
    required super.netGrowthUsd,
    required super.percentageGrowth,
    required super.isPositive,
  });

  factory PortfolioPerformanceModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>;
    final pointsList = rawPoints.map((p) {
      return PerformancePoint(
        x: (p['x'] as num).toDouble(),
        y: (p['y'] as num).toDouble(),
        dateLabel: p['date_label'] as String,
      );
    }).toList();

    return PortfolioPerformanceModel(
      timeframe: json['timeframe'] as String,
      points: pointsList,
      netGrowthUsd: (json['net_growth_usd'] as num).toDouble(),
      percentageGrowth: (json['percentage_growth'] as num).toDouble(),
      isPositive: json['is_positive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeframe': timeframe,
      'points': points
          .map((p) => {
                'x': p.x,
                'y': p.y,
                'date_label': p.dateLabel,
              })
          .toList(),
      'net_growth_usd': netGrowthUsd,
      'percentage_growth': percentageGrowth,
      'is_positive': isPositive,
    };
  }
}
