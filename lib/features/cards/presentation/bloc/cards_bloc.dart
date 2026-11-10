import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_cards_usecase.dart';
import '../../domain/usecases/issue_new_card_usecase.dart';
import '../../domain/usecases/regenerate_disposable_card_usecase.dart';
import '../../domain/usecases/reveal_card_details_usecase.dart';
import '../../domain/usecases/toggle_card_channel_usecase.dart';
import '../../domain/usecases/toggle_card_freeze_usecase.dart';
import '../../domain/usecases/update_card_limit_usecase.dart';
import 'cards_event.dart';
import 'cards_state.dart';

class CardsBloc extends Bloc<CardsEvent, CardsState> {
  final GetCardsUseCase getCardsUseCase;
  final TogglePaymentCardFreezeUseCase toggleCardFreezeUseCase;
  final UpdateCardLimitUseCase updateCardLimitUseCase;
  final ToggleCardChannelUseCase toggleCardChannelUseCase;
  final RevealCardDetailsUseCase revealCardDetailsUseCase;
  final RegenerateDisposableCardUseCase regenerateDisposableCardUseCase;
  final IssueNewCardUseCase issueNewCardUseCase;

  CardsBloc({
    required this.getCardsUseCase,
    required this.toggleCardFreezeUseCase,
    required this.updateCardLimitUseCase,
    required this.toggleCardChannelUseCase,
    required this.revealCardDetailsUseCase,
    required this.regenerateDisposableCardUseCase,
    required this.issueNewCardUseCase,
  }) : super(const CardsInitial()) {
    on<LoadCardsEvent>(_onLoadCards);
    on<SelectCardIndexEvent>(_onSelectCardIndex);
    on<ToggleFreezeCardEvent>(_onToggleFreezeCard);
    on<UpdateCardLimitEvent>(_onUpdateCardLimit);
    on<ToggleCardChannelEvent>(_onToggleCardChannel);
    on<RevealCardDetailsEvent>(_onRevealCardDetails);
    on<RegenerateDisposableCardEvent>(_onRegenerateDisposableCard);
    on<IssueNewCardEvent>(_onIssueNewCard);
  }

  Future<void> _onLoadCards(
    LoadCardsEvent event,
    Emitter<CardsState> emit,
  ) async {
    emit(const CardsLoading());
    final result = await getCardsUseCase();
    if (result.isSuccess) {
      emit(CardsLoaded(cards: result.dataOrNull ?? []));
    } else {
      emit(CardsError(result.failureOrNull?.message ?? 'Failed to load cards.'));
    }
  }

  void _onSelectCardIndex(
    SelectCardIndexEvent event,
    Emitter<CardsState> emit,
  ) {
    final currentState = state;
    if (currentState is CardsLoaded) {
      if (event.index >= 0 && event.index < currentState.cards.length) {
        emit(currentState.copyWith(selectedIndex: event.index));
      }
    }
  }

  Future<void> _onToggleFreezeCard(
    ToggleFreezeCardEvent event,
    Emitter<CardsState> emit,
  ) async {
    final currentState = state;
    if (currentState is CardsLoaded) {
      final result = await toggleCardFreezeUseCase(
        cardId: event.cardId,
        freeze: event.freeze,
      );
      if (result.isSuccess) {
        final updatedCard = result.dataOrNull!;
        final updatedList = currentState.cards.map((c) {
          return c.id == updatedCard.id ? updatedCard : c;
        }).toList();
        emit(currentState.copyWith(cards: updatedList));
      }
    }
  }

  Future<void> _onUpdateCardLimit(
    UpdateCardLimitEvent event,
    Emitter<CardsState> emit,
  ) async {
    final currentState = state;
    if (currentState is CardsLoaded) {
      final result = await updateCardLimitUseCase(
        cardId: event.cardId,
        limit: event.limit,
      );
      if (result.isSuccess) {
        final updatedCard = result.dataOrNull!;
        final updatedList = currentState.cards.map((c) {
          return c.id == updatedCard.id ? updatedCard : c;
        }).toList();
        emit(currentState.copyWith(cards: updatedList));
      }
    }
  }

  Future<void> _onToggleCardChannel(
    ToggleCardChannelEvent event,
    Emitter<CardsState> emit,
  ) async {
    final currentState = state;
    if (currentState is CardsLoaded) {
      final result = await toggleCardChannelUseCase(
        cardId: event.cardId,
        channel: event.channel,
        isEnabled: event.isEnabled,
      );
      if (result.isSuccess) {
        final updatedCard = result.dataOrNull!;
        final updatedList = currentState.cards.map((c) {
          return c.id == updatedCard.id ? updatedCard : c;
        }).toList();
        emit(currentState.copyWith(cards: updatedList));
      }
    }
  }

  Future<void> _onRevealCardDetails(
    RevealCardDetailsEvent event,
    Emitter<CardsState> emit,
  ) async {
    final currentState = state;
    if (currentState is CardsLoaded) {
      final result = await revealCardDetailsUseCase(cardId: event.cardId);
      if (result.isSuccess) {
        final updatedCard = result.dataOrNull!;
        final updatedList = currentState.cards.map((c) {
          return c.id == updatedCard.id ? updatedCard : c;
        }).toList();
        emit(currentState.copyWith(cards: updatedList));
      }
    }
  }

  Future<void> _onRegenerateDisposableCard(
    RegenerateDisposableCardEvent event,
    Emitter<CardsState> emit,
  ) async {
    final currentState = state;
    if (currentState is CardsLoaded) {
      final result = await regenerateDisposableCardUseCase(cardId: event.cardId);
      if (result.isSuccess) {
        final updatedCard = result.dataOrNull!;
        final updatedList = currentState.cards.map((c) {
          return c.id == updatedCard.id ? updatedCard : c;
        }).toList();
        emit(currentState.copyWith(cards: updatedList));
      }
    }
  }

  Future<void> _onIssueNewCard(
    IssueNewCardEvent event,
    Emitter<CardsState> emit,
  ) async {
    final currentState = state;
    if (currentState is CardsLoaded) {
      final result = await issueNewCardUseCase(
        name: event.name,
        type: event.type,
        limit: event.limit,
      );
      if (result.isSuccess) {
        final newCard = result.dataOrNull!;
        final updatedList = [...currentState.cards, newCard];
        emit(currentState.copyWith(
          cards: updatedList,
          selectedIndex: updatedList.length - 1,
        ));
      }
    }
  }
}
