import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:aerovault/features/governance/domain/entities/approval_signer.dart';
import 'package:aerovault/features/governance/domain/entities/governance_request.dart';
import 'package:aerovault/features/governance/domain/usecases/get_governance_requests_use_case.dart';
import 'package:aerovault/features/governance/domain/usecases/reject_governance_request_use_case.dart';
import 'package:aerovault/features/governance/domain/usecases/sign_governance_request_use_case.dart';
import 'package:aerovault/features/governance/presentation/bloc/governance_bloc.dart';
import 'package:aerovault/features/governance/presentation/bloc/governance_event.dart';
import 'package:aerovault/features/governance/presentation/bloc/governance_state.dart';

class MockGetGovernanceRequestsUseCase extends Mock
    implements GetGovernanceRequestsUseCase {}

class MockSignGovernanceRequestUseCase extends Mock
    implements SignGovernanceRequestUseCase {}

class MockRejectGovernanceRequestUseCase extends Mock
    implements RejectGovernanceRequestUseCase {}

void main() {
  late MockGetGovernanceRequestsUseCase mockGetGovernanceRequestsUseCase;
  late MockSignGovernanceRequestUseCase mockSignGovernanceRequestUseCase;
  late MockRejectGovernanceRequestUseCase mockRejectGovernanceRequestUseCase;
  late GovernanceBloc governanceBloc;

  final tRequest = GovernanceRequest(
    id: 'GOV-WIRE-01',
    title: 'Swiss Escrow Wire',
    description: 'Wire authorization',
    amount: 500000.0,
    currency: 'USD',
    recipient: 'Baker Escrow',
    recipientAddressOrIban: 'CH93 0000',
    initiatedBy: 'Marc Oberholzer',
    initiatedAt: DateTime(2026, 11, 10),
    requiredSignatures: 2,
    totalSigners: 3,
    signers: const [
      ApprovalSigner(
        id: 'SIGNER-01',
        name: 'Alexander Vance',
        role: 'CEO',
        hasApproved: true,
      ),
      ApprovalSigner(
        id: 'SIGNER-02',
        name: 'Pasindu Gayashan',
        role: 'Lead Architect',
        hasApproved: false,
      ),
    ],
    status: GovernanceStatus.pending,
    urgency: GovernanceUrgency.critical,
  );

  setUp(() {
    mockGetGovernanceRequestsUseCase = MockGetGovernanceRequestsUseCase();
    mockSignGovernanceRequestUseCase = MockSignGovernanceRequestUseCase();
    mockRejectGovernanceRequestUseCase = MockRejectGovernanceRequestUseCase();

    governanceBloc = GovernanceBloc(
      getGovernanceRequestsUseCase: mockGetGovernanceRequestsUseCase,
      signGovernanceRequestUseCase: mockSignGovernanceRequestUseCase,
      rejectGovernanceRequestUseCase: mockRejectGovernanceRequestUseCase,
    );
  });

  tearDown(() {
    governanceBloc.close();
  });

  test('initial state is GovernanceInitial', () {
    expect(governanceBloc.state, equals(const GovernanceInitial()));
  });

  blocTest<GovernanceBloc, GovernanceState>(
    'GovernanceBloc - LoadGovernanceRequestsEvent emits [GovernanceLoading, GovernanceLoaded] when successful',
    build: () {
      when(() => mockGetGovernanceRequestsUseCase())
          .thenAnswer((_) async => [tRequest]);
      return governanceBloc;
    },
    act: (bloc) => bloc.add(const LoadGovernanceRequestsEvent()),
    expect: () => [
      const GovernanceLoading(),
      GovernanceLoaded(requests: [tRequest]),
    ],
  );

  blocTest<GovernanceBloc, GovernanceState>(
    'GovernanceBloc - LoadGovernanceRequestsEvent emits [GovernanceLoading, GovernanceError] when use case fails',
    build: () {
      when(() => mockGetGovernanceRequestsUseCase())
          .thenThrow(Exception('Network timeout'));
      return governanceBloc;
    },
    act: (bloc) => bloc.add(const LoadGovernanceRequestsEvent()),
    expect: () => [
      const GovernanceLoading(),
      const GovernanceError(
          'Failed to load corporate governance requests: Exception: Network timeout'),
    ],
  );

  blocTest<GovernanceBloc, GovernanceState>(
    'GovernanceBloc - SignGovernanceRequestEvent updates request and emits toast message',
    build: () {
      final updated = tRequest.copyWith(
        signers: const [
          ApprovalSigner(
            id: 'SIGNER-01',
            name: 'Alexander Vance',
            role: 'CEO',
            hasApproved: true,
          ),
          ApprovalSigner(
            id: 'SIGNER-02',
            name: 'Pasindu Gayashan',
            role: 'Lead Architect',
            hasApproved: true,
          ),
        ],
        status: GovernanceStatus.approved,
      );

      when(() => mockSignGovernanceRequestUseCase(
            requestId: any(named: 'requestId'),
            signerId: any(named: 'signerId'),
            signerName: any(named: 'signerName'),
            note: any(named: 'note'),
          )).thenAnswer((_) async => updated);

      return governanceBloc;
    },
    seed: () => GovernanceLoaded(requests: [tRequest]),
    act: (bloc) => bloc.add(const SignGovernanceRequestEvent(
      requestId: 'GOV-WIRE-01',
      signerId: 'SIGNER-02',
      signerName: 'Pasindu Gayashan',
    )),
    expect: () => [
      isA<GovernanceLoaded>().having(
        (s) => s.toastMessage,
        'toastMessage',
        contains('Corporate Dual-Control Authorization Complete'),
      ),
    ],
  );

  blocTest<GovernanceBloc, GovernanceState>(
    'GovernanceBloc - RejectGovernanceRequestEvent updates request status to rejected',
    build: () {
      final rejected = tRequest.copyWith(
        status: GovernanceStatus.rejected,
        rejectionReason: 'Suspicious IBAN route',
      );

      when(() => mockRejectGovernanceRequestUseCase(
            requestId: any(named: 'requestId'),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => rejected);

      return governanceBloc;
    },
    seed: () => GovernanceLoaded(requests: [tRequest]),
    act: (bloc) => bloc.add(const RejectGovernanceRequestEvent(
      requestId: 'GOV-WIRE-01',
      reason: 'Suspicious IBAN route',
    )),
    expect: () => [
      isA<GovernanceLoaded>().having(
        (s) => s.toastMessage,
        'toastMessage',
        contains('Corporate authorization vetoed'),
      ),
    ],
  );

  blocTest<GovernanceBloc, GovernanceState>(
    'GovernanceBloc - FilterGovernanceTabEvent updates selectedTab index',
    build: () => governanceBloc,
    seed: () => GovernanceLoaded(requests: [tRequest]),
    act: (bloc) => bloc.add(const FilterGovernanceTabEvent(1)),
    expect: () => [
      GovernanceLoaded(requests: [tRequest], selectedTab: 1),
    ],
  );
}
