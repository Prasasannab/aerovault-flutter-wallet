import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';
import '../repositories/cards_repository.dart';

class UpdateCardLimitUseCase {
  final CardsRepository _repository;

  const UpdateCardLimitUseCase(this._repository);

  Future<Result<PaymentCard>> call({
    required String cardId,
    required double limit,
  }) async {
    return _repository.updateSpendingLimit(cardId: cardId, limit: limit);
  }
}
