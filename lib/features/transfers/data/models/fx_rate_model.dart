import '../../domain/entities/fx_rate.dart';

class FxRateModel extends FxRate {
  const FxRateModel({
    required super.pair,
    required super.baseCurrency,
    required super.quoteCurrency,
    required super.rate,
    required super.change24h,
    required super.isPositive,
    super.sparklineTrend = 'up',
  });

  factory FxRateModel.fromJson(Map<String, dynamic> json) {
    return FxRateModel(
      pair: json['pair'] as String,
      baseCurrency: json['baseCurrency'] as String,
      quoteCurrency: json['quoteCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      change24h: (json['change24h'] as num).toDouble(),
      isPositive: json['isPositive'] as bool,
      sparklineTrend: json['sparklineTrend'] as String? ?? 'up',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pair': pair,
      'baseCurrency': baseCurrency,
      'quoteCurrency': quoteCurrency,
      'rate': rate,
      'change24h': change24h,
      'isPositive': isPositive,
      'sparklineTrend': sparklineTrend,
    };
  }
}
