import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aerovault/core/errors/failures.dart';
import 'package:aerovault/core/utils/result.dart';
import 'package:aerovault/features/concierge/domain/entities/chat_message.dart';
import 'package:aerovault/features/concierge/domain/entities/concierge_agent.dart';
import 'package:aerovault/features/concierge/domain/entities/concierge_session.dart';
import 'package:aerovault/features/concierge/domain/usecases/get_concierge_session_use_case.dart';
import 'package:aerovault/features/concierge/domain/usecases/send_concierge_message_use_case.dart';
import 'package:aerovault/features/concierge/presentation/bloc/concierge_bloc.dart';
import 'package:aerovault/features/concierge/presentation/bloc/concierge_event.dart';
import 'package:aerovault/features/concierge/presentation/bloc/concierge_state.dart';

class MockGetConciergeSessionUseCase extends Mock implements GetConciergeSessionUseCase {}
class MockSendConciergeMessageUseCase extends Mock implements SendConciergeMessageUseCase {}

void main() {
  late ConciergeBloc conciergeBloc;
  late MockGetConciergeSessionUseCase mockGetConciergeSessionUseCase;
  late MockSendConciergeMessageUseCase mockSendConciergeMessageUseCase;

  const testAgent = ConciergeAgent(
    id: 'AGENT-1',
    name: 'Claire Delacroix',
    title: 'Senior Wealth Executive',
    location: 'Geneva (CH)',
    avatarUrl: 'assets/images/sample_avatar.jpg',
    isOnline: true,
    responseTimeSla: '< 1 min',
  );

  const testSession = ConciergeSession(
    sessionId: 'SES-1',
    encryptionProtocol: 'AES-256-GCM',
    agent: testAgent,
    messages: [
      ChatMessage(
        id: 'M1',
        sender: MessageSender.agent,
        text: 'Welcome to Geneva Wealth Concierge.',
        timestampFormatted: '12:00 PM',
      ),
    ],
    quickPrompts: ['Request Limit Increase', 'Order Card'],
  );

  setUp(() {
    mockGetConciergeSessionUseCase = MockGetConciergeSessionUseCase();
    mockSendConciergeMessageUseCase = MockSendConciergeMessageUseCase();

    conciergeBloc = ConciergeBloc(
      getConciergeSessionUseCase: mockGetConciergeSessionUseCase,
      sendConciergeMessageUseCase: mockSendConciergeMessageUseCase,
    );
  });

  tearDown(() {
    conciergeBloc.close();
  });

  test('initial state is ConciergeInitial', () {
    expect(conciergeBloc.state, const ConciergeInitial());
  });

  group('ConciergeBloc - LoadConciergeSessionEvent', () {
    blocTest<ConciergeBloc, ConciergeState>(
      'emits [ConciergeLoading, ConciergeLoaded] when session is loaded successfully',
      build: () {
        when(() => mockGetConciergeSessionUseCase())
            .thenAnswer((_) async => Result.success(testSession));
        return conciergeBloc;
      },
      act: (bloc) => bloc.add(const LoadConciergeSessionEvent()),
      expect: () => [
        const ConciergeLoading(),
        const ConciergeLoaded(session: testSession),
      ],
      verify: (_) {
        verify(() => mockGetConciergeSessionUseCase()).called(1);
      },
    );

    blocTest<ConciergeBloc, ConciergeState>(
      'emits [ConciergeLoading, ConciergeError] when session retrieval fails',
      build: () {
        when(() => mockGetConciergeSessionUseCase())
            .thenAnswer((_) async => Result.error(const ServerFailure(message: 'Connection failed')));
        return conciergeBloc;
      },
      act: (bloc) => bloc.add(const LoadConciergeSessionEvent()),
      expect: () => [
        const ConciergeLoading(),
        const ConciergeError('Connection failed'),
      ],
    );
  });

  group('ConciergeBloc - SendChatMessageEvent', () {
    final updatedSession = testSession.copyWith(
      messages: [
        ...testSession.messages,
        const ChatMessage(
          id: 'M2',
          sender: MessageSender.user,
          text: 'Request limit increase',
          timestampFormatted: '12:01 PM',
        ),
      ],
    );

    blocTest<ConciergeBloc, ConciergeState>(
      'emits typing state then updated session with reply',
      build: () {
        when(() => mockSendConciergeMessageUseCase('Request limit increase'))
            .thenAnswer((_) async => Result.success(updatedSession));
        return conciergeBloc;
      },
      seed: () => const ConciergeLoaded(session: testSession),
      act: (bloc) => bloc.add(const SendChatMessageEvent('Request limit increase')),
      expect: () => [
        const ConciergeLoaded(session: testSession, isAgentTyping: true),
        ConciergeLoaded(session: updatedSession, isAgentTyping: false),
      ],
    );
  });
}
