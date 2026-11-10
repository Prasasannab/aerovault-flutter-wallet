import 'package:equatable/equatable.dart';

/// Represents a live institutional foreign exchange or crypto market rate
class FxRate extends Equatable {
  final String pair;
  final String baseCurrency;
  final String quoteCurrency;
  final double rate;
  final double change24h;
  final bool isPositive;
  final String sparklineTrend;

  const FxRate({
    required this.pair,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rate,
    required this.change24h,
    required this.isPositive,
    this.sparklineTrend = 'up',
  });

  @override
  List<Object?> get props => [
        pair,
        baseCurrency,
        quoteCurrency,
        rate,
        change24h,
        isPositive,
        sparklineTrend,
      ];
}
