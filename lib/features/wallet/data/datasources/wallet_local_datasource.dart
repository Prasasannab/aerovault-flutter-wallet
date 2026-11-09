import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/security/hardware_keystore_service.dart';
import '../models/virtual_card_model.dart';
import '../models/wallet_account_model.dart';

abstract class WalletDataSource {
  Future<WalletAccountModel> getWalletAccount();
  Future<VirtualCardModel> getVirtualCard();
  Future<bool> setCardFrozen({required bool freeze});
  Future<bool> setBalanceHidden({required bool hide});
}

/// Simulated Enterprise Banking Data Source with 350ms real-world network latency
class WalletDataSourceImpl implements WalletDataSource {
  final HardwareKeystoreService _keystoreService;

  bool _isCardFrozen = false;
  bool _isBalanceHidden = false;

  WalletDataSourceImpl(this._keystoreService);

  @override
  Future<WalletAccountModel> getWalletAccount() async {
    // Simulate real-world banking API transport latency
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );

    _isBalanceHidden = await _keystoreService.isBalanceHidden();

    return WalletAccountModel(
      id: 'ACC-8842-ENTERPRISE',
      holderName: AppConstants.defaultHolderName,
      fiatBalance: 84392.50,
      btcBalance: 1.4285,
      ethBalance: 18.5000,
      btcPriceUsd: 68450.00,
      ethPriceUsd: 3480.00,
      currencyCode: 'USD',
      isBalanceHidden: _isBalanceHidden,
    );
  }

  @override
  Future<VirtualCardModel> getVirtualCard() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );

    return VirtualCardModel(
      id: 'CARD-VISA-PLATINUM-8842',
      cardNumberMasked: AppConstants.defaultCardNumberMasked,
      cardholderName: AppConstants.defaultHolderName,
      expiry: AppConstants.defaultCardExpiry,
      cvvMasked: AppConstants.defaultCardCvvMasked,
      cardTier: 'VISA Platinum',
      isFrozen: _isCardFrozen,
      spendingLimit: 25000.00,
      currentSpend: 5799.00,
    );
  }

  @override
  Future<bool> setCardFrozen({required bool freeze}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _isCardFrozen = freeze;
    return _isCardFrozen;
  }

  @override
  Future<bool> setBalanceHidden({required bool hide}) async {
    await _keystoreService.setBalanceHidden(hide);
    _isBalanceHidden = hide;
    return _isBalanceHidden;
  }
}
