import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/errors/failures.dart';
import 'package:aerovault/core/utils/result.dart';
import 'package:aerovault/features/profile/domain/entities/authorized_device.dart';
import 'package:aerovault/features/profile/domain/entities/kyc_document.dart';
import 'package:aerovault/features/profile/domain/entities/user_profile.dart';
import 'package:aerovault/features/profile/domain/usecases/get_user_profile_use_case.dart';
import 'package:aerovault/features/profile/domain/usecases/revoke_device_use_case.dart';
import 'package:aerovault/features/profile/domain/usecases/update_transfer_limits_use_case.dart';
import 'package:aerovault/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aerovault/features/profile/presentation/bloc/profile_event.dart';
import 'package:aerovault/features/profile/presentation/bloc/profile_state.dart';

class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}
class MockUpdateTransferLimitsUseCase extends Mock implements UpdateTransferLimitsUseCase {}
class MockRevokeDeviceUseCase extends Mock implements RevokeDeviceUseCase {}

void main() {
  late ProfileBloc profileBloc;
  late MockGetUserProfileUseCase mockGetUserProfileUseCase;
  late MockUpdateTransferLimitsUseCase mockUpdateTransferLimitsUseCase;
  late MockRevokeDeviceUseCase mockRevokeDeviceUseCase;

  const testProfile = UserProfile(
    id: 'USR-8842-ENTERPRISE',
    fullName: 'Prasanna Buddhika',
    preferredName: 'Prasanna',
    email: 'pasindu.g@aerovault.swiss',
    phoneMasked: '+41 79 ••• •• 42',
    taxResidence: 'Zurich, Switzerland (CH)',
    clientTier: 'Tier 3 Sovereign Private',
    finmaRegulated: true,
    amlRiskScore: 'Ultra-Low (0.01)',
    dailyWireLimit: 500000.0,
    dailyAtmLimit: 10000.0,
    monthlyCardCap: 100000.0,
    hardwareEnclaveKeyId: 'SEC-ENCLAVE-8842',
    biometricsEnabled: true,
    documents: [
      KycDocument(
        id: 'DOC-1',
        title: 'Swiss Biometric Passport',
        documentType: 'Passport',
        documentNumberMasked: 'PA••••8842',
        status: KycDocumentStatus.verified,
        verifiedDate: '14 Oct 2024',
        expiryDate: '14 Oct 2034',
        issuingAuthority: 'EDA',
      ),
    ],
    authorizedDevices: [
      AuthorizedDevice(
        id: 'DEV-1',
        deviceName: 'iPhone 16 Pro',
        platform: 'iOS 18.2',
        isCurrentDevice: true,
        lastActive: 'Active Now',
        hardwareEnclaveType: 'Apple Secure Enclave',
        ipAddressMasked: '194.230.•••.12',
      ),
    ],
  );

  setUp(() {
    mockGetUserProfileUseCase = MockGetUserProfileUseCase();
    mockUpdateTransferLimitsUseCase = MockUpdateTransferLimitsUseCase();
    mockRevokeDeviceUseCase = MockRevokeDeviceUseCase();

    profileBloc = ProfileBloc(
      getUserProfileUseCase: mockGetUserProfileUseCase,
      updateTransferLimitsUseCase: mockUpdateTransferLimitsUseCase,
      revokeDeviceUseCase: mockRevokeDeviceUseCase,
    );
  });

  tearDown(() {
    profileBloc.close();
  });

  test('initial state is ProfileInitial', () {
    expect(profileBloc.state, const ProfileInitial());
  });

  group('ProfileBloc - LoadProfileEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when profile is fetched successfully',
      build: () {
        when(() => mockGetUserProfileUseCase())
            .thenAnswer((_) async => Result.success(testProfile));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        const ProfileLoading(),
        const ProfileLoaded(profile: testProfile),
      ],
      verify: (_) {
        verify(() => mockGetUserProfileUseCase()).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when fetching profile fails',
      build: () {
        when(() => mockGetUserProfileUseCase())
            .thenAnswer((_) async => Result.error(const ServerFailure(message: 'Server error')));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        const ProfileLoading(),
        const ProfileError('Server error'),
      ],
    );
  });

  group('ProfileBloc - UpdateLimitsEvent', () {
    final updatedProfile = testProfile.copyWith(
      dailyWireLimit: 750000.0,
      monthlyCardCap: 150000.0,
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileLoaded with updated limits when current state is ProfileLoaded',
      build: () {
        when(() => mockUpdateTransferLimitsUseCase(
              dailyWireLimit: 750000.0,
              monthlyCardCap: 150000.0,
            )).thenAnswer((_) async => Result.success(updatedProfile));
        return profileBloc;
      },
      seed: () => const ProfileLoaded(profile: testProfile),
      act: (bloc) => bloc.add(
        const UpdateLimitsEvent(
          dailyWireLimit: 750000.0,
          monthlyCardCap: 150000.0,
        ),
      ),
      expect: () => [
        ProfileLoaded(
          profile: updatedProfile,
          feedbackMessage: 'Banking limits updated and signed by Swiss clearing core',
        ),
      ],
    );
  });

  group('ProfileBloc - RevokeDeviceEvent', () {
    final revokedProfile = testProfile.copyWith(authorizedDevices: const []);

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileLoaded with device revoked when current state is ProfileLoaded',
      build: () {
        when(() => mockRevokeDeviceUseCase('DEV-1'))
            .thenAnswer((_) async => Result.success(revokedProfile));
        return profileBloc;
      },
      seed: () => const ProfileLoaded(profile: testProfile),
      act: (bloc) => bloc.add(const RevokeDeviceEvent('DEV-1')),
      expect: () => [
        ProfileLoaded(
          profile: revokedProfile,
          feedbackMessage: 'Device hardware enclave key revoked successfully',
        ),
      ],
    );
  });
}
