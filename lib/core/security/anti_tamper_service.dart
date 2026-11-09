import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter/services.dart';

/// Device Integrity and Anti-Tampering Check Result
class DeviceIntegrityResult {
  final bool isSecure;
  final bool isJailbrokenOrRooted;
  final bool isDeveloperModeActive;
  final List<String> issues;

  const DeviceIntegrityResult({
    required this.isSecure,
    required this.isJailbrokenOrRooted,
    required this.isDeveloperModeActive,
    required this.issues,
  });

  factory DeviceIntegrityResult.secure() {
    return const DeviceIntegrityResult(
      isSecure: true,
      isJailbrokenOrRooted: false,
      isDeveloperModeActive: false,
      issues: [],
    );
  }

  factory DeviceIntegrityResult.compromised({
    required bool jailbroken,
    required bool devMode,
    required List<String> issues,
  }) {
    return DeviceIntegrityResult(
      isSecure: false,
      isJailbrokenOrRooted: jailbroken,
      isDeveloperModeActive: devMode,
      issues: issues,
    );
  }
}

/// Anti-Tampering, Jailbreak, and Root Detection Service
class AntiTamperService {
  /// Scan device environment for jailbreak, root binaries, and unsafe developer configurations
  Future<DeviceIntegrityResult> checkDeviceIntegrity({
    bool allowDevModeInDebug = true,
  }) async {
    final issues = <String>[];
    bool isJailbroken = false;
    bool isDevMode = false;

    try {
      isJailbroken = await FlutterJailbreakDetection.jailbroken;
      if (isJailbroken) {
        issues.add('Device is Jailbroken / Rooted. Unsafe execution environment.');
      }
    } on PlatformException catch (e) {
      // In simulator/unsupported platforms or errors, handle gracefully
      issues.add('Failed to verify jailbreak status: ${e.message}');
    }

    try {
      isDevMode = await FlutterJailbreakDetection.developerMode;
      if (isDevMode && !allowDevModeInDebug) {
        issues.add('Android Developer Options / ADB Debugging is enabled.');
      }
    } on PlatformException {
      // iOS doesn't have Android-style developer mode API
    }

    final bool isSecure = isJailbroken == false && issues.isEmpty;

    return DeviceIntegrityResult(
      isSecure: isSecure,
      isJailbrokenOrRooted: isJailbroken,
      isDeveloperModeActive: isDevMode,
      issues: issues,
    );
  }
}
