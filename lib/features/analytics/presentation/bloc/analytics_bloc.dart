import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_portfolio_performance_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetPortfolioPerformanceUseCase getPortfolioPerformanceUseCase;

  AnalyticsBloc({required this.getPortfolioPerformanceUseCase})
      : super(const AnalyticsInitial()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<ChangeTimeframeEvent>(_onChangeTimeframe);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getPortfolioPerformanceUseCase(timeframe: event.timeframe);

    result.fold(
      onSuccess: (performance) => emit(AnalyticsLoaded(performance)),
      onError: (failure) => emit(AnalyticsError(failure.message)),
    );
  }

  Future<void> _onChangeTimeframe(
    ChangeTimeframeEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getPortfolioPerformanceUseCase(timeframe: event.timeframe);

    result.fold(
      onSuccess: (performance) => emit(AnalyticsLoaded(performance)),
      onError: (failure) => emit(AnalyticsError(failure.message)),
    );
  }
}
