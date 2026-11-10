import '../entities/governance_request.dart';
import '../repositories/governance_repository.dart';

class SignGovernanceRequestUseCase {
  final GovernanceRepository repository;

  const SignGovernanceRequestUseCase(this.repository);

  Future<GovernanceRequest> call({
    required String requestId,
    required String signerId,
    required String signerName,
    String? note,
  }) async {
    return await repository.signRequest(
      requestId: requestId,
      signerId: signerId,
      signerName: signerName,
      note: note,
    );
  }
}
