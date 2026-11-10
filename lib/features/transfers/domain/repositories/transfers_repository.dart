import '../../../../core/utils/result.dart';
import '../entities/fx_rate.dart';
import '../entities/scheduled_transfer.dart';
import '../entities/wire_routing_info.dart';

/// Contract interface for Transfers & FX Hub operations
abstract class TransfersRepository {
  Future<Result<List<FxRate>>> getFxRates();
  Future<Result<List<ScheduledTransfer>>> getScheduledTransfers();
  Future<Result<ScheduledTransfer>> toggleScheduledTransfer({
    required String transferId,
    required bool isActive,
  });
  Future<Result<WireRoutingInfo>> getWireRoutingInfo();
}
