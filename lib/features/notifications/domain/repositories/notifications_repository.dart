import '../../../../core/utils/result.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications();
  Future<Result<void>> markNotificationAsRead(String notificationId);
  Future<Result<void>> markAllNotificationsAsRead();
}
