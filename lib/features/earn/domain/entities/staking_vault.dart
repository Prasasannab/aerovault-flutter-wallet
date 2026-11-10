import 'package:equatable/equatable.dart';

enum StakingTerm { flexible, locked30d, locked90d, locked365d }

class StakingVault extends Equatable {
  final String id;
  final String assetCode;
  final String assetName;
  final String symbol;
  final double apyPercentage;
  final double stakedBalance;
  final double stakedBalanceUsd;
  final double accruedYield;
  final double accruedYieldUsd;
  final StakingTerm term;
  final String clearingAuditor;
  final String riskLevel;
  final int colorHex;

  const StakingVault({
    required this.id,
    required this.assetCode,
    required this.assetName,
    required this.symbol,
    required this.apyPercentage,
    required this.stakedBalance,
    required this.stakedBalanceUsd,
    required this.accruedYield,
    required this.accruedYieldUsd,
    required this.term,
    required this.clearingAuditor,
    required this.riskLevel,
    required this.colorHex,
  });

  String get termLabel {
    switch (term) {
      case StakingTerm.flexible:
        return 'Flexible (Instant Exit)';
      case StakingTerm.locked30d:
        return '30-Day Lock';
      case StakingTerm.locked90d:
        return '90-Day Lock (+0.5% APY)';
      case StakingTerm.locked365d:
        return '365-Day Institutional';
    }
  }

  StakingVault copyWith({
    String? id,
    String? assetCode,
    String? assetName,
    String? symbol,
    double? apyPercentage,
    double? stakedBalance,
    double? stakedBalanceUsd,
    double? accruedYield,
    double? accruedYieldUsd,
    StakingTerm? term,
    String? clearingAuditor,
    String? riskLevel,
    int? colorHex,
  }) {
    return StakingVault(
      id: id ?? this.id,
      assetCode: assetCode ?? this.assetCode,
      assetName: assetName ?? this.assetName,
      symbol: symbol ?? this.symbol,
      apyPercentage: apyPercentage ?? this.apyPercentage,
      stakedBalance: stakedBalance ?? this.stakedBalance,
      stakedBalanceUsd: stakedBalanceUsd ?? this.stakedBalanceUsd,
      accruedYield: accruedYield ?? this.accruedYield,
      accruedYieldUsd: accruedYieldUsd ?? this.accruedYieldUsd,
      term: term ?? this.term,
      clearingAuditor: clearingAuditor ?? this.clearingAuditor,
      riskLevel: riskLevel ?? this.riskLevel,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        assetCode,
        assetName,
        symbol,
        apyPercentage,
        stakedBalance,
        stakedBalanceUsd,
        accruedYield,
        accruedYieldUsd,
        term,
        clearingAuditor,
        riskLevel,
        colorHex,
      ];
}
