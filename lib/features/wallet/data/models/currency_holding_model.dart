import '../../domain/entities/currency_holding.dart';

class CurrencyHoldingModel extends CurrencyHolding {
  const CurrencyHoldingModel({
    required super.code,
    required super.name,
    required super.symbol,
    required super.flagEmoji,
    required super.balance,
    required super.balanceUsdEquivalent,
    required super.iban,
    required super.clearingNetwork,
    super.isCrypto = false,
    super.isEnabled = true,
  });

  factory CurrencyHoldingModel.fromJson(Map<String, dynamic> json) {
    return CurrencyHoldingModel(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      flagEmoji: json['flagEmoji'] as String,
      balance: (json['balance'] as num).toDouble(),
      balanceUsdEquivalent: (json['balanceUsdEquivalent'] as num).toDouble(),
      iban: json['iban'] as String,
      clearingNetwork: json['clearingNetwork'] as String,
      isCrypto: json['isCrypto'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'flagEmoji': flagEmoji,
      'balance': balance,
      'balanceUsdEquivalent': balanceUsdEquivalent,
      'iban': iban,
      'clearingNetwork': clearingNetwork,
      'isCrypto': isCrypto,
      'isEnabled': isEnabled,
    };
  }

  factory CurrencyHoldingModel.fromEntity(CurrencyHolding entity) {
    return CurrencyHoldingModel(
      code: entity.code,
      name: entity.name,
      symbol: entity.symbol,
      flagEmoji: entity.flagEmoji,
      balance: entity.balance,
      balanceUsdEquivalent: entity.balanceUsdEquivalent,
      iban: entity.iban,
      clearingNetwork: entity.clearingNetwork,
      isCrypto: entity.isCrypto,
      isEnabled: entity.isEnabled,
    );
  }
}
