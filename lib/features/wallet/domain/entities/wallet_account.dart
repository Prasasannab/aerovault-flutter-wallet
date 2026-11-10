import 'package:equatable/equatable.dart';
import 'currency_holding.dart';

/// Domain Entity representing the primary multi-currency & crypto wallet account
class WalletAccount extends Equatable {
  final String id;
  final String holderName;
  final double fiatBalance;
  final double btcBalance;
  final double ethBalance;
  final double btcPriceUsd;
  final double ethPriceUsd;
  final String currencyCode;
  final bool isBalanceHidden;
  final List<CurrencyHolding> holdings;
  final String selectedCurrencyCode;

  const WalletAccount({
    required this.id,
    required this.holderName,
    required this.fiatBalance,
    required this.btcBalance,
    required this.ethBalance,
    required this.btcPriceUsd,
    required this.ethPriceUsd,
    this.currencyCode = 'USD',
    this.isBalanceHidden = false,
    this.holdings = const [],
    this.selectedCurrencyCode = 'USD',
  });

  /// Total Portfolio Net Worth converted to fiat USD equivalent
  double get totalPortfolioBalanceUsd =>
      fiatBalance + (btcBalance * btcPriceUsd) + (ethBalance * ethPriceUsd);

  /// Active selected currency holding (e.g. USD, EUR, CHF, GBP)
  CurrencyHolding get activeHolding {
    if (holdings.isEmpty) {
      return CurrencyHolding(
        code: currencyCode,
        name: 'US Dollar',
        symbol: '\$',
        flagEmoji: '🇺🇸',
        balance: fiatBalance,
        balanceUsdEquivalent: fiatBalance,
        iban: 'US02 0260 0959 3884 21',
        clearingNetwork: 'Fedwire & ACH',
      );
    }
    for (final holding in holdings) {
      if (holding.code == selectedCurrencyCode) {
        return holding;
      }
    }
    return holdings.first;
  }

  WalletAccount copyWith({
    String? id,
    String? holderName,
    double? fiatBalance,
    double? btcBalance,
    double? ethBalance,
    double? btcPriceUsd,
    double? ethPriceUsd,
    String? currencyCode,
    bool? isBalanceHidden,
    List<CurrencyHolding>? holdings,
    String? selectedCurrencyCode,
  }) {
    return WalletAccount(
      id: id ?? this.id,
      holderName: holderName ?? this.holderName,
      fiatBalance: fiatBalance ?? this.fiatBalance,
      btcBalance: btcBalance ?? this.btcBalance,
      ethBalance: ethBalance ?? this.ethBalance,
      btcPriceUsd: btcPriceUsd ?? this.btcPriceUsd,
      ethPriceUsd: ethPriceUsd ?? this.ethPriceUsd,
      currencyCode: currencyCode ?? this.currencyCode,
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
      holdings: holdings ?? this.holdings,
      selectedCurrencyCode: selectedCurrencyCode ?? this.selectedCurrencyCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        holderName,
        fiatBalance,
        btcBalance,
        ethBalance,
        btcPriceUsd,
        ethPriceUsd,
        currencyCode,
        isBalanceHidden,
        holdings,
        selectedCurrencyCode,
      ];
}
