import '../../domain/entities/yield_summary.dart';

class YieldSummaryModel extends YieldSummary {
  const YieldSummaryModel({
    required super.totalStakedUsd,
    required super.totalAccruedYieldUsd,
    required super.dailyProjectedYieldUsd,
    required super.monthlyProjectedYieldUsd,
    required super.yearlyProjectedYieldUsd,
    required super.lastDistribution,
    required super.nextPayoutEta,
  });

  factory YieldSummaryModel.fromEntity(YieldSummary entity) {
    return YieldSummaryModel(
      totalStakedUsd: entity.totalStakedUsd,
      totalAccruedYieldUsd: entity.totalAccruedYieldUsd,
      dailyProjectedYieldUsd: entity.dailyProjectedYieldUsd,
      monthlyProjectedYieldUsd: entity.monthlyProjectedYieldUsd,
      yearlyProjectedYieldUsd: entity.yearlyProjectedYieldUsd,
      lastDistribution: entity.lastDistribution,
      nextPayoutEta: entity.nextPayoutEta,
    );
  }

  factory YieldSummaryModel.fromJson(Map<String, dynamic> json) {
    return YieldSummaryModel(
      totalStakedUsd: (json['total_staked_usd'] as num).toDouble(),
      totalAccruedYieldUsd: (json['total_accrued_yield_usd'] as num).toDouble(),
      dailyProjectedYieldUsd: (json['daily_projected_yield_usd'] as num).toDouble(),
      monthlyProjectedYieldUsd: (json['monthly_projected_yield_usd'] as num).toDouble(),
      yearlyProjectedYieldUsd: (json['yearly_projected_yield_usd'] as num).toDouble(),
      lastDistribution: json['last_distribution'] as String,
      nextPayoutEta: json['next_payout_eta'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_staked_usd': totalStakedUsd,
      'total_accrued_yield_usd': totalAccruedYieldUsd,
      'daily_projected_yield_usd': dailyProjectedYieldUsd,
      'monthly_projected_yield_usd': monthlyProjectedYieldUsd,
      'yearly_projected_yield_usd': yearlyProjectedYieldUsd,
      'last_distribution': lastDistribution,
      'next_payout_eta': nextPayoutEta,
    };
  }
}
