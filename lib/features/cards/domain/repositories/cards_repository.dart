import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';

/// Contract interface for Card Management operations
abstract class CardsRepository {
  Future<Result<List<PaymentCard>>> getCards();
  Future<Result<PaymentCard>> toggleCardFreeze({required String cardId, required bool freeze});
  Future<Result<PaymentCard>> updateSpendingLimit({required String cardId, required double limit});
  Future<Result<PaymentCard>> toggleChannel({
    required String cardId,
    required CardChannel channel,
    required bool isEnabled,
  });
  Future<Result<PaymentCard>> revealCardDetails({required String cardId});
  Future<Result<PaymentCard>> regenerateDisposableCard({required String cardId});
  Future<Result<PaymentCard>> issueNewCard({
    required String name,
    required CardType type,
    required double limit,
  });
}
