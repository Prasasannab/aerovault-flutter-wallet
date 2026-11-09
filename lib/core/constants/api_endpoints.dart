/// Banking API endpoints & SSL Certificate Fingerprints
class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = 'https://api.aerovault.bank/v1';

  // Endpoints
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authVerifyPin = '/auth/verify-pin';
  static const String walletBalance = '/wallet/balances';
  static const String walletCard = '/wallet/virtual-card';
  static const String walletToggleFreeze = '/wallet/virtual-card/freeze';
  static const String transactions = '/transactions';
  static const String analyticsPerformance = '/analytics/performance';

  // Production SHA-256 Public Key Pinning Hashes for api.aerovault.bank
  static const List<String> pinnedCertificateFingerprints = [
    // Primary Certificate SHA-256
    '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
    // Backup Disaster Recovery Certificate SHA-256
    '4870f2b3e8544974f268f7d983411b938383a8b4ecf1a92e105e263d91f24522',
  ];
}
