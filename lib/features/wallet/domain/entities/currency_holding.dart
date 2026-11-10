import 'package:equatable/equatable.dart';

/// Represents a foreign fiat currency sub-account or crypto reserve holding
class CurrencyHolding extends Equatable {
  final String code;
  final String name;
  final String symbol;
  final String flagEmoji;
  final double balance;
  final double balanceUsdEquivalent;
  final String iban;
  final String clearingNetwork;
  final bool isCrypto;
  final bool isEnabled;

  const CurrencyHolding({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flagEmoji,
    required this.balance,
    required this.balanceUsdEquivalent,
    required this.iban,
    required this.clearingNetwork,
    this.isCrypto = false,
    this.isEnabled = true,
  });

  CurrencyHolding copyWith({
    String? code,
    String? name,
    String? symbol,
    String? flagEmoji,
    double? balance,
    double? balanceUsdEquivalent,
    String? iban,
    String? clearingNetwork,
    bool? isCrypto,
    bool? isEnabled,
  }) {
    return CurrencyHolding(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      balance: balance ?? this.balance,
      balanceUsdEquivalent: balanceUsdEquivalent ?? this.balanceUsdEquivalent,
      iban: iban ?? this.iban,
      clearingNetwork: clearingNetwork ?? this.clearingNetwork,
      isCrypto: isCrypto ?? this.isCrypto,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [
        code,
        name,
        symbol,
        flagEmoji,
        balance,
        balanceUsdEquivalent,
        iban,
        clearingNetwork,
        isCrypto,
        isEnabled,
      ];
}
