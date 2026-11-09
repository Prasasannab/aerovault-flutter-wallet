import '../../../../core/utils/result.dart';
import '../entities/virtual_card.dart';
import '../entities/wallet_account.dart';

/// Contract interface for Wallet operations (Dependency Inversion Principle)
abstract class WalletRepository {
  Future<Result<WalletAccount>> getWalletAccount();
  Future<Result<VirtualCard>> getVirtualCard();
  Future<Result<bool>> toggleCardFreeze({required bool freeze});
  Future<Result<bool>> toggleBalanceVisibility({required bool hide});
}
