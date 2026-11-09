import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/virtual_card.dart';
import '../../domain/entities/wallet_account.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_datasource.dart';

/// Implementation of WalletRepository converting Data Models to Domain Entities
class WalletRepositoryImpl implements WalletRepository {
  final WalletDataSource _dataSource;

  WalletRepositoryImpl(this._dataSource);

  @override
  Future<Result<WalletAccount>> getWalletAccount() async {
    try {
      final accountModel = await _dataSource.getWalletAccount();
      return Result.success(accountModel);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on CacheException catch (e) {
      return Result.error(CacheFailure(message: e.message));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to load wallet account: $e'));
    }
  }

  @override
  Future<Result<VirtualCard>> getVirtualCard() async {
    try {
      final cardModel = await _dataSource.getVirtualCard();
      return Result.success(cardModel);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to load virtual card: $e'));
    }
  }

  @override
  Future<Result<bool>> toggleCardFreeze({required bool freeze}) async {
    try {
      final result = await _dataSource.setCardFrozen(freeze: freeze);
      return Result.success(result);
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to toggle card freeze: $e'));
    }
  }

  @override
  Future<Result<bool>> toggleBalanceVisibility({required bool hide}) async {
    try {
      final result = await _dataSource.setBalanceHidden(hide: hide);
      return Result.success(result);
    } catch (e) {
      return Result.error(CacheFailure(message: 'Failed to update privacy preference: $e'));
    }
  }
}
