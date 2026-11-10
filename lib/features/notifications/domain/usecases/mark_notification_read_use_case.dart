import '../../../../core/utils/result.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository repository;

  const MarkNotificationReadUseCase(this.repository);

  Future<Result<void>> call(String notificationId) =>
      repository.markNotificationAsRead(notificationId);
}
