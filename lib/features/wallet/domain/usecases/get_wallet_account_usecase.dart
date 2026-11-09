import '../../../../core/utils/result.dart';
import '../entities/wallet_account.dart';
import '../repositories/wallet_repository.dart';

/// Single responsibility use case: Retrieve active wallet balances & assets
class GetWalletAccountUseCase {
  final WalletRepository _repository;

  GetWalletAccountUseCase(this._repository);

  Future<Result<WalletAccount>> call() async {
    return await _repository.getWalletAccount();
  }
}
