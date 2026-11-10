import '../../../../core/utils/result.dart';
import '../entities/scheduled_transfer.dart';
import '../repositories/transfers_repository.dart';

class GetScheduledTransfersUseCase {
  final TransfersRepository repository;

  const GetScheduledTransfersUseCase(this.repository);

  Future<Result<List<ScheduledTransfer>>> call() =>
      repository.getScheduledTransfers();
}
