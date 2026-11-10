import '../../../../core/utils/result.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  const GetNotificationsUseCase(this.repository);

  Future<Result<List<AppNotification>>> call() => repository.getNotifications();
}
