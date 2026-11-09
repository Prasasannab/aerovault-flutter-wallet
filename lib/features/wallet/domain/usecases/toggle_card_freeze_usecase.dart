import '../../../../core/utils/result.dart';
import '../repositories/wallet_repository.dart';

/// Single responsibility use case: Freeze or unfreeze the virtual card instantly
class ToggleCardFreezeUseCase {
  final WalletRepository _repository;

  ToggleCardFreezeUseCase(this._repository);

  Future<Result<bool>> call({required bool freeze}) async {
    return await _repository.toggleCardFreeze(freeze: freeze);
  }
}
