import '../../../../core/utils/result.dart';
import '../entities/virtual_card.dart';
import '../repositories/wallet_repository.dart';

/// Single responsibility use case: Retrieve virtual card status & limits
class GetVirtualCardUseCase {
  final WalletRepository _repository;

  GetVirtualCardUseCase(this._repository);

  Future<Result<VirtualCard>> call() async {
    return await _repository.getVirtualCard();
  }
}
