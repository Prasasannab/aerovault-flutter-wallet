import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_card.dart';

abstract class CardsEvent extends Equatable {
  const CardsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCardsEvent extends CardsEvent {
  const LoadCardsEvent();
}

class SelectCardIndexEvent extends CardsEvent {
  final int index;
  const SelectCardIndexEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ToggleFreezeCardEvent extends CardsEvent {
  final String cardId;
  final bool freeze;

  const ToggleFreezeCardEvent({required this.cardId, required this.freeze});

  @override
  List<Object?> get props => [cardId, freeze];
}

class UpdateCardLimitEvent extends CardsEvent {
  final String cardId;
  final double limit;

  const UpdateCardLimitEvent({required this.cardId, required this.limit});

  @override
  List<Object?> get props => [cardId, limit];
}

class ToggleCardChannelEvent extends CardsEvent {
  final String cardId;
  final CardChannel channel;
  final bool isEnabled;

  const ToggleCardChannelEvent({
    required this.cardId,
    required this.channel,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [cardId, channel, isEnabled];
}

class RevealCardDetailsEvent extends CardsEvent {
  final String cardId;

  const RevealCardDetailsEvent({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class RegenerateDisposableCardEvent extends CardsEvent {
  final String cardId;

  const RegenerateDisposableCardEvent({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class IssueNewCardEvent extends CardsEvent {
  final String name;
  final CardType type;
  final double limit;

  const IssueNewCardEvent({
    required this.name,
    required this.type,
    required this.limit,
  });

  @override
  List<Object?> get props => [name, type, limit];
}
