import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/constants/app_constants.dart';
import 'package:aerovault/core/errors/exceptions.dart';
import 'package:aerovault/core/security/anti_tamper_service.dart';
import 'package:aerovault/core/security/biometric_service.dart';
import 'package:aerovault/core/security/hardware_keystore_service.dart';
import 'package:aerovault/core/security/security_service.dart';

class MockHardwareKeystoreService extends Mock implements HardwareKeystoreService {}
class MockBiometricService extends Mock implements BiometricService {}
class MockAntiTamperService extends Mock implements AntiTamperService {}

void main() {
  late SecurityService securityService;
  late MockHardwareKeystoreService mockKeystoreService;
  late MockBiometricService mockBiometricService;
  late MockAntiTamperService mockAntiTamperService;

  setUp(() {
    mockKeystoreService = MockHardwareKeystoreService();
    mockBiometricService = MockBiometricService();
    mockAntiTamperService = MockAntiTamperService();

    securityService = SecurityService(
      keystoreService: mockKeystoreService,
      biometricService: mockBiometricService,
      antiTamperService: mockAntiTamperService,
    );
  });

  group('SecurityService - Startup Integrity Audit', () {
    test('returns secure result when device has no integrity violations', () async {
      when(() => mockAntiTamperService.checkDeviceIntegrity())
          .thenAnswer((_) async => DeviceIntegrityResult.secure());

      final result = await securityService.performStartupIntegrityAudit();

      expect(result.isSecure, isTrue);
      expect(result.issues, isEmpty);
      verify(() => mockAntiTamperService.checkDeviceIntegrity()).called(1);
      verifyNever(() => mockKeystoreService.wipeAllTokensAndSecrets());
    });

    test('wipes keystore immediately and throws DeviceCompromisedException on jailbreak/root', () async {
      when(() => mockAntiTamperService.checkDeviceIntegrity()).thenAnswer(
        (_) async => DeviceIntegrityResult.compromised(
          jailbroken: true,
          devMode: false,
          issues: ['Device is Jailbroken / Rooted.'],
        ),
      );
      when(() => mockKeystoreService.wipeAllTokensAndSecrets()).thenAnswer((_) async {});

      await expectLater(
        securityService.performStartupIntegrityAudit(),
        throwsA(isA<DeviceCompromisedException>()),
      );

      // Verify immediate session wipe was called
      verify(() => mockKeystoreService.wipeAllTokensAndSecrets()).called(1);
      expect(securityService.isLockedOut, isTrue);
    });
  });

  group('SecurityService - Biometric Authentication', () {
    test('authenticates via biometric sensor when enabled', () async {
      when(() => mockKeystoreService.isBiometricsEnabled()).thenAnswer((_) async => true);
      when(() => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          )).thenAnswer((_) async => true);

      final success = await securityService.authenticateBiometric();

      expect(success, isTrue);
      expect(securityService.failedPinAttempts, 0);
      verify(() => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          )).called(1);
    });

    test('returns false when biometrics are toggled off by user', () async {
      when(() => mockKeystoreService.isBiometricsEnabled()).thenAnswer((_) async => false);

      final success = await securityService.authenticateBiometric();

      expect(success, isFalse);
      verifyNever(() => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ));
    });
  });

  group('SecurityService - PIN Throttling & Lockout Protection', () {
    test('validates correct PIN and resets attempt counter', () async {
      when(() => mockKeystoreService.verifyPin('123456')).thenAnswer((_) async => true);

      final result = await securityService.verifyPin('123456');

      expect(result, isTrue);
      expect(securityService.failedPinAttempts, 0);
      expect(securityService.isLockedOut, isFalse);
    });

    test('increments failure counter on invalid PIN', () async {
      when(() => mockKeystoreService.verifyPin('000000')).thenAnswer((_) async => false);

      final result = await securityService.verifyPin('000000');

      expect(result, isFalse);
      expect(securityService.failedPinAttempts, 1);
      expect(securityService.remainingPinAttempts, AppConstants.maxPinAttempts - 1);
    });

    test('locks out account and wipes all secrets after 3 failed attempts', () async {
      when(() => mockKeystoreService.verifyPin('wrong')).thenAnswer((_) async => false);
      when(() => mockKeystoreService.wipeAllTokensAndSecrets()).thenAnswer((_) async {});

      // 1st attempt
      await securityService.verifyPin('wrong');
      expect(securityService.failedPinAttempts, 1);

      // 2nd attempt
      await securityService.verifyPin('wrong');
      expect(securityService.failedPinAttempts, 2);

      // 3rd attempt: reaches threshold -> triggers emergency wipe and throws SecurityException
      await expectLater(
        securityService.verifyPin('wrong'),
        throwsA(isA<SecurityException>()),
      );

      expect(securityService.isLockedOut, isTrue);
      verify(() => mockKeystoreService.wipeAllTokensAndSecrets()).called(1);
    });
  });
}
