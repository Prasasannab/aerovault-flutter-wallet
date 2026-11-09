import '../../../../core/utils/result.dart';
import '../repositories/wallet_repository.dart';

/// Single responsibility use case: Obfuscate or reveal wallet balance for privacy
class ToggleBalanceVisibilityUseCase {
  final WalletRepository _repository;

  ToggleBalanceVisibilityUseCase(this._repository);

  Future<Result<bool>> call({required bool hide}) async {
    return await _repository.toggleBalanceVisibility(hide: hide);
  }
}
