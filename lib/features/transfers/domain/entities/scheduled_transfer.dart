import 'package:equatable/equatable.dart';

/// Represents an automated recurring direct order or standing wire
class ScheduledTransfer extends Equatable {
  final String id;
  final String title;
  final String recipient;
  final double amount;
  final String currency;
  final String frequency;
  final String nextExecutionDate;
  final String category;
  final bool isActive;

  const ScheduledTransfer({
    required this.id,
    required this.title,
    required this.recipient,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.nextExecutionDate,
    required this.category,
    this.isActive = true,
  });

  ScheduledTransfer copyWith({
    String? id,
    String? title,
    String? recipient,
    double? amount,
    String? currency,
    String? frequency,
    String? nextExecutionDate,
    String? category,
    bool? isActive,
  }) {
    return ScheduledTransfer(
      id: id ?? this.id,
      title: title ?? this.title,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      frequency: frequency ?? this.frequency,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        recipient,
        amount,
        currency,
        frequency,
        nextExecutionDate,
        category,
        isActive,
      ];
}
