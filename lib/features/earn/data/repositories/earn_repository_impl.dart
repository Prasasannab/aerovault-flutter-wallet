import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/staking_vault.dart';
import '../../domain/entities/yield_summary.dart';
import '../../domain/repositories/earn_repository.dart';
import '../datasources/earn_data_source.dart';

class EarnRepositoryImpl implements EarnRepository {
  final EarnDataSource _dataSource;

  EarnRepositoryImpl(this._dataSource);

  @override
  Future<Result<(List<StakingVault>, YieldSummary)>> getEarnVaults() async {
    try {
      final data = await _dataSource.getEarnVaults();
      return Result.success(data);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to retrieve earn vaults: $e'));
    }
  }

  @override
  Future<Result<(List<StakingVault>, YieldSummary)>> stakeAsset({
    required String vaultId,
    required double amount,
  }) async {
    try {
      final data = await _dataSource.stakeAsset(vaultId: vaultId, amount: amount);
      return Result.success(data);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to stake assets: $e'));
    }
  }

  @override
  Future<Result<(List<StakingVault>, YieldSummary)>> unstakeAsset({
    required String vaultId,
    required double amount,
  }) async {
    try {
      final data = await _dataSource.unstakeAsset(vaultId: vaultId, amount: amount);
      return Result.success(data);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to unstake assets: $e'));
    }
  }

  @override
  Future<Result<(List<StakingVault>, YieldSummary, double claimedAmountUsd)>> claimAllYield() async {
    try {
      final data = await _dataSource.claimAllYield();
      return Result.success(data);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to claim accrued yield: $e'));
    }
  }
}
