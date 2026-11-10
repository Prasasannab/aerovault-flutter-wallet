import '../../../../core/utils/result.dart';
import '../entities/staking_vault.dart';
import '../entities/yield_summary.dart';
import '../repositories/earn_repository.dart';

class UnstakeAssetUseCase {
  final EarnRepository _repository;

  UnstakeAssetUseCase(this._repository);

  Future<Result<(List<StakingVault>, YieldSummary)>> call({
    required String vaultId,
    required double amount,
  }) async {
    return await _repository.unstakeAsset(vaultId: vaultId, amount: amount);
  }
}
