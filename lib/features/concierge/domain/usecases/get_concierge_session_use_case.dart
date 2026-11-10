import '../../../../core/utils/result.dart';
import '../entities/concierge_session.dart';
import '../repositories/concierge_repository.dart';

class GetConciergeSessionUseCase {
  final ConciergeRepository _repository;

  GetConciergeSessionUseCase(this._repository);

  Future<Result<ConciergeSession>> call() async {
    return await _repository.getSession();
  }
}
