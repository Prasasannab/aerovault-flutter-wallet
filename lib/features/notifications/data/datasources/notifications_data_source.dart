import '../models/app_notification_model.dart';
import '../../domain/entities/app_notification.dart';

abstract class NotificationsDataSource {
  Future<List<AppNotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationsLocalDataSourceImpl implements NotificationsDataSource {
  final List<AppNotificationModel> _notifications = [
    AppNotificationModel(
      id: 'notif-001',
      title: 'Upwork Global Escrow Wire Credited',
      message: 'Direct deposit from Upwork Global Escrow confirmed & cleared via JPMorgan Chase NYC interbank settlement.',
      category: NotificationCategory.transfer,
      priority: NotificationPriority.high,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      isRead: false,
      referenceCode: 'TX-UPWORK-8842',
      amountFormatted: '+\$14,850.00',
    ),
    AppNotificationModel(
      id: 'notif-002',
      title: 'Hardware Secure Enclave Verified',
      message: 'Zero tampering detected. Hardware-backed Keychain keystore passed startup cryptographic integrity audit.',
      category: NotificationCategory.security,
      priority: NotificationPriority.critical,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
      isRead: false,
      referenceCode: 'SEC-ENCLAVE-91',
    ),
    AppNotificationModel(
      id: 'notif-003',
      title: 'Disposable Ghost Card Rolled',
      message: 'Dynamic 3-digit CVV and single-use PAN rolled successfully after digital subscription verification.',
      category: NotificationCategory.security,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      referenceCode: 'CARD-GHOST-ROLL',
    ),
    AppNotificationModel(
      id: 'notif-004',
      title: 'FINMA Swiss Statement Certified',
      message: 'Official Swiss Banking Statement generated with SHA-256 fingerprint proof and procedural QR matrix seal.',
      category: NotificationCategory.compliance,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: true,
      referenceCode: 'FINMA-CH-2026',
    ),
    AppNotificationModel(
      id: 'notif-005',
      title: 'Ethereum Cold Staking Yield Credited',
      message: 'Institutional PoS validator distribution completed. Staking reward allocated to cold storage reserve.',
      category: NotificationCategory.transfer,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      referenceCode: 'ETH-YIELD-441',
      amountFormatted: '+0.145 ETH',
    ),
  ];

  @override
  Future<List<AppNotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_notifications);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}
