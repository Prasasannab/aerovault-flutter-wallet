import '../../../../core/utils/result.dart';
import '../entities/staking_vault.dart';
import '../entities/yield_summary.dart';

abstract class EarnRepository {
  Future<Result<(List<StakingVault>, YieldSummary)>> getEarnVaults();
  Future<Result<(List<StakingVault>, YieldSummary)>> stakeAsset({
    required String vaultId,
    required double amount,
  });
  Future<Result<(List<StakingVault>, YieldSummary)>> unstakeAsset({
    required String vaultId,
    required double amount,
  });
  Future<Result<(List<StakingVault>, YieldSummary, double claimedAmountUsd)>> claimAllYield();
}
