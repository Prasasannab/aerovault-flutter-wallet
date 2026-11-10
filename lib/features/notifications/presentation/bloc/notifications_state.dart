import 'package:equatable/equatable.dart';
import '../../domain/entities/app_notification.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> allNotifications;
  final List<AppNotification> filteredNotifications;
  final NotificationCategory? selectedCategory;
  final int unreadCount;

  const NotificationsLoaded({
    required this.allNotifications,
    required this.filteredNotifications,
    this.selectedCategory,
    required this.unreadCount,
  });

  NotificationsLoaded copyWith({
    List<AppNotification>? allNotifications,
    List<AppNotification>? filteredNotifications,
    NotificationCategory? selectedCategory,
    bool clearCategory = false,
    int? unreadCount,
  }) {
    return NotificationsLoaded(
      allNotifications: allNotifications ?? this.allNotifications,
      filteredNotifications: filteredNotifications ?? this.filteredNotifications,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        allNotifications,
        filteredNotifications,
        selectedCategory,
        unreadCount,
      ];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
