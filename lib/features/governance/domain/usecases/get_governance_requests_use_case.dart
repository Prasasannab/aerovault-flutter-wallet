import '../entities/governance_request.dart';
import '../repositories/governance_repository.dart';

class GetGovernanceRequestsUseCase {
  final GovernanceRepository repository;

  const GetGovernanceRequestsUseCase(this.repository);

  Future<List<GovernanceRequest>> call() async {
    return await repository.getGovernanceRequests();
  }
}
