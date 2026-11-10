import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/errors/failures.dart';
import 'package:aerovault/core/utils/result.dart';
import 'package:aerovault/features/earn/domain/entities/staking_vault.dart';
import 'package:aerovault/features/earn/domain/entities/yield_summary.dart';
import 'package:aerovault/features/earn/domain/usecases/claim_all_yield_use_case.dart';
import 'package:aerovault/features/earn/domain/usecases/get_earn_vaults_use_case.dart';
import 'package:aerovault/features/earn/domain/usecases/stake_asset_use_case.dart';
import 'package:aerovault/features/earn/domain/usecases/unstake_asset_use_case.dart';
import 'package:aerovault/features/earn/presentation/bloc/earn_bloc.dart';
import 'package:aerovault/features/earn/presentation/bloc/earn_event.dart';
import 'package:aerovault/features/earn/presentation/bloc/earn_state.dart';

class MockGetEarnVaultsUseCase extends Mock implements GetEarnVaultsUseCase {}
class MockStakeAssetUseCase extends Mock implements StakeAssetUseCase {}
class MockUnstakeAssetUseCase extends Mock implements UnstakeAssetUseCase {}
class MockClaimAllYieldUseCase extends Mock implements ClaimAllYieldUseCase {}

void main() {
  late EarnBloc earnBloc;
  late MockGetEarnVaultsUseCase mockGetEarnVaultsUseCase;
  late MockStakeAssetUseCase mockStakeAssetUseCase;
  late MockUnstakeAssetUseCase mockUnstakeAssetUseCase;
  late MockClaimAllYieldUseCase mockClaimAllYieldUseCase;

  const testVault = StakingVault(
    id: 'VAULT-1',
    assetCode: 'ETH',
    assetName: 'Ethereum PoS',
    symbol: '⟠',
    apyPercentage: 4.5,
    stakedBalance: 10.0,
    stakedBalanceUsd: 34000.0,
    accruedYield: 0.1,
    accruedYieldUsd: 340.0,
    term: StakingTerm.flexible,
    clearingAuditor: 'Consensys',
    riskLevel: 'Low',
    colorHex: 0xFF627EEA,
  );

  const testSummary = YieldSummary(
    totalStakedUsd: 34000.0,
    totalAccruedYieldUsd: 340.0,
    dailyProjectedYieldUsd: 4.2,
    monthlyProjectedYieldUsd: 126.0,
    yearlyProjectedYieldUsd: 1530.0,
    lastDistribution: 'Today',
    nextPayoutEta: 'in 8h',
  );

  setUp(() {
    mockGetEarnVaultsUseCase = MockGetEarnVaultsUseCase();
    mockStakeAssetUseCase = MockStakeAssetUseCase();
    mockUnstakeAssetUseCase = MockUnstakeAssetUseCase();
    mockClaimAllYieldUseCase = MockClaimAllYieldUseCase();

    earnBloc = EarnBloc(
      getEarnVaultsUseCase: mockGetEarnVaultsUseCase,
      stakeAssetUseCase: mockStakeAssetUseCase,
      unstakeAssetUseCase: mockUnstakeAssetUseCase,
      claimAllYieldUseCase: mockClaimAllYieldUseCase,
    );
  });

  tearDown(() {
    earnBloc.close();
  });

  test('initial state is EarnInitial', () {
    expect(earnBloc.state, const EarnInitial());
  });

  group('EarnBloc - LoadEarnVaultsEvent', () {
    blocTest<EarnBloc, EarnState>(
      'emits [EarnLoading, EarnLoaded] when vaults are retrieved successfully',
      build: () {
        when(() => mockGetEarnVaultsUseCase())
            .thenAnswer((_) async => Result.success(([testVault], testSummary)));
        return earnBloc;
      },
      act: (bloc) => bloc.add(const LoadEarnVaultsEvent()),
      expect: () => [
        const EarnLoading(),
        const EarnLoaded(vaults: [testVault], summary: testSummary),
      ],
      verify: (_) {
        verify(() => mockGetEarnVaultsUseCase()).called(1);
      },
    );

    blocTest<EarnBloc, EarnState>(
      'emits [EarnLoading, EarnError] when retrieval fails',
      build: () {
        when(() => mockGetEarnVaultsUseCase())
            .thenAnswer((_) async => Result.error(const ServerFailure(message: 'Vault failure')));
        return earnBloc;
      },
      act: (bloc) => bloc.add(const LoadEarnVaultsEvent()),
      expect: () => [
        const EarnLoading(),
        const EarnError('Vault failure'),
      ],
    );
  });

  group('EarnBloc - StakeAssetEvent', () {
    final updatedVault = testVault.copyWith(stakedBalance: 15.0, stakedBalanceUsd: 51000.0);

    blocTest<EarnBloc, EarnState>(
      'emits EarnLoaded with new balance and toast message',
      build: () {
        when(() => mockStakeAssetUseCase(vaultId: 'VAULT-1', amount: 5.0))
            .thenAnswer((_) async => Result.success(([updatedVault], testSummary)));
        return earnBloc;
      },
      seed: () => const EarnLoaded(vaults: [testVault], summary: testSummary),
      act: (bloc) => bloc.add(const StakeAssetEvent(vaultId: 'VAULT-1', amount: 5.0)),
      expect: () => [
        EarnLoaded(
          vaults: [updatedVault],
          summary: testSummary,
          toastMessage: 'Successfully deposited and staked into vault.',
        ),
      ],
    );
  });

  group('EarnBloc - ClaimAllYieldEvent', () {
    final zeroYieldVault = testVault.copyWith(accruedYield: 0.0, accruedYieldUsd: 0.0);
    final zeroSummary = testSummary.copyWith(totalAccruedYieldUsd: 0.0);

    blocTest<EarnBloc, EarnState>(
      'emits EarnLoaded with zeroed yield and claim toast message',
      build: () {
        when(() => mockClaimAllYieldUseCase())
            .thenAnswer((_) async => Result.success(([zeroYieldVault], zeroSummary, 340.0)));
        return earnBloc;
      },
      seed: () => const EarnLoaded(vaults: [testVault], summary: testSummary),
      act: (bloc) => bloc.add(const ClaimAllYieldEvent()),
      expect: () => [
        EarnLoaded(
          vaults: [zeroYieldVault],
          summary: zeroSummary,
          toastMessage: 'Claimed \$340.00 accrued yield to balance.',
        ),
      ],
    );
  });
}
