import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/errors/failures.dart';
import 'package:aerovault/core/utils/result.dart';
import 'package:aerovault/features/wallet/domain/entities/virtual_card.dart';
import 'package:aerovault/features/wallet/domain/entities/wallet_account.dart';
import 'package:aerovault/features/wallet/domain/usecases/get_virtual_card_usecase.dart';
import 'package:aerovault/features/wallet/domain/usecases/get_wallet_account_usecase.dart';
import 'package:aerovault/features/wallet/domain/usecases/toggle_balance_visibility_usecase.dart';
import 'package:aerovault/features/wallet/domain/usecases/toggle_card_freeze_usecase.dart';
import 'package:aerovault/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:aerovault/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:aerovault/features/wallet/presentation/bloc/wallet_state.dart';

class MockGetWalletAccountUseCase extends Mock implements GetWalletAccountUseCase {}
class MockGetVirtualCardUseCase extends Mock implements GetVirtualCardUseCase {}
class MockToggleCardFreezeUseCase extends Mock implements ToggleCardFreezeUseCase {}
class MockToggleBalanceVisibilityUseCase extends Mock implements ToggleBalanceVisibilityUseCase {}

void main() {
  late WalletBloc walletBloc;
  late MockGetWalletAccountUseCase mockGetWalletAccountUseCase;
  late MockGetVirtualCardUseCase mockGetVirtualCardUseCase;
  late MockToggleCardFreezeUseCase mockToggleCardFreezeUseCase;
  late MockToggleBalanceVisibilityUseCase mockToggleBalanceVisibilityUseCase;

  const testAccount = WalletAccount(
    id: 'ACC-1',
    holderName: 'Pasindu G.',
    fiatBalance: 84392.50,
    btcBalance: 1.4,
    ethBalance: 18.0,
    btcPriceUsd: 68000.0,
    ethPriceUsd: 3400.0,
  );

  const testCard = VirtualCard(
    id: 'CARD-1',
    cardNumberMasked: '•••• •••• •••• 8842',
    cardholderName: 'Pasindu G.',
    expiry: '11/29',
    cvvMasked: '•••',
  );

  setUp(() {
    mockGetWalletAccountUseCase = MockGetWalletAccountUseCase();
    mockGetVirtualCardUseCase = MockGetVirtualCardUseCase();
    mockToggleCardFreezeUseCase = MockToggleCardFreezeUseCase();
    mockToggleBalanceVisibilityUseCase = MockToggleBalanceVisibilityUseCase();

    walletBloc = WalletBloc(
      getWalletAccountUseCase: mockGetWalletAccountUseCase,
      getVirtualCardUseCase: mockGetVirtualCardUseCase,
      toggleCardFreezeUseCase: mockToggleCardFreezeUseCase,
      toggleBalanceVisibilityUseCase: mockToggleBalanceVisibilityUseCase,
    );
  });

  tearDown(() {
    walletBloc.close();
  });

  group('WalletBloc - LoadWalletEvent', () {
    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletLoaded] when both account and card load successfully',
      build: () {
        when(() => mockGetWalletAccountUseCase())
            .thenAnswer((_) async => Result.success(testAccount));
        when(() => mockGetVirtualCardUseCase())
            .thenAnswer((_) async => Result.success(testCard));
        return walletBloc;
      },
      act: (bloc) => bloc.add(const LoadWalletEvent()),
      expect: () => [
        const WalletLoading(),
        const WalletLoaded(account: testAccount, card: testCard),
      ],
      verify: (_) {
        verify(() => mockGetWalletAccountUseCase()).called(1);
        verify(() => mockGetVirtualCardUseCase()).called(1);
      },
    );

    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletError] when account retrieval fails',
      build: () {
        when(() => mockGetWalletAccountUseCase()).thenAnswer(
          (_) async => Result.error(const ServerFailure(message: 'Network timeout')),
        );
        when(() => mockGetVirtualCardUseCase())
            .thenAnswer((_) async => Result.success(testCard));
        return walletBloc;
      },
      act: (bloc) => bloc.add(const LoadWalletEvent()),
      expect: () => [
        const WalletLoading(),
        const WalletError('Network timeout'),
      ],
    );
  });

  group('WalletBloc - Mutations', () {
    blocTest<WalletBloc, WalletState>(
      'updates card.isFrozen when ToggleCardFreezeEvent succeeds',
      build: () {
        when(() => mockToggleCardFreezeUseCase(freeze: true))
            .thenAnswer((_) async => Result.success(true));
        return walletBloc;
      },
      seed: () => const WalletLoaded(account: testAccount, card: testCard),
      act: (bloc) => bloc.add(const ToggleCardFreezeEvent(freeze: true)),
      expect: () => [
        WalletLoaded(
          account: testAccount,
          card: testCard.copyWith(isFrozen: true),
        ),
      ],
      verify: (_) {
        verify(() => mockToggleCardFreezeUseCase(freeze: true)).called(1);
      },
    );

    blocTest<WalletBloc, WalletState>(
      'updates account.isBalanceHidden when ToggleBalanceVisibilityEvent succeeds',
      build: () {
        when(() => mockToggleBalanceVisibilityUseCase(hide: true))
            .thenAnswer((_) async => Result.success(true));
        return walletBloc;
      },
      seed: () => const WalletLoaded(account: testAccount, card: testCard),
      act: (bloc) => bloc.add(const ToggleBalanceVisibilityEvent(hide: true)),
      expect: () => [
        WalletLoaded(
          account: testAccount.copyWith(isBalanceHidden: true),
          card: testCard,
        ),
      ],
      verify: (_) {
        verify(() => mockToggleBalanceVisibilityUseCase(hide: true)).called(1);
      },
    );

    blocTest<WalletBloc, WalletState>(
      'adjusts fiat and crypto balances when AdjustWalletBalanceEvent is dispatched',
      build: () => walletBloc,
      seed: () => const WalletLoaded(account: testAccount, card: testCard),
      act: (bloc) => bloc.add(const AdjustWalletBalanceEvent(fiatDelta: -500.0, btcDelta: 0.1)),
      expect: () => [
        WalletLoaded(
          account: testAccount.copyWith(
            fiatBalance: testAccount.fiatBalance - 500.0,
            btcBalance: testAccount.btcBalance + 0.1,
          ),
          card: testCard,
        ),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'switches active currency holding when SwitchCurrencyHoldingEvent is dispatched',
      build: () => walletBloc,
      seed: () => const WalletLoaded(account: testAccount, card: testCard),
      act: (bloc) => bloc.add(const SwitchCurrencyHoldingEvent('EUR')),
      expect: () => [
        WalletLoaded(
          account: testAccount.copyWith(selectedCurrencyCode: 'EUR'),
          card: testCard,
        ),
      ],
    );
  });
}
