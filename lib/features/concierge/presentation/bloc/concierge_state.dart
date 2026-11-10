import 'package:equatable/equatable.dart';
import '../../domain/entities/concierge_session.dart';

abstract class ConciergeState extends Equatable {
  const ConciergeState();

  @override
  List<Object?> get props => [];
}

class ConciergeInitial extends ConciergeState {
  const ConciergeInitial();
}

class ConciergeLoading extends ConciergeState {
  const ConciergeLoading();
}

class ConciergeLoaded extends ConciergeState {
  final ConciergeSession session;
  final bool isAgentTyping;

  const ConciergeLoaded({
    required this.session,
    this.isAgentTyping = false,
  });

  ConciergeLoaded copyWith({
    ConciergeSession? session,
    bool? isAgentTyping,
  }) {
    return ConciergeLoaded(
      session: session ?? this.session,
      isAgentTyping: isAgentTyping ?? this.isAgentTyping,
    );
  }

  @override
  List<Object?> get props => [session, isAgentTyping];
}

class ConciergeError extends ConciergeState {
  final String message;

  const ConciergeError(this.message);

  @override
  List<Object?> get props => [message];
}
