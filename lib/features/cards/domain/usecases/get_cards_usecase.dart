import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';
import '../repositories/cards_repository.dart';

class GetCardsUseCase {
  final CardsRepository _repository;

  const GetCardsUseCase(this._repository);

  Future<Result<List<PaymentCard>>> call() async {
    return _repository.getCards();
  }
}
