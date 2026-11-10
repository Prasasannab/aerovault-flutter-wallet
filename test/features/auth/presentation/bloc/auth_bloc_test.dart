import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/security/security_service.dart';
import 'package:aerovault/features/auth/domain/usecases/authenticate_biometric_usecase.dart';
import 'package:aerovault/features/auth/domain/usecases/verify_pin_usecase.dart';
import 'package:aerovault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aerovault/features/auth/presentation/bloc/auth_event.dart';
import 'package:aerovault/features/auth/presentation/bloc/auth_state.dart';

class MockVerifyPinUseCase extends Mock implements VerifyPinUseCase {}
class MockAuthenticateBiometricUseCase extends Mock implements AuthenticateBiometricUseCase {}
class MockSecurityService extends Mock implements SecurityService {}

void main() {
  late AuthBloc authBloc;
  late MockVerifyPinUseCase mockVerifyPinUseCase;
  late MockAuthenticateBiometricUseCase mockAuthenticateBiometricUseCase;
  late MockSecurityService mockSecurityService;

  setUp(() {
    mockVerifyPinUseCase = MockVerifyPinUseCase();
    mockAuthenticateBiometricUseCase = MockAuthenticateBiometricUseCase();
    mockSecurityService = MockSecurityService();

    authBloc = AuthBloc(
      verifyPinUseCase: mockVerifyPinUseCase,
      authenticateBiometricUseCase: mockAuthenticateBiometricUseCase,
      securityService: mockSecurityService,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthChecking, AuthAuthenticated] when valid PIN is verified',
      build: () {
        when(() => mockVerifyPinUseCase('123456')).thenAnswer((_) async => true);
        return authBloc;
      },
      act: (bloc) => bloc.add(const VerifyPinEvent('123456')),
      expect: () => [
        const AuthChecking(),
        const AuthAuthenticated(method: 'PIN'),
      ],
      verify: (_) {
        verify(() => mockVerifyPinUseCase('123456')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthChecking, AuthPinError] when invalid PIN is entered',
      build: () {
        when(() => mockVerifyPinUseCase('000000')).thenAnswer((_) async => false);
        when(() => mockSecurityService.isLockedOut).thenReturn(false);
        when(() => mockSecurityService.remainingPinAttempts).thenReturn(2);
        return authBloc;
      },
      act: (bloc) => bloc.add(const VerifyPinEvent('000000')),
      expect: () => [
        const AuthChecking(),
        const AuthPinError(
          message: 'Invalid cryptographic PIN.',
          remainingAttempts: 2,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthChecking, AuthLockedOut] when security lockout threshold is reached',
      build: () {
        when(() => mockVerifyPinUseCase('999999')).thenAnswer((_) async => false);
        when(() => mockSecurityService.isLockedOut).thenReturn(true);
        when(() => mockSecurityService.remainingPinAttempts).thenReturn(0);
        return authBloc;
      },
      act: (bloc) => bloc.add(const VerifyPinEvent('999999')),
      expect: () => [
        const AuthChecking(),
        isA<AuthLockedOut>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthChecking, AuthAuthenticated] when biometric authorization succeeds',
      build: () {
        when(() => mockAuthenticateBiometricUseCase(
              localizedReason: any(named: 'localizedReason'),
            )).thenAnswer((_) async => true);
        return authBloc;
      },
      act: (bloc) => bloc.add(const BiometricAuthEvent()),
      expect: () => [
        const AuthChecking(),
        const AuthAuthenticated(method: 'BIOMETRIC'),
      ],
    );
  });
}
