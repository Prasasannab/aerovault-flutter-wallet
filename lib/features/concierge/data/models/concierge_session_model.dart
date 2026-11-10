import '../../domain/entities/concierge_session.dart';
import 'chat_message_model.dart';
import 'concierge_agent_model.dart';

class ConciergeSessionModel extends ConciergeSession {
  const ConciergeSessionModel({
    required super.sessionId,
    required super.encryptionProtocol,
    required super.agent,
    required super.messages,
    required super.quickPrompts,
  });

  factory ConciergeSessionModel.fromJson(Map<String, dynamic> json) {
    return ConciergeSessionModel(
      sessionId: json['session_id'] as String,
      encryptionProtocol: json['encryption_protocol'] as String,
      agent: ConciergeAgentModel.fromJson(json['agent'] as Map<String, dynamic>),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      quickPrompts: (json['quick_prompts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'encryption_protocol': encryptionProtocol,
      'agent': (agent is ConciergeAgentModel)
          ? (agent as ConciergeAgentModel).toJson()
          : ConciergeAgentModel(
              id: agent.id,
              name: agent.name,
              title: agent.title,
              location: agent.location,
              avatarUrl: agent.avatarUrl,
              isOnline: agent.isOnline,
              responseTimeSla: agent.responseTimeSla,
            ).toJson(),
      'messages': messages
          .map((m) => (m is ChatMessageModel)
              ? m.toJson()
              : ChatMessageModel(
                  id: m.id,
                  sender: m.sender,
                  text: m.text,
                  timestampFormatted: m.timestampFormatted,
                  deliveryStatus: m.deliveryStatus,
                  attachmentName: m.attachmentName,
                  attachmentType: m.attachmentType,
                  actionPrompts: m.actionPrompts,
                ).toJson())
          .toList(),
      'quick_prompts': quickPrompts,
    };
  }
}
