import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.sender,
    required super.text,
    required super.timestampFormatted,
    super.deliveryStatus = MessageDeliveryStatus.read,
    super.attachmentName,
    super.attachmentType,
    super.actionPrompts,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.agent,
      ),
      text: json['text'] as String,
      timestampFormatted: json['timestamp_formatted'] as String,
      deliveryStatus: MessageDeliveryStatus.values.firstWhere(
        (e) => e.name == json['delivery_status'],
        orElse: () => MessageDeliveryStatus.read,
      ),
      attachmentName: json['attachment_name'] as String?,
      attachmentType: json['attachment_type'] as String?,
      actionPrompts: (json['action_prompts'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.name,
      'text': text,
      'timestamp_formatted': timestampFormatted,
      'delivery_status': deliveryStatus.name,
      'attachment_name': attachmentName,
      'attachment_type': attachmentType,
      'action_prompts': actionPrompts,
    };
  }
}
