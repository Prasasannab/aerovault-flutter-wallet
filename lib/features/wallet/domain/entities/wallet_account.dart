import 'package:equatable/equatable.dart';

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
  });

  /// Total Portfolio Net Worth converted to fiat USD equivalent
  double get totalPortfolioBalanceUsd =>
      fiatBalance + (btcBalance * btcPriceUsd) + (ethBalance * ethPriceUsd);

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
      ];
}
