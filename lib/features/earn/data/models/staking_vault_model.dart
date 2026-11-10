import '../../domain/entities/staking_vault.dart';

class StakingVaultModel extends StakingVault {
  const StakingVaultModel({
    required super.id,
    required super.assetCode,
    required super.assetName,
    required super.symbol,
    required super.apyPercentage,
    required super.stakedBalance,
    required super.stakedBalanceUsd,
    required super.accruedYield,
    required super.accruedYieldUsd,
    required super.term,
    required super.clearingAuditor,
    required super.riskLevel,
    required super.colorHex,
  });

  factory StakingVaultModel.fromEntity(StakingVault entity) {
    return StakingVaultModel(
      id: entity.id,
      assetCode: entity.assetCode,
      assetName: entity.assetName,
      symbol: entity.symbol,
      apyPercentage: entity.apyPercentage,
      stakedBalance: entity.stakedBalance,
      stakedBalanceUsd: entity.stakedBalanceUsd,
      accruedYield: entity.accruedYield,
      accruedYieldUsd: entity.accruedYieldUsd,
      term: entity.term,
      clearingAuditor: entity.clearingAuditor,
      riskLevel: entity.riskLevel,
      colorHex: entity.colorHex,
    );
  }

  factory StakingVaultModel.fromJson(Map<String, dynamic> json) {
    return StakingVaultModel(
      id: json['id'] as String,
      assetCode: json['asset_code'] as String,
      assetName: json['asset_name'] as String,
      symbol: json['symbol'] as String,
      apyPercentage: (json['apy_percentage'] as num).toDouble(),
      stakedBalance: (json['staked_balance'] as num).toDouble(),
      stakedBalanceUsd: (json['staked_balance_usd'] as num).toDouble(),
      accruedYield: (json['accrued_yield'] as num).toDouble(),
      accruedYieldUsd: (json['accrued_yield_usd'] as num).toDouble(),
      term: StakingTerm.values.firstWhere(
        (e) => e.name == json['term'],
        orElse: () => StakingTerm.flexible,
      ),
      clearingAuditor: json['clearing_auditor'] as String,
      riskLevel: json['risk_level'] as String,
      colorHex: json['color_hex'] as int? ?? 0xFF00E599,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_code': assetCode,
      'asset_name': assetName,
      'symbol': symbol,
      'apy_percentage': apyPercentage,
      'staked_balance': stakedBalance,
      'staked_balance_usd': stakedBalanceUsd,
      'accrued_yield': accruedYield,
      'accrued_yield_usd': accruedYieldUsd,
      'term': term.name,
      'clearing_auditor': clearingAuditor,
      'risk_level': riskLevel,
      'color_hex': colorHex,
    };
  }
}
