import '../entities/governance_request.dart';
import '../repositories/governance_repository.dart';

class RejectGovernanceRequestUseCase {
  final GovernanceRepository repository;

  const RejectGovernanceRequestUseCase(this.repository);

  Future<GovernanceRequest> call({
    required String requestId,
    required String reason,
  }) async {
    return await repository.rejectRequest(
      requestId: requestId,
      reason: reason,
    );
  }
}
