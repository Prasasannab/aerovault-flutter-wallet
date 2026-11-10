import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_concierge_session_use_case.dart';
import '../../domain/usecases/send_concierge_message_use_case.dart';
import 'concierge_event.dart';
import 'concierge_state.dart';

class ConciergeBloc extends Bloc<ConciergeEvent, ConciergeState> {
  final GetConciergeSessionUseCase getConciergeSessionUseCase;
  final SendConciergeMessageUseCase sendConciergeMessageUseCase;

  ConciergeBloc({
    required this.getConciergeSessionUseCase,
    required this.sendConciergeMessageUseCase,
  }) : super(const ConciergeInitial()) {
    on<LoadConciergeSessionEvent>(_onLoadSession);
    on<SendChatMessageEvent>(_onSendMessage);
  }

  Future<void> _onLoadSession(
    LoadConciergeSessionEvent event,
    Emitter<ConciergeState> emit,
  ) async {
    emit(const ConciergeLoading());
    final result = await getConciergeSessionUseCase();
    result.fold(
      onSuccess: (session) => emit(ConciergeLoaded(session: session)),
      onError: (failure) => emit(ConciergeError(failure.message)),
    );
  }

  Future<void> _onSendMessage(
    SendChatMessageEvent event,
    Emitter<ConciergeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConciergeLoaded) {
      emit(currentState.copyWith(isAgentTyping: true));

      final result = await sendConciergeMessageUseCase(event.message);
      result.fold(
        onSuccess: (updatedSession) => emit(
          ConciergeLoaded(session: updatedSession, isAgentTyping: false),
        ),
        onError: (failure) => emit(ConciergeError(failure.message)),
      );
    }
  }
}
