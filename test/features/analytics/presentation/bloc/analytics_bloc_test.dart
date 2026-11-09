import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/errors/failures.dart';
import 'package:aerovault/core/utils/result.dart';
import 'package:aerovault/features/analytics/domain/entities/portfolio_performance.dart';
import 'package:aerovault/features/analytics/domain/usecases/get_portfolio_performance_usecase.dart';
import 'package:aerovault/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:aerovault/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:aerovault/features/analytics/presentation/bloc/analytics_state.dart';

class MockGetPortfolioPerformanceUseCase extends Mock implements GetPortfolioPerformanceUseCase {}

void main() {
  late AnalyticsBloc analyticsBloc;
  late MockGetPortfolioPerformanceUseCase mockGetPortfolioPerformanceUseCase;

  const testPerformance = PortfolioPerformance(
    timeframe: '1M',
    points: [
      PerformancePoint(x: 0, y: 73000.0, dateLabel: 'Day 1'),
      PerformancePoint(x: 1, y: 84392.5, dateLabel: 'Day 30'),
    ],
    netGrowthUsd: 10892.5,
    percentageGrowth: 14.8,
    isPositive: true,
  );

  setUp(() {
    mockGetPortfolioPerformanceUseCase = MockGetPortfolioPerformanceUseCase();
    analyticsBloc = AnalyticsBloc(getPortfolioPerformanceUseCase: mockGetPortfolioPerformanceUseCase);
  });

  tearDown(() {
    analyticsBloc.close();
  });

  group('AnalyticsBloc', () {
    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsLoaded] when LoadAnalyticsEvent succeeds',
      build: () {
        when(() => mockGetPortfolioPerformanceUseCase(timeframe: '1M'))
            .thenAnswer((_) async => Result.success(testPerformance));
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const LoadAnalyticsEvent(timeframe: '1M')),
      expect: () => [
        const AnalyticsLoading(),
        const AnalyticsLoaded(testPerformance),
      ],
      verify: (_) {
        verify(() => mockGetPortfolioPerformanceUseCase(timeframe: '1M')).called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsLoaded] with new timeframe when ChangeTimeframeEvent is dispatched',
      build: () {
        when(() => mockGetPortfolioPerformanceUseCase(timeframe: '1Y'))
            .thenAnswer((_) async => Result.success(testPerformance));
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const ChangeTimeframeEvent('1Y')),
      expect: () => [
        const AnalyticsLoading(),
        const AnalyticsLoaded(testPerformance),
      ],
      verify: (_) {
        verify(() => mockGetPortfolioPerformanceUseCase(timeframe: '1Y')).called(1);
      },
    );

    blocTest<AnalyticsBloc, AnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsError] when use case fails',
      build: () {
        when(() => mockGetPortfolioPerformanceUseCase(timeframe: '1M')).thenAnswer(
          (_) async => Result.error(const ServerFailure(message: 'Analytics service unavailable')),
        );
        return analyticsBloc;
      },
      act: (bloc) => bloc.add(const LoadAnalyticsEvent(timeframe: '1M')),
      expect: () => [
        const AnalyticsLoading(),
        const AnalyticsError('Analytics service unavailable'),
      ],
    );
  });
}
