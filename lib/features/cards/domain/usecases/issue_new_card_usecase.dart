import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';
import '../repositories/cards_repository.dart';

class IssueNewCardUseCase {
  final CardsRepository _repository;

  const IssueNewCardUseCase(this._repository);

  Future<Result<PaymentCard>> call({
    required String name,
    required CardType type,
    required double limit,
  }) async {
    return _repository.issueNewCard(
      name: name,
      type: type,
      limit: limit,
    );
  }
}
