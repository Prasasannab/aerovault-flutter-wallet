import '../../domain/entities/governance_request.dart';
import '../../domain/repositories/governance_repository.dart';
import '../datasources/governance_data_source.dart';

class GovernanceRepositoryImpl implements GovernanceRepository {
  final GovernanceDataSource dataSource;

  const GovernanceRepositoryImpl(this.dataSource);

  @override
  Future<List<GovernanceRequest>> getGovernanceRequests() async {
    return await dataSource.getGovernanceRequests();
  }

  @override
  Future<GovernanceRequest> signRequest({
    required String requestId,
    required String signerId,
    required String signerName,
    String? note,
  }) async {
    return await dataSource.signRequest(
      requestId: requestId,
      signerId: signerId,
      signerName: signerName,
      note: note,
    );
  }

  @override
  Future<GovernanceRequest> rejectRequest({
    required String requestId,
    required String reason,
  }) async {
    return await dataSource.rejectRequest(
      requestId: requestId,
      reason: reason,
    );
  }
}
