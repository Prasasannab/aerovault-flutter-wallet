import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/utils/result.dart';
import 'package:aerovault/features/cards/domain/entities/payment_card.dart';
import 'package:aerovault/features/cards/domain/usecases/get_cards_usecase.dart';
import 'package:aerovault/features/cards/domain/usecases/issue_new_card_usecase.dart';
import 'package:aerovault/features/cards/domain/usecases/regenerate_disposable_card_usecase.dart';
import 'package:aerovault/features/cards/domain/usecases/reveal_card_details_usecase.dart';
import 'package:aerovault/features/cards/domain/usecases/toggle_card_channel_usecase.dart';
import 'package:aerovault/features/cards/domain/usecases/toggle_card_freeze_usecase.dart';
import 'package:aerovault/features/cards/domain/usecases/update_card_limit_usecase.dart';
import 'package:aerovault/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:aerovault/features/cards/presentation/bloc/cards_event.dart';
import 'package:aerovault/features/cards/presentation/bloc/cards_state.dart';

class MockGetCardsUseCase extends Mock implements GetCardsUseCase {}
class MockTogglePaymentCardFreezeUseCase extends Mock implements TogglePaymentCardFreezeUseCase {}
class MockUpdateCardLimitUseCase extends Mock implements UpdateCardLimitUseCase {}
class MockToggleCardChannelUseCase extends Mock implements ToggleCardChannelUseCase {}
class MockRevealCardDetailsUseCase extends Mock implements RevealCardDetailsUseCase {}
class MockRegenerateDisposableCardUseCase extends Mock implements RegenerateDisposableCardUseCase {}
class MockIssueNewCardUseCase extends Mock implements IssueNewCardUseCase {}

void main() {
  late CardsBloc cardsBloc;
  late MockGetCardsUseCase mockGetCardsUseCase;
  late MockTogglePaymentCardFreezeUseCase mockToggleFreezeUseCase;
  late MockUpdateCardLimitUseCase mockUpdateLimitUseCase;
  late MockToggleCardChannelUseCase mockToggleChannelUseCase;
  late MockRevealCardDetailsUseCase mockRevealDetailsUseCase;
  late MockRegenerateDisposableCardUseCase mockRegenerateUseCase;
  late MockIssueNewCardUseCase mockIssueCardUseCase;

  const testCard1 = PaymentCard(
    id: 'CARD-1',
    name: 'Obsidian Metal',
    type: CardType.metalPhysical,
    brand: CardBrand.visa,
    cardTier: 'VISA Infinite',
    maskedNumber: '•••• •••• •••• 8842',
    fullNumber: '4532 8842 1092 8842',
    cardholderName: 'PASINDU G.',
    expiry: '12/29',
    maskedCvv: '•••',
    cvv: '842',
    isFrozen: false,
    spendingLimit: 50000.0,
    currentSpend: 8420.0,
  );

  const testCard2 = PaymentCard(
    id: 'CARD-2',
    name: 'Ghost Card',
    type: CardType.disposableGhost,
    brand: CardBrand.mastercard,
    cardTier: 'Mastercard Dynamic',
    maskedNumber: '•••• •••• •••• 1234',
    fullNumber: '5412 1234 5678 1234',
    cardholderName: 'PASINDU G.',
    expiry: '04/26',
    maskedCvv: '•••',
    cvv: '999',
    isFrozen: false,
    spendingLimit: 2500.0,
    currentSpend: 0.0,
  );

  setUp(() {
    mockGetCardsUseCase = MockGetCardsUseCase();
    mockToggleFreezeUseCase = MockTogglePaymentCardFreezeUseCase();
    mockUpdateLimitUseCase = MockUpdateCardLimitUseCase();
    mockToggleChannelUseCase = MockToggleCardChannelUseCase();
    mockRevealDetailsUseCase = MockRevealCardDetailsUseCase();
    mockRegenerateUseCase = MockRegenerateDisposableCardUseCase();
    mockIssueCardUseCase = MockIssueNewCardUseCase();

    cardsBloc = CardsBloc(
      getCardsUseCase: mockGetCardsUseCase,
      toggleCardFreezeUseCase: mockToggleFreezeUseCase,
      updateCardLimitUseCase: mockUpdateLimitUseCase,
      toggleCardChannelUseCase: mockToggleChannelUseCase,
      revealCardDetailsUseCase: mockRevealDetailsUseCase,
      regenerateDisposableCardUseCase: mockRegenerateUseCase,
      issueNewCardUseCase: mockIssueCardUseCase,
    );
  });

  tearDown(() {
    cardsBloc.close();
  });

  test('initial state is CardsInitial', () {
    expect(cardsBloc.state, const CardsInitial());
  });

  group('CardsBloc - LoadCardsEvent', () {
    blocTest<CardsBloc, CardsState>(
      'emits [CardsLoading, CardsLoaded] when cards are loaded successfully',
      build: () {
        when(() => mockGetCardsUseCase())
            .thenAnswer((_) async => Result.success([testCard1, testCard2]));
        return cardsBloc;
      },
      act: (bloc) => bloc.add(const LoadCardsEvent()),
      expect: () => [
        const CardsLoading(),
        const CardsLoaded(cards: [testCard1, testCard2], selectedIndex: 0),
      ],
      verify: (_) {
        verify(() => mockGetCardsUseCase()).called(1);
      },
    );
  });

  group('CardsBloc - SelectCardIndexEvent', () {
    blocTest<CardsBloc, CardsState>(
      'updates selectedIndex within bounds',
      seed: () => const CardsLoaded(cards: [testCard1, testCard2], selectedIndex: 0),
      build: () => cardsBloc,
      act: (bloc) => bloc.add(const SelectCardIndexEvent(1)),
      expect: () => [
        const CardsLoaded(cards: [testCard1, testCard2], selectedIndex: 1),
      ],
    );
  });

  group('CardsBloc - ToggleFreezeCardEvent', () {
    final frozenCard = testCard1.copyWith(isFrozen: true);

    blocTest<CardsBloc, CardsState>(
      'emits updated cards list with target card frozen',
      seed: () => const CardsLoaded(cards: [testCard1, testCard2], selectedIndex: 0),
      build: () {
        when(() => mockToggleFreezeUseCase(cardId: 'CARD-1', freeze: true))
            .thenAnswer((_) async => Result.success(frozenCard));
        return cardsBloc;
      },
      act: (bloc) => bloc.add(const ToggleFreezeCardEvent(cardId: 'CARD-1', freeze: true)),
      expect: () => [
        CardsLoaded(cards: [frozenCard, testCard2], selectedIndex: 0),
      ],
      verify: (_) {
        verify(() => mockToggleFreezeUseCase(cardId: 'CARD-1', freeze: true)).called(1);
      },
    );
  });

  group('CardsBloc - UpdateCardLimitEvent', () {
    final updatedLimitCard = testCard1.copyWith(spendingLimit: 75000.0);

    blocTest<CardsBloc, CardsState>(
      'emits updated cards with modified spending limit',
      seed: () => const CardsLoaded(cards: [testCard1, testCard2], selectedIndex: 0),
      build: () {
        when(() => mockUpdateLimitUseCase(cardId: 'CARD-1', limit: 75000.0))
            .thenAnswer((_) async => Result.success(updatedLimitCard));
        return cardsBloc;
      },
      act: (bloc) => bloc.add(const UpdateCardLimitEvent(cardId: 'CARD-1', limit: 75000.0)),
      expect: () => [
        CardsLoaded(cards: [updatedLimitCard, testCard2], selectedIndex: 0),
      ],
    );
  });

  group('CardsBloc - RevealCardDetailsEvent', () {
    final revealedCard = testCard1.copyWith(isSensitiveRevealed: true);

    blocTest<CardsBloc, CardsState>(
      'emits updated cards with sensitive credentials revealed',
      seed: () => const CardsLoaded(cards: [testCard1, testCard2], selectedIndex: 0),
      build: () {
        when(() => mockRevealDetailsUseCase(cardId: 'CARD-1'))
            .thenAnswer((_) async => Result.success(revealedCard));
        return cardsBloc;
      },
      act: (bloc) => bloc.add(const RevealCardDetailsEvent(cardId: 'CARD-1')),
      expect: () => [
        CardsLoaded(cards: [revealedCard, testCard2], selectedIndex: 0),
      ],
    );
  });
}
