import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/payment_card.dart';
import '../../domain/repositories/cards_repository.dart';
import '../datasources/cards_local_datasource.dart';

class CardsRepositoryImpl implements CardsRepository {
  final CardsDataSource _dataSource;

  CardsRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<PaymentCard>>> getCards() async {
    try {
      final models = await _dataSource.getCards();
      return Result.success(models);
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to retrieve payment cards: $e'));
    }
  }

  @override
  Future<Result<PaymentCard>> toggleCardFreeze({
    required String cardId,
    required bool freeze,
  }) async {
    try {
      final updated = await _dataSource.toggleCardFreeze(cardId: cardId, freeze: freeze);
      return Result.success(updated);
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to update freeze status: $e'));
    }
  }

  @override
  Future<Result<PaymentCard>> updateSpendingLimit({
    required String cardId,
    required double limit,
  }) async {
    try {
      final updated = await _dataSource.updateSpendingLimit(cardId: cardId, limit: limit);
      return Result.success(updated);
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to update spending limit: $e'));
    }
  }

  @override
  Future<Result<PaymentCard>> toggleChannel({
    required String cardId,
    required CardChannel channel,
    required bool isEnabled,
  }) async {
    try {
      final updated = await _dataSource.toggleChannel(
        cardId: cardId,
        channel: channel,
        isEnabled: isEnabled,
      );
      return Result.success(updated);
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to toggle security channel: $e'));
    }
  }

  @override
  Future<Result<PaymentCard>> revealCardDetails({required String cardId}) async {
    try {
      final updated = await _dataSource.revealCardDetails(cardId: cardId);
      return Result.success(updated);
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to toggle sensitive details: $e'));
    }
  }

  @override
  Future<Result<PaymentCard>> regenerateDisposableCard({required String cardId}) async {
    try {
      final updated = await _dataSource.regenerateDisposableCard(cardId: cardId);
      return Result.success(updated);
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to regenerate disposable card: $e'));
    }
  }

  @override
  Future<Result<PaymentCard>> issueNewCard({
    required String name,
    required CardType type,
    required double limit,
  }) async {
    try {
      final created = await _dataSource.issueNewCard(
        name: name,
        type: type,
        limit: limit,
      );
      return Result.success(created);
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to issue new card: $e'));
    }
  }
}
