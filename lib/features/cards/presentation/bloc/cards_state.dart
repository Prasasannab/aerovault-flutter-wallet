import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_card.dart';

abstract class CardsState extends Equatable {
  const CardsState();

  @override
  List<Object?> get props => [];
}

class CardsInitial extends CardsState {
  const CardsInitial();
}

class CardsLoading extends CardsState {
  const CardsLoading();
}

class CardsLoaded extends CardsState {
  final List<PaymentCard> cards;
  final int selectedIndex;

  const CardsLoaded({
    required this.cards,
    this.selectedIndex = 0,
  });

  PaymentCard get activeCard =>
      cards.isNotEmpty && selectedIndex < cards.length ? cards[selectedIndex] : cards.first;

  CardsLoaded copyWith({
    List<PaymentCard>? cards,
    int? selectedIndex,
  }) {
    return CardsLoaded(
      cards: cards ?? this.cards,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [cards, selectedIndex];
}

class CardsError extends CardsState {
  final String message;

  const CardsError(this.message);

  @override
  List<Object?> get props => [message];
}
