import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';
import '../repositories/cards_repository.dart';

class RegenerateDisposableCardUseCase {
  final CardsRepository _repository;

  const RegenerateDisposableCardUseCase(this._repository);

  Future<Result<PaymentCard>> call({required String cardId}) async {
    return _repository.regenerateDisposableCard(cardId: cardId);
  }
}
