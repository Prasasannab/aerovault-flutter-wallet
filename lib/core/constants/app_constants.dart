/// Application-wide constants for AeroVault
class AppConstants {
  const AppConstants._();

  static const String appName = 'AeroVault';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Enterprise Multi-Currency & Crypto Neobank';

  // Secure Storage Keys
  static const String keyAccessToken = 'aerovault_access_token_v1';
  static const String keyRefreshToken = 'aerovault_refresh_token_v1';
  static const String keyPinHash = 'aerovault_user_pin_hash_v1';
  static const String keyPinSalt = 'aerovault_user_pin_salt_v1';
  static const String keyBiometricsEnabled = 'aerovault_biometrics_flag_v1';
  static const String keyAccountHolderName = 'aerovault_holder_name_v1';
  static const String keyIsCardFrozen = 'aerovault_card_frozen_v1';
  static const String keyBalanceHidden = 'aerovault_balance_hidden_v1';

  // Default Mock Holder
  static const String defaultHolderName = 'Pasindu G.';
  static const String defaultCardNumberMasked = '•••• •••• •••• 8842';
  static const String defaultCardExpiry = '11/29';
  static const String defaultCardCvvMasked = '•••';

  // Network & Session
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
  static const int simulatedNetworkDelayMs = 350;
  static const int maxPinAttempts = 3;
}
