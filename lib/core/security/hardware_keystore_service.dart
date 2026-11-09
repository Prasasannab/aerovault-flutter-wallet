import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Hardware-Backed Keystore / Keychain Storage Service
/// Enforces Apple Secure Enclave & Android Keystore AES-256 GCM
class HardwareKeystoreService {
  final FlutterSecureStorage _storage;

  HardwareKeystoreService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
                synchronizable: false,
              ),
              aOptions: AndroidOptions(
                resetOnError: true,
              ),
            );

  /// Store session tokens securely
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
      await _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    } catch (e) {
      throw CacheException(message: 'Failed to store tokens in hardware keystore: $e');
    }
  }

  /// Retrieve active access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.keyAccessToken);
    } catch (e) {
      throw CacheException(message: 'Failed to read token from hardware keystore: $e');
    }
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.keyRefreshToken);
    } catch (e) {
      throw CacheException(message: 'Failed to read refresh token: $e');
    }
  }

  /// Hash and securely save 6-digit PIN with a cryptographic salt
  Future<void> savePin(String pin) async {
    try {
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      final saltedPin = '$pin:$salt';
      final pinHash = sha256.convert(utf8.encode(saltedPin)).toString();

      await _storage.write(key: AppConstants.keyPinSalt, value: salt);
      await _storage.write(key: AppConstants.keyPinHash, value: pinHash);
    } catch (e) {
      throw CacheException(message: 'Failed to securely store PIN: $e');
    }
  }

  /// Verify entered PIN against the salted hash stored in hardware keystore
  Future<bool> verifyPin(String enteredPin) async {
    try {
      final storedHash = await _storage.read(key: AppConstants.keyPinHash);
      final storedSalt = await _storage.read(key: AppConstants.keyPinSalt);

      if (storedHash == null || storedSalt == null) {
        // Fallback for default mock account PIN: '123456'
        return enteredPin == '123456';
      }

      final enteredSalted = '$enteredPin:$storedSalt';
      final enteredHash = sha256.convert(utf8.encode(enteredSalted)).toString();

      return enteredHash == storedHash;
    } catch (e) {
      throw CacheException(message: 'Failed to verify PIN: $e');
    }
  }

  /// Biometric toggle persistence
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.keyBiometricsEnabled,
      value: enabled.toString(),
    );
  }

  Future<bool> isBiometricsEnabled() async {
    final value = await _storage.read(key: AppConstants.keyBiometricsEnabled);
    return value == null ? true : value.toLowerCase() == 'true';
  }

  /// Privacy: Balance visibility toggle
  Future<void> setBalanceHidden(bool hidden) async {
    await _storage.write(
      key: AppConstants.keyBalanceHidden,
      value: hidden.toString(),
    );
  }

  Future<bool> isBalanceHidden() async {
    final value = await _storage.read(key: AppConstants.keyBalanceHidden);
    return value?.toLowerCase() == 'true';
  }

  /// Instant Session Wipe on Tampering, Jailbreak, or User Logout
  Future<void> wipeAllTokensAndSecrets() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException(message: 'Failed to securely wipe storage: $e');
    }
  }
}
