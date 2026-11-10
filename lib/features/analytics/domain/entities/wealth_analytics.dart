import 'package:equatable/equatable.dart';

class AssetAllocation extends Equatable {
  final String symbol;
  final String name;
  final double valueUsd;
  final double percentage;
  final int colorHex;

  const AssetAllocation({
    required this.symbol,
    required this.name,
    required this.valueUsd,
    required this.percentage,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [symbol, name, valueUsd, percentage, colorHex];
}

class SpendingCategoryBreakdown extends Equatable {
  final String category;
  final double amount;
  final double percentage;
  final int colorHex;

  const SpendingCategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [category, amount, percentage, colorHex];
}

class WealthAnalytics extends Equatable {
  final double totalNetWorth;
  final double monthlyInflow;
  final double monthlyOutflow;
  final int financialHealthScore; // e.g. 94 out of 100
  final String ratingTier; // e.g. "Tier 1 Prime"
  final List<AssetAllocation> allocations;
  final List<SpendingCategoryBreakdown> spendingBreakdown;

  const WealthAnalytics({
    required this.totalNetWorth,
    required this.monthlyInflow,
    required this.monthlyOutflow,
    required this.financialHealthScore,
    required this.ratingTier,
    required this.allocations,
    required this.spendingBreakdown,
  });

  double get netSavingsRate =>
      monthlyInflow > 0 ? ((monthlyInflow - monthlyOutflow) / monthlyInflow).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [
        totalNetWorth,
        monthlyInflow,
        monthlyOutflow,
        financialHealthScore,
        ratingTier,
        allocations,
        spendingBreakdown,
      ];
}
