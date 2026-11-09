import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../errors/exceptions.dart';

/// Bank-Grade Biometrics Service (FaceID, TouchID, Android Biometrics)
class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  /// Check whether the device supports biometric hardware and has biometrics enrolled
  Future<bool> canAuthenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } on PlatformException catch (e) {
      throw SecurityException(message: 'Error checking biometrics support: ${e.message}');
    }
  }

  /// Retrieve available biometric sensors (e.g. FaceID, Fingerprint)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      throw SecurityException(message: 'Error getting available biometrics: ${e.message}');
    }
  }

  /// Authenticate user strictly using Biometrics (Zero fallback to device passcode)
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = true,
  }) async {
    try {
      final hasHardware = await canAuthenticate();
      if (!hasHardware) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable' || e.code == 'NotEnrolled') {
        return false;
      }
      throw SecurityException(message: 'Biometric authentication failed: ${e.message}');
    }
  }

  /// Cancel any pending biometric authentication requests
  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (_) {}
  }
}
