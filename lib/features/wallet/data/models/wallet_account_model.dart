import '../../domain/entities/wallet_account.dart';
import 'currency_holding_model.dart';

/// Data Model for Wallet Account with JSON serialization
class WalletAccountModel extends WalletAccount {
  const WalletAccountModel({
    required super.id,
    required super.holderName,
    required super.fiatBalance,
    required super.btcBalance,
    required super.ethBalance,
    required super.btcPriceUsd,
    required super.ethPriceUsd,
    super.currencyCode = 'USD',
    super.isBalanceHidden = false,
    super.holdings = const [],
    super.selectedCurrencyCode = 'USD',
  });

  factory WalletAccountModel.fromJson(Map<String, dynamic> json) {
    return WalletAccountModel(
      id: json['id'] as String,
      holderName: json['holder_name'] as String,
      fiatBalance: (json['fiat_balance'] as num).toDouble(),
      btcBalance: (json['btc_balance'] as num).toDouble(),
      ethBalance: (json['eth_balance'] as num).toDouble(),
      btcPriceUsd: (json['btc_price_usd'] as num).toDouble(),
      ethPriceUsd: (json['eth_price_usd'] as num).toDouble(),
      currencyCode: json['currency_code'] as String? ?? 'USD',
      isBalanceHidden: json['is_balance_hidden'] as bool? ?? false,
      holdings: (json['holdings'] as List<dynamic>?)
              ?.map((item) => CurrencyHoldingModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedCurrencyCode: json['selected_currency_code'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'holder_name': holderName,
      'fiat_balance': fiatBalance,
      'btc_balance': btcBalance,
      'eth_balance': ethBalance,
      'btc_price_usd': btcPriceUsd,
      'eth_price_usd': ethPriceUsd,
      'currency_code': currencyCode,
      'is_balance_hidden': isBalanceHidden,
      'holdings': holdings
          .map((h) => CurrencyHoldingModel.fromEntity(h).toJson())
          .toList(),
      'selected_currency_code': selectedCurrencyCode,
    };
  }

  factory WalletAccountModel.fromEntity(WalletAccount entity) {
    return WalletAccountModel(
      id: entity.id,
      holderName: entity.holderName,
      fiatBalance: entity.fiatBalance,
      btcBalance: entity.btcBalance,
      ethBalance: entity.ethBalance,
      btcPriceUsd: entity.btcPriceUsd,
      ethPriceUsd: entity.ethPriceUsd,
      currencyCode: entity.currencyCode,
      isBalanceHidden: entity.isBalanceHidden,
      holdings: entity.holdings,
      selectedCurrencyCode: entity.selectedCurrencyCode,
    );
  }
}
