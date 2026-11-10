import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_use_case.dart';
import '../../domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../domain/usecases/mark_notification_read_use_case.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;

  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllNotificationsReadUseCase,
  }) : super(const NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<FilterNotificationsCategoryEvent>(_onFilterCategory);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());

    final result = await getNotificationsUseCase();
    final items = result.dataOrNull;

    if (items != null) {
      final unread = items.where((n) => !n.isRead).length;
      emit(NotificationsLoaded(
        allNotifications: items,
        filteredNotifications: items,
        selectedCategory: null,
        unreadCount: unread,
      ));
    } else {
      emit(const NotificationsError('Failed to load bank audit notifications'));
    }
  }

  void _onFilterCategory(
    FilterNotificationsCategoryEvent event,
    Emitter<NotificationsState> emit,
  ) {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    final filtered = event.category == null
        ? currentState.allNotifications
        : currentState.allNotifications
            .where((n) => n.category == event.category)
            .toList();

    emit(currentState.copyWith(
      filteredNotifications: filtered,
      selectedCategory: event.category,
      clearCategory: event.category == null,
    ));
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    await markNotificationReadUseCase(event.notificationId);

    final updatedAll = currentState.allNotifications.map((n) {
      if (n.id == event.notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final filtered = currentState.selectedCategory == null
        ? updatedAll
        : updatedAll
            .where((n) => n.category == currentState.selectedCategory)
            .toList();

    final unread = updatedAll.where((n) => !n.isRead).length;

    emit(currentState.copyWith(
      allNotifications: updatedAll,
      filteredNotifications: filtered,
      unreadCount: unread,
    ));
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    await markAllNotificationsReadUseCase();

    final updatedAll =
        currentState.allNotifications.map((n) => n.copyWith(isRead: true)).toList();

    final filtered = currentState.selectedCategory == null
        ? updatedAll
        : updatedAll
            .where((n) => n.category == currentState.selectedCategory)
            .toList();

    emit(currentState.copyWith(
      allNotifications: updatedAll,
      filteredNotifications: filtered,
      unreadCount: 0,
    ));
  }
}
