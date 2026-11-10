import '../../../../core/utils/result.dart';
import '../entities/staking_vault.dart';
import '../entities/yield_summary.dart';
import '../repositories/earn_repository.dart';

class GetEarnVaultsUseCase {
  final EarnRepository _repository;

  GetEarnVaultsUseCase(this._repository);

  Future<Result<(List<StakingVault>, YieldSummary)>> call() async {
    return await _repository.getEarnVaults();
  }
}
