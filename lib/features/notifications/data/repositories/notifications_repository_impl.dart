import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsDataSource dataSource;

  const NotificationsRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<AppNotification>>> getNotifications() async {
    try {
      final items = await dataSource.getNotifications();
      return Result.success(items);
    } catch (e) {
      return Result.error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> markNotificationAsRead(String notificationId) async {
    try {
      await dataSource.markAsRead(notificationId);
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> markAllNotificationsAsRead() async {
    try {
      await dataSource.markAllAsRead();
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure(message: e.toString()));
    }
  }
}
