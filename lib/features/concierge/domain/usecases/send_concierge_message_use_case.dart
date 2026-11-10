import '../../../../core/utils/result.dart';
import '../entities/concierge_session.dart';
import '../repositories/concierge_repository.dart';

class SendConciergeMessageUseCase {
  final ConciergeRepository _repository;

  SendConciergeMessageUseCase(this._repository);

  Future<Result<ConciergeSession>> call(String text) async {
    return await _repository.sendMessage(text);
  }
}
