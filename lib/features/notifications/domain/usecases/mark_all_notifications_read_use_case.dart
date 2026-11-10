import '../../../../core/utils/result.dart';
import '../repositories/notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationsRepository repository;

  const MarkAllNotificationsReadUseCase(this.repository);

  Future<Result<void>> call() => repository.markAllNotificationsAsRead();
}
