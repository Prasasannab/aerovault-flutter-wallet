import 'package:equatable/equatable.dart';

enum NotificationCategory {
  security,
  transfer,
  compliance,
  system,
}

enum NotificationPriority {
  critical,
  high,
  normal,
}

/// Represents an institutional bank alert, security event, or compliance ledger notice
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? referenceCode;
  final String? amountFormatted;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
    this.referenceCode,
    this.amountFormatted,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    String? referenceCode,
    String? amountFormatted,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      referenceCode: referenceCode ?? this.referenceCode,
      amountFormatted: amountFormatted ?? this.amountFormatted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        category,
        priority,
        timestamp,
        isRead,
        referenceCode,
        amountFormatted,
      ];
}
