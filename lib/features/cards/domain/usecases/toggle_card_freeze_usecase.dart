import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';
import '../repositories/cards_repository.dart';

class TogglePaymentCardFreezeUseCase {
  final CardsRepository _repository;

  const TogglePaymentCardFreezeUseCase(this._repository);

  Future<Result<PaymentCard>> call({
    required String cardId,
    required bool freeze,
  }) async {
    return _repository.toggleCardFreeze(cardId: cardId, freeze: freeze);
  }
}
