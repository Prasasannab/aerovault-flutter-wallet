import 'package:equatable/equatable.dart';

enum MessageSender { user, agent, system }
enum MessageDeliveryStatus { sending, sent, delivered, read }

class ChatMessage extends Equatable {
  final String id;
  final MessageSender sender;
  final String text;
  final String timestampFormatted;
  final MessageDeliveryStatus deliveryStatus;
  final String? attachmentName;
  final String? attachmentType;
  final List<String>? actionPrompts;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestampFormatted,
    this.deliveryStatus = MessageDeliveryStatus.read,
    this.attachmentName,
    this.attachmentType,
    this.actionPrompts,
  });

  @override
  List<Object?> get props => [
        id,
        sender,
        text,
        timestampFormatted,
        deliveryStatus,
        attachmentName,
        attachmentType,
        actionPrompts,
      ];
}
