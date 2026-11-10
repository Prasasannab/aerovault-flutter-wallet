import 'package:equatable/equatable.dart';
import '../../domain/entities/app_notification.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationsEvent {
  const LoadNotificationsEvent();
}

class FilterNotificationsCategoryEvent extends NotificationsEvent {
  final NotificationCategory? category;

  const FilterNotificationsCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class MarkNotificationAsReadEvent extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsReadEvent extends NotificationsEvent {
  const MarkAllNotificationsAsReadEvent();
}
