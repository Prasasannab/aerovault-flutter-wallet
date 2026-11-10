import 'package:equatable/equatable.dart';

abstract class ConciergeEvent extends Equatable {
  const ConciergeEvent();

  @override
  List<Object?> get props => [];
}

class LoadConciergeSessionEvent extends ConciergeEvent {
  const LoadConciergeSessionEvent();
}

class SendChatMessageEvent extends ConciergeEvent {
  final String message;

  const SendChatMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetConciergeSessionEvent extends ConciergeEvent {
  const ResetConciergeSessionEvent();
}
