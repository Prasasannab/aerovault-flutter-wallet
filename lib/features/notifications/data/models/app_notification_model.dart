import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.category,
    required super.priority,
    required super.timestamp,
    super.isRead = false,
    super.referenceCode,
    super.amountFormatted,
  });

  @override
  AppNotificationModel copyWith({
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
    return AppNotificationModel(
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

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NotificationCategory.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      referenceCode: json['referenceCode'] as String?,
      amountFormatted: json['amountFormatted'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category.name,
      'priority': priority.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'referenceCode': referenceCode,
      'amountFormatted': amountFormatted,
    };
  }
}
