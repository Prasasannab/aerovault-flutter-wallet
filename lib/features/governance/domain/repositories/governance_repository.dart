import '../entities/governance_request.dart';

abstract class GovernanceRepository {
  Future<List<GovernanceRequest>> getGovernanceRequests();
  
  Future<GovernanceRequest> signRequest({
    required String requestId,
    required String signerId,
    required String signerName,
    String? note,
  });

  Future<GovernanceRequest> rejectRequest({
    required String requestId,
    required String reason,
  });
}
