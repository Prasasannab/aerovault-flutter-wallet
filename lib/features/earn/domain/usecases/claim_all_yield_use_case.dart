import '../../../../core/utils/result.dart';
import '../entities/staking_vault.dart';
import '../entities/yield_summary.dart';
import '../repositories/earn_repository.dart';

class ClaimAllYieldUseCase {
  final EarnRepository _repository;

  ClaimAllYieldUseCase(this._repository);

  Future<Result<(List<StakingVault>, YieldSummary, double claimedAmountUsd)>> call() async {
    return await _repository.claimAllYield();
  }
}
