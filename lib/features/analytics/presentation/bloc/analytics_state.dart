import 'package:equatable/equatable.dart';
import '../../domain/entities/portfolio_performance.dart';
import '../../domain/entities/wealth_analytics.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final PortfolioPerformance performance;
  final WealthAnalytics? wealthAnalytics;

  const AnalyticsLoaded(
    this.performance, {
    this.wealthAnalytics,
  });

  AnalyticsLoaded copyWith({
    PortfolioPerformance? performance,
    WealthAnalytics? wealthAnalytics,
  }) {
    return AnalyticsLoaded(
      performance ?? this.performance,
      wealthAnalytics: wealthAnalytics ?? this.wealthAnalytics,
    );
  }

  @override
  List<Object?> get props => [performance, wealthAnalytics];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
