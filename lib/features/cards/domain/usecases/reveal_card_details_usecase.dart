import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';
import '../repositories/cards_repository.dart';

class RevealCardDetailsUseCase {
  final CardsRepository _repository;

  const RevealCardDetailsUseCase(this._repository);

  Future<Result<PaymentCard>> call({required String cardId}) async {
    return _repository.revealCardDetails(cardId: cardId);
  }
}
