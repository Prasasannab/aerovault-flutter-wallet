import '../../../../core/utils/result.dart';
import '../entities/staking_vault.dart';
import '../entities/yield_summary.dart';
import '../repositories/earn_repository.dart';

class StakeAssetUseCase {
  final EarnRepository _repository;

  StakeAssetUseCase(this._repository);

  Future<Result<(List<StakingVault>, YieldSummary)>> call({
    required String vaultId,
    required double amount,
  }) async {
    return await _repository.stakeAsset(vaultId: vaultId, amount: amount);
  }
}
