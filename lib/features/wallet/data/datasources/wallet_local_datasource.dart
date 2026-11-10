import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/security/hardware_keystore_service.dart';
import '../models/currency_holding_model.dart';
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

    const holdings = [
      CurrencyHoldingModel(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        flagEmoji: '🇺🇸',
        balance: 84392.50,
        balanceUsdEquivalent: 84392.50,
        iban: 'US02 0260 0959 3884 21',
        clearingNetwork: 'Fedwire & ACH Domestic',
      ),
      CurrencyHoldingModel(
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
        flagEmoji: '🇪🇺',
        balance: 48250.00,
        balanceUsdEquivalent: 52327.12,
        iban: 'DE89 3704 0044 0532 0130 00',
        clearingNetwork: 'SEPA Instant (EBA Clearing)',
      ),
      CurrencyHoldingModel(
        code: 'CHF',
        name: 'Swiss Franc',
        symbol: 'CHF ',
        flagEmoji: '🇨🇭',
        balance: 36400.00,
        balanceUsdEquivalent: 41176.47,
        iban: 'CH93 0076 2011 6238 5295 7',
        clearingNetwork: 'SIX Swiss Interbank (SIC)',
      ),
      CurrencyHoldingModel(
        code: 'GBP',
        name: 'British Pound',
        symbol: '£',
        flagEmoji: '🇬🇧',
        balance: 12450.00,
        balanceUsdEquivalent: 16097.85,
        iban: 'GB29 AERO 2004 1588 4210 92',
        clearingNetwork: 'Faster Payments Service (FPS)',
      ),
      CurrencyHoldingModel(
        code: 'BTC',
        name: 'Bitcoin Cold Reserve',
        symbol: '₿',
        flagEmoji: '🪙',
        balance: 1.4285,
        balanceUsdEquivalent: 97780.82,
        iban: 'bc1qaero8842...reserve',
        clearingNetwork: 'Institutional Multi-Sig Cold Vault',
        isCrypto: true,
      ),
      CurrencyHoldingModel(
        code: 'ETH',
        name: 'Ethereum Staking',
        symbol: '⟠',
        flagEmoji: '💎',
        balance: 18.5000,
        balanceUsdEquivalent: 64380.00,
        iban: '0xaero8842...beacon',
        clearingNetwork: 'PoS Validator Node #41',
        isCrypto: true,
      ),
    ];

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
      holdings: holdings,
      selectedCurrencyCode: 'USD',
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
      cvvMasked: '•••',
      isFrozen: _isCardFrozen,
      spendingLimit: 25000.00,
      currentSpend: 4120.50,
    );
  }

  @override
  Future<bool> setCardFrozen({required bool freeze}) async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
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
