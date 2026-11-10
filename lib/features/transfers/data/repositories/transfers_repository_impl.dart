import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/fx_rate.dart';
import '../../domain/entities/scheduled_transfer.dart';
import '../../domain/entities/wire_routing_info.dart';
import '../../domain/repositories/transfers_repository.dart';
import '../datasources/transfers_data_source.dart';

class TransfersRepositoryImpl implements TransfersRepository {
  final TransfersDataSource dataSource;

  const TransfersRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<FxRate>>> getFxRates() async {
    try {
      final rates = await dataSource.getFxRates();
      return Result.success(rates);
    } catch (e) {
      return Result.error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ScheduledTransfer>>> getScheduledTransfers() async {
    try {
      final transfers = await dataSource.getScheduledTransfers();
      return Result.success(transfers);
    } catch (e) {
      return Result.error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ScheduledTransfer>> toggleScheduledTransfer({
    required String transferId,
    required bool isActive,
  }) async {
    try {
      final transfer = await dataSource.toggleScheduledTransfer(
        transferId: transferId,
        isActive: isActive,
      );
      return Result.success(transfer);
    } catch (e) {
      return Result.error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<WireRoutingInfo>> getWireRoutingInfo() async {
    try {
      final routing = await dataSource.getWireRoutingInfo();
      return Result.success(routing);
    } catch (e) {
      return Result.error(ServerFailure(message: e.toString()));
    }
  }
}
