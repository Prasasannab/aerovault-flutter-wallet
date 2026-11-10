import '../../../../core/utils/result.dart';
import '../entities/wealth_analytics.dart';
import '../repositories/analytics_repository.dart';

class GetWealthAnalyticsUseCase {
  final AnalyticsRepository _repository;

  const GetWealthAnalyticsUseCase(this._repository);

  Future<Result<WealthAnalytics>> call() async {
    return _repository.getWealthAnalytics();
  }
}
