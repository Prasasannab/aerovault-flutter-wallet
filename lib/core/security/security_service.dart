import 'dart:async';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'anti_tamper_service.dart';
import 'biometric_service.dart';
import 'hardware_keystore_service.dart';

/// Central Bank-Grade Security Service Orchestrator
class SecurityService {
  final HardwareKeystoreService keystoreService;
  final BiometricService biometricService;
  final AntiTamperService antiTamperService;

  // Ephemeral in-memory dynamic session encryption key (never persisted to disk)
  String? _ephemeralSessionKey;
  int _failedPinAttempts = 0;
  bool _isLockedOut = false;

  SecurityService({
    required this.keystoreService,
    required this.biometricService,
    required this.antiTamperService,
  }) {
    _rotateSessionKey();
  }

  String get ephemeralSessionKey => _ephemeralSessionKey ??= const Uuid().v4();
  int get failedPinAttempts => _failedPinAttempts;
  bool get isLockedOut => _isLockedOut;
  int get remainingPinAttempts =>
      (AppConstants.maxPinAttempts - _failedPinAttempts).clamp(0, AppConstants.maxPinAttempts);

  void _rotateSessionKey() {
    _ephemeralSessionKey = const Uuid().v4();
  }

  /// Initialize and verify device security integrity on application launch
  Future<DeviceIntegrityResult> performStartupIntegrityAudit() async {
    final result = await antiTamperService.checkDeviceIntegrity();

    if (!result.isSecure) {
      // Immediate emergency wipe on compromise
      await emergencyWipeOnCompromise();
      throw DeviceCompromisedException(
        message: 'Security compromise detected! App execution terminated.',
        reasons: result.issues,
      );
    }

    return result;
  }

  /// Authenticate using Biometrics with immediate fallback to PIN
  Future<bool> authenticateBiometric() async {
    final isEnabled = await keystoreService.isBiometricsEnabled();
    if (!isEnabled) {
      return false;
    }

    final authenticated = await biometricService.authenticate(
      localizedReason: 'Authenticate with Face ID / Biometrics to access AeroVault',
    );

    if (authenticated) {
      _resetPinAttempts();
      _rotateSessionKey();
    }

    return authenticated;
  }

  /// Verify entered 6-digit PIN with attempt throttling
  Future<bool> verifyPin(String pin) async {
    if (_isLockedOut) {
      throw const SecurityException(
        message: 'Account locked due to excessive failed attempts. Please contact customer support.',
      );
    }

    final isValid = await keystoreService.verifyPin(pin);

    if (isValid) {
      _resetPinAttempts();
      _rotateSessionKey();
      return true;
    } else {
      _failedPinAttempts++;
      if (_failedPinAttempts >= AppConstants.maxPinAttempts) {
        _isLockedOut = true;
        // Wipe session tokens upon lockout to protect customer funds
        await keystoreService.wipeAllTokensAndSecrets();
        throw const SecurityException(
          message: 'Maximum PIN attempts reached. Session wiped for protection.',
        );
      }
      return false;
    }
  }

  void _resetPinAttempts() {
    _failedPinAttempts = 0;
    _isLockedOut = false;
  }

  /// Immediate emergency wipe of all memory secrets, tokens, and hardware keystore
  Future<void> emergencyWipeOnCompromise() async {
    _ephemeralSessionKey = null;
    _failedPinAttempts = 0;
    _isLockedOut = true;
    await keystoreService.wipeAllTokensAndSecrets();
  }
}
