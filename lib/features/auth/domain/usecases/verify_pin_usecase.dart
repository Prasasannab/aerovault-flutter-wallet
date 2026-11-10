import '../../../../core/security/security_service.dart';

/// Domain UseCase to verify user's 6-digit cryptographic PIN
class VerifyPinUseCase {
  final SecurityService securityService;

  const VerifyPinUseCase(this.securityService);

  Future<bool> call(String pin) async {
    return await securityService.verifyPin(pin);
  }
}
