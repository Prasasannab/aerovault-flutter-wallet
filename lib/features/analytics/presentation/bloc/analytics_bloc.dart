import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_portfolio_performance_usecase.dart';
import '../../domain/usecases/get_wealth_analytics_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetPortfolioPerformanceUseCase getPortfolioPerformanceUseCase;
  final GetWealthAnalyticsUseCase? getWealthAnalyticsUseCase;

  AnalyticsBloc({
    required this.getPortfolioPerformanceUseCase,
    this.getWealthAnalyticsUseCase,
  }) : super(const AnalyticsInitial()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<ChangeTimeframeEvent>(_onChangeTimeframe);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getPortfolioPerformanceUseCase(timeframe: event.timeframe);

    if (result.isSuccess) {
      final performance = result.dataOrNull!;
      if (getWealthAnalyticsUseCase != null) {
        final wealthResult = await getWealthAnalyticsUseCase!();
        emit(AnalyticsLoaded(performance, wealthAnalytics: wealthResult.dataOrNull));
      } else {
        emit(AnalyticsLoaded(performance));
      }
    } else {
      emit(AnalyticsError(result.failureOrNull?.message ?? 'Analytics service unavailable'));
    }
  }

  Future<void> _onChangeTimeframe(
    ChangeTimeframeEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final currentWealth = (state is AnalyticsLoaded) ? (state as AnalyticsLoaded).wealthAnalytics : null;
    emit(const AnalyticsLoading());
    final result = await getPortfolioPerformanceUseCase(timeframe: event.timeframe);

    if (result.isSuccess) {
      final performance = result.dataOrNull!;
      emit(AnalyticsLoaded(performance, wealthAnalytics: currentWealth));
    } else {
      emit(AnalyticsError(result.failureOrNull?.message ?? 'Analytics service unavailable'));
    }
  }
}
