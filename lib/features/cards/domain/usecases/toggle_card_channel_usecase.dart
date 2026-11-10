import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';
import '../repositories/cards_repository.dart';

class ToggleCardChannelUseCase {
  final CardsRepository _repository;

  const ToggleCardChannelUseCase(this._repository);

  Future<Result<PaymentCard>> call({
    required String cardId,
    required CardChannel channel,
    required bool isEnabled,
  }) async {
    return _repository.toggleChannel(
      cardId: cardId,
      channel: channel,
      isEnabled: isEnabled,
    );
  }
}
