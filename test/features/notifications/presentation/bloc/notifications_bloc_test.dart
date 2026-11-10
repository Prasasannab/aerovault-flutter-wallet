import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/utils/result.dart';
import 'package:aerovault/features/notifications/domain/entities/app_notification.dart';
import 'package:aerovault/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:aerovault/features/notifications/domain/usecases/mark_all_notifications_read_use_case.dart';
import 'package:aerovault/features/notifications/domain/usecases/mark_notification_read_use_case.dart';
import 'package:aerovault/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:aerovault/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:aerovault/features/notifications/presentation/bloc/notifications_state.dart';

class MockGetNotificationsUseCase extends Mock implements GetNotificationsUseCase {}
class MockMarkNotificationReadUseCase extends Mock implements MarkNotificationReadUseCase {}
class MockMarkAllNotificationsReadUseCase extends Mock implements MarkAllNotificationsReadUseCase {}

void main() {
  late NotificationsBloc notificationsBloc;
  late MockGetNotificationsUseCase mockGetNotifications;
  late MockMarkNotificationReadUseCase mockMarkNotificationRead;
  late MockMarkAllNotificationsReadUseCase mockMarkAllNotificationsRead;

  final testNotification1 = AppNotification(
    id: 'notif-1',
    title: 'Upwork Wire Received',
    message: 'Deposit confirmed',
    category: NotificationCategory.transfer,
    priority: NotificationPriority.high,
    timestamp: DateTime(2026, 11, 10, 12, 0),
    isRead: false,
    referenceCode: 'TX-UPWORK-8842',
  );

  final testNotification2 = AppNotification(
    id: 'notif-2',
    title: 'Enclave Validated',
    message: 'Keystore secure',
    category: NotificationCategory.security,
    priority: NotificationPriority.critical,
    timestamp: DateTime(2026, 11, 10, 11, 0),
    isRead: false,
  );

  setUp(() {
    mockGetNotifications = MockGetNotificationsUseCase();
    mockMarkNotificationRead = MockMarkNotificationReadUseCase();
    mockMarkAllNotificationsRead = MockMarkAllNotificationsReadUseCase();

    notificationsBloc = NotificationsBloc(
      getNotificationsUseCase: mockGetNotifications,
      markNotificationReadUseCase: mockMarkNotificationRead,
      markAllNotificationsReadUseCase: mockMarkAllNotificationsRead,
    );
  });

  tearDown(() {
    notificationsBloc.close();
  });

  test('initial state is NotificationsInitial', () {
    expect(notificationsBloc.state, equals(const NotificationsInitial()));
  });

  blocTest<NotificationsBloc, NotificationsState>(
    'emits [NotificationsLoading, NotificationsLoaded] when LoadNotificationsEvent succeeds',
    build: () {
      when(() => mockGetNotifications()).thenAnswer(
        (_) async => Result.success([testNotification1, testNotification2]),
      );
      return notificationsBloc;
    },
    act: (bloc) => bloc.add(const LoadNotificationsEvent()),
    expect: () => [
      const NotificationsLoading(),
      isA<NotificationsLoaded>()
          .having((s) => s.allNotifications.length, 'allNotifications.length', 2)
          .having((s) => s.unreadCount, 'unreadCount', 2),
    ],
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'filters notifications by category correctly',
    build: () => notificationsBloc,
    seed: () => NotificationsLoaded(
      allNotifications: [testNotification1, testNotification2],
      filteredNotifications: [testNotification1, testNotification2],
      unreadCount: 2,
    ),
    act: (bloc) => bloc.add(const FilterNotificationsCategoryEvent(NotificationCategory.security)),
    expect: () => [
      isA<NotificationsLoaded>()
          .having((s) => s.filteredNotifications.length, 'filtered.length', 1)
          .having((s) => s.filteredNotifications.first.id, 'id', 'notif-2')
          .having((s) => s.selectedCategory, 'selectedCategory', NotificationCategory.security),
    ],
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'marks single notification as read',
    build: () {
      when(() => mockMarkNotificationRead(any())).thenAnswer(
        (_) async => Result.success(null),
      );
      return notificationsBloc;
    },
    seed: () => NotificationsLoaded(
      allNotifications: [testNotification1, testNotification2],
      filteredNotifications: [testNotification1, testNotification2],
      unreadCount: 2,
    ),
    act: (bloc) => bloc.add(const MarkNotificationAsReadEvent('notif-1')),
    expect: () => [
      isA<NotificationsLoaded>()
          .having((s) => s.allNotifications.first.isRead, 'first.isRead', true)
          .having((s) => s.unreadCount, 'unreadCount', 1),
    ],
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'marks all notifications as read',
    build: () {
      when(() => mockMarkAllNotificationsRead()).thenAnswer(
        (_) async => Result.success(null),
      );
      return notificationsBloc;
    },
    seed: () => NotificationsLoaded(
      allNotifications: [testNotification1, testNotification2],
      filteredNotifications: [testNotification1, testNotification2],
      unreadCount: 2,
    ),
    act: (bloc) => bloc.add(const MarkAllNotificationsAsReadEvent()),
    expect: () => [
      isA<NotificationsLoaded>()
          .having((s) => s.allNotifications.every((n) => n.isRead), 'all read', true)
          .having((s) => s.unreadCount, 'unreadCount', 0),
    ],
  );
}
