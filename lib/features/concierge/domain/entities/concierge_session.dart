import 'package:equatable/equatable.dart';
import 'chat_message.dart';
import 'concierge_agent.dart';

class ConciergeSession extends Equatable {
  final String sessionId;
  final String encryptionProtocol;
  final ConciergeAgent agent;
  final List<ChatMessage> messages;
  final List<String> quickPrompts;

  const ConciergeSession({
    required this.sessionId,
    required this.encryptionProtocol,
    required this.agent,
    required this.messages,
    required this.quickPrompts,
  });

  ConciergeSession copyWith({
    String? sessionId,
    String? encryptionProtocol,
    ConciergeAgent? agent,
    List<ChatMessage>? messages,
    List<String>? quickPrompts,
  }) {
    return ConciergeSession(
      sessionId: sessionId ?? this.sessionId,
      encryptionProtocol: encryptionProtocol ?? this.encryptionProtocol,
      agent: agent ?? this.agent,
      messages: messages ?? this.messages,
      quickPrompts: quickPrompts ?? this.quickPrompts,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        encryptionProtocol,
        agent,
        messages,
        quickPrompts,
      ];
}
