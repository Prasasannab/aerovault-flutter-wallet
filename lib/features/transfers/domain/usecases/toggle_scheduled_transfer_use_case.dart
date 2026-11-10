import '../../../../core/utils/result.dart';
import '../entities/scheduled_transfer.dart';
import '../repositories/transfers_repository.dart';

class ToggleScheduledTransferUseCase {
  final TransfersRepository repository;

  const ToggleScheduledTransferUseCase(this.repository);

  Future<Result<ScheduledTransfer>> call({
    required String transferId,
    required bool isActive,
  }) =>
      repository.toggleScheduledTransfer(
        transferId: transferId,
        isActive: isActive,
      );
}
