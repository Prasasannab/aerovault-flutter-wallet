import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/staking_vault.dart';
import '../models/staking_vault_model.dart';
import '../models/yield_summary_model.dart';

abstract class EarnDataSource {
  Future<(List<StakingVaultModel>, YieldSummaryModel)> getEarnVaults();
  Future<(List<StakingVaultModel>, YieldSummaryModel)> stakeAsset({
    required String vaultId,
    required double amount,
  });
  Future<(List<StakingVaultModel>, YieldSummaryModel)> unstakeAsset({
    required String vaultId,
    required double amount,
  });
  Future<(List<StakingVaultModel>, YieldSummaryModel, double claimedAmountUsd)> claimAllYield();
}

class EarnLocalDataSourceImpl implements EarnDataSource {
  List<StakingVaultModel>? _vaults;
  YieldSummaryModel? _summary;

  void _initDefaults() {
    _vaults = const [
      StakingVaultModel(
        id: 'VAULT-ETH-POS',
        assetCode: 'ETH',
        assetName: 'Ethereum PoS Validator',
        symbol: '⟠',
        apyPercentage: 4.50,
        stakedBalance: 18.5000,
        stakedBalanceUsd: 64380.00,
        accruedYield: 0.0693,
        accruedYieldUsd: 241.42,
        term: StakingTerm.flexible,
        clearingAuditor: 'Swisscom Blockchain & Consensys',
        riskLevel: 'Tier 1 Sovereign Validator Node',
        colorHex: 0xFF627EEA,
      ),
      StakingVaultModel(
        id: 'VAULT-BTC-COLD',
        assetCode: 'BTC',
        assetName: 'Bitcoin Cold Reserve Liquidity',
        symbol: '₿',
        apyPercentage: 3.80,
        stakedBalance: 1.4285,
        stakedBalanceUsd: 97780.82,
        accruedYield: 0.0045,
        accruedYieldUsd: 309.64,
        term: StakingTerm.locked90d,
        clearingAuditor: 'Anchorage Digital & FINMA Audited',
        riskLevel: 'Multi-Sig Cold Vault Level 4',
        colorHex: 0xFFF7931A,
      ),
      StakingVaultModel(
        id: 'VAULT-USD-TREASURY',
        assetCode: 'USD',
        assetName: 'US Treasury Short-Term Yield',
        symbol: '\$',
        apyPercentage: 5.20,
        stakedBalance: 50000.00,
        stakedBalanceUsd: 50000.00,
        accruedYield: 216.67,
        accruedYieldUsd: 216.67,
        term: StakingTerm.flexible,
        clearingAuditor: 'BNY Mellon & Fedwire Direct',
        riskLevel: 'US Gov Sovereign Backed Tier 1',
        colorHex: 0xFF00E599,
      ),
      StakingVaultModel(
        id: 'VAULT-SOL-FAST',
        assetCode: 'SOL',
        assetName: 'Solana High-Yield Validator',
        symbol: '◎',
        apyPercentage: 6.80,
        stakedBalance: 0.0,
        stakedBalanceUsd: 0.0,
        accruedYield: 0.0,
        accruedYieldUsd: 0.0,
        term: StakingTerm.flexible,
        clearingAuditor: 'Jump Crypto & Solana Foundation',
        riskLevel: 'Delegated PoS Low Slasher',
        colorHex: 0xFF00D2FF,
      ),
    ];

    _summary = const YieldSummaryModel(
      totalStakedUsd: 212160.82,
      totalAccruedYieldUsd: 767.73,
      dailyProjectedYieldUsd: 25.59,
      monthlyProjectedYieldUsd: 767.73,
      yearlyProjectedYieldUsd: 9340.75,
      lastDistribution: 'Today, 00:00 UTC (Direct Credit)',
      nextPayoutEta: 'in 7h 24m (Daily Batch)',
    );
  }

  @override
  Future<(List<StakingVaultModel>, YieldSummaryModel)> getEarnVaults() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    if (_vaults == null || _summary == null) {
      _initDefaults();
    }
    return (_vaults!, _summary!);
  }

  @override
  Future<(List<StakingVaultModel>, YieldSummaryModel)> stakeAsset({
    required String vaultId,
    required double amount,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    if (_vaults == null || _summary == null) {
      _initDefaults();
    }

    final updatedVaults = _vaults!.map((vault) {
      if (vault.id == vaultId) {
        final newStaked = vault.stakedBalance + amount;
        final unitPriceUsd = vault.stakedBalance > 0
            ? vault.stakedBalanceUsd / vault.stakedBalance
            : (vault.assetCode == 'SOL' ? 195.0 : 1.0);
        final newStakedUsd = newStaked * unitPriceUsd;

        return StakingVaultModel.fromEntity(
          vault.copyWith(
            stakedBalance: newStaked,
            stakedBalanceUsd: newStakedUsd,
          ),
        );
      }
      return vault;
    }).toList();

    _vaults = updatedVaults;
    _recalculateSummary();
    return (_vaults!, _summary!);
  }

  @override
  Future<(List<StakingVaultModel>, YieldSummaryModel)> unstakeAsset({
    required String vaultId,
    required double amount,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    if (_vaults == null || _summary == null) {
      _initDefaults();
    }

    final updatedVaults = _vaults!.map((vault) {
      if (vault.id == vaultId) {
        final newStaked = (vault.stakedBalance - amount).clamp(0.0, double.infinity);
        final unitPriceUsd = vault.stakedBalance > 0
            ? vault.stakedBalanceUsd / vault.stakedBalance
            : 1.0;
        final newStakedUsd = newStaked * unitPriceUsd;

        return StakingVaultModel.fromEntity(
          vault.copyWith(
            stakedBalance: newStaked,
            stakedBalanceUsd: newStakedUsd,
          ),
        );
      }
      return vault;
    }).toList();

    _vaults = updatedVaults;
    _recalculateSummary();
    return (_vaults!, _summary!);
  }

  @override
  Future<(List<StakingVaultModel>, YieldSummaryModel, double claimedAmountUsd)> claimAllYield() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    if (_vaults == null || _summary == null) {
      _initDefaults();
    }

    final claimedUsd = _summary!.totalAccruedYieldUsd;

    final updatedVaults = _vaults!.map((vault) {
      return StakingVaultModel.fromEntity(
        vault.copyWith(
          accruedYield: 0.0,
          accruedYieldUsd: 0.0,
        ),
      );
    }).toList();

    _vaults = updatedVaults;
    _summary = YieldSummaryModel.fromEntity(
      _summary!.copyWith(
        totalAccruedYieldUsd: 0.0,
        lastDistribution: 'Claimed Instantly (Settled to Fiat Ledger)',
      ),
    );

    return (_vaults!, _summary!, claimedUsd);
  }

  void _recalculateSummary() {
    double totalStaked = 0.0;
    double totalAccrued = 0.0;

    for (final v in _vaults!) {
      totalStaked += v.stakedBalanceUsd;
      totalAccrued += v.accruedYieldUsd;
    }

    final yearly = totalStaked * 0.044; // ~4.4% blended APY
    final monthly = yearly / 12;
    final daily = yearly / 365;

    _summary = YieldSummaryModel(
      totalStakedUsd: totalStaked,
      totalAccruedYieldUsd: totalAccrued,
      dailyProjectedYieldUsd: daily,
      monthlyProjectedYieldUsd: monthly,
      yearlyProjectedYieldUsd: yearly,
      lastDistribution: _summary?.lastDistribution ?? 'Today, 00:00 UTC',
      nextPayoutEta: _summary?.nextPayoutEta ?? 'in 7h 24m (Daily Batch)',
    );
  }
}
