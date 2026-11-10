import '../../../../core/security/security_service.dart';

/// Domain UseCase to authenticate via hardware biometric sensors (Face ID / Touch ID)
class AuthenticateBiometricUseCase {
  final SecurityService securityService;

  const AuthenticateBiometricUseCase(this.securityService);

  Future<bool> call({String localizedReason = 'Authenticate to access AeroVault Sovereign'}) async {
    return await securityService.authenticateBiometric(localizedReason: localizedReason);
  }
}
