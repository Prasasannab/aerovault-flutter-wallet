import '../../domain/entities/scheduled_transfer.dart';

class ScheduledTransferModel extends ScheduledTransfer {
  const ScheduledTransferModel({
    required super.id,
    required super.title,
    required super.recipient,
    required super.amount,
    required super.currency,
    required super.frequency,
    required super.nextExecutionDate,
    required super.category,
    super.isActive = true,
  });

  factory ScheduledTransferModel.fromJson(Map<String, dynamic> json) {
    return ScheduledTransferModel(
      id: json['id'] as String,
      title: json['title'] as String,
      recipient: json['recipient'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      frequency: json['frequency'] as String,
      nextExecutionDate: json['nextExecutionDate'] as String,
      category: json['category'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'recipient': recipient,
      'amount': amount,
      'currency': currency,
      'frequency': frequency,
      'nextExecutionDate': nextExecutionDate,
      'category': category,
      'isActive': isActive,
    };
  }
}
