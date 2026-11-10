import 'package:equatable/equatable.dart';

class YieldSummary extends Equatable {
  final double totalStakedUsd;
  final double totalAccruedYieldUsd;
  final double dailyProjectedYieldUsd;
  final double monthlyProjectedYieldUsd;
  final double yearlyProjectedYieldUsd;
  final String lastDistribution;
  final String nextPayoutEta;

  const YieldSummary({
    required this.totalStakedUsd,
    required this.totalAccruedYieldUsd,
    required this.dailyProjectedYieldUsd,
    required this.monthlyProjectedYieldUsd,
    required this.yearlyProjectedYieldUsd,
    required this.lastDistribution,
    required this.nextPayoutEta,
  });

  YieldSummary copyWith({
    double? totalStakedUsd,
    double? totalAccruedYieldUsd,
    double? dailyProjectedYieldUsd,
    double? monthlyProjectedYieldUsd,
    double? yearlyProjectedYieldUsd,
    String? lastDistribution,
    String? nextPayoutEta,
  }) {
    return YieldSummary(
      totalStakedUsd: totalStakedUsd ?? this.totalStakedUsd,
      totalAccruedYieldUsd: totalAccruedYieldUsd ?? this.totalAccruedYieldUsd,
      dailyProjectedYieldUsd: dailyProjectedYieldUsd ?? this.dailyProjectedYieldUsd,
      monthlyProjectedYieldUsd: monthlyProjectedYieldUsd ?? this.monthlyProjectedYieldUsd,
      yearlyProjectedYieldUsd: yearlyProjectedYieldUsd ?? this.yearlyProjectedYieldUsd,
      lastDistribution: lastDistribution ?? this.lastDistribution,
      nextPayoutEta: nextPayoutEta ?? this.nextPayoutEta,
    );
  }

  @override
  List<Object?> get props => [
        totalStakedUsd,
        totalAccruedYieldUsd,
        dailyProjectedYieldUsd,
        monthlyProjectedYieldUsd,
        yearlyProjectedYieldUsd,
        lastDistribution,
        nextPayoutEta,
      ];
}
