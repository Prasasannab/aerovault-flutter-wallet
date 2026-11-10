import 'dart:async';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';
import '../models/concierge_agent_model.dart';
import '../models/concierge_session_model.dart';

abstract class ConciergeDataSource {
  Future<ConciergeSessionModel> getSession();
  Future<ConciergeSessionModel> sendMessage(String text);
  Future<ConciergeSessionModel> resetSession();
}

class ConciergeLocalDataSourceImpl implements ConciergeDataSource {
  ConciergeSessionModel? _session;

  ConciergeSessionModel _buildInitialSession() {
    final now = DateTime.now();
    final timeFormat = DateFormat('h:mm a');

    const agent = ConciergeAgentModel(
      id: 'AGENT-GENEVA-07',
      name: 'Claire Delacroix',
      title: 'Senior Private Wealth Executive',
      location: 'Geneva Headquarters (CH)',
      avatarUrl: 'assets/images/sample_avatar.jpg',
      isOnline: true,
      responseTimeSla: '< 1 min • Centurion Priority',
    );

    final initialMessages = [
      ChatMessageModel(
        id: 'MSG-001',
        sender: MessageSender.system,
        text: 'Session authenticated via Apple Secure Enclave Level 3 Hardware Root. End-to-end encryption established with Geneva Private Banking Node.',
        timestampFormatted: timeFormat.format(now.subtract(const Duration(minutes: 15))),
      ),
      ChatMessageModel(
        id: 'MSG-002',
        sender: MessageSender.agent,
        text: 'Good afternoon, Mr. Gayashan. I am Claire Delacroix, your dedicated Swiss Private Wealth Concierge. Your \$246,553.33 portfolio and Tier 3 clearing lines are active and audited. How may I assist your treasury or international settlements today?',
        timestampFormatted: timeFormat.format(now.subtract(const Duration(minutes: 14))),
        actionPrompts: const [
          'Request \$1,000,000 Outbound Wire Headroom',
          'Order Bespoke Obsidian Titanium Card',
          'Query Institutional Staking Yields',
        ],
      ),
      ChatMessageModel(
        id: 'MSG-003',
        sender: MessageSender.user,
        text: 'Could you confirm the status of our upcoming Swiss interbank transfer line?',
        timestampFormatted: timeFormat.format(now.subtract(const Duration(minutes: 8))),
        deliveryStatus: MessageDeliveryStatus.read,
      ),
      ChatMessageModel(
        id: 'MSG-004',
        sender: MessageSender.agent,
        text: 'Certainly. The SIX Swiss Interbank Clearing (SIC) and Fedwire liquidity lines have been pre-cleared by our treasury desk. You can execute transfers up to \$500,000.00 instantly with zero foreign exchange markup.',
        timestampFormatted: timeFormat.format(now.subtract(const Duration(minutes: 6))),
      ),
    ];

    const quickPrompts = [
      'Request \$1,000,000 Outbound Wire Headroom',
      'Order Bespoke Obsidian Titanium Card',
      'Query Institutional Staking Yields',
      'Download Annual FINMA Regulatory Pack',
    ];

    return ConciergeSessionModel(
      sessionId: 'SES-CH-8842-E2EE',
      encryptionProtocol: 'AES-256-GCM • Signal Double Ratchet',
      agent: agent,
      messages: initialMessages,
      quickPrompts: quickPrompts,
    );
  }

  @override
  Future<ConciergeSessionModel> getSession() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    _session ??= _buildInitialSession();
    return _session!;
  }

  @override
  Future<ConciergeSessionModel> sendMessage(String text) async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    _session ??= _buildInitialSession();

    final now = DateTime.now();
    final timeFormat = DateFormat('h:mm a');

    // Add user message
    final userMsg = ChatMessageModel(
      id: 'MSG-USER-${now.millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: text,
      timestampFormatted: timeFormat.format(now),
      deliveryStatus: MessageDeliveryStatus.read,
    );

    // Generate intelligent banker response based on context
    final lower = text.toLowerCase();
    String agentReply;
    String? attachmentName;
    String? attachmentType;

    if (lower.contains('wire') || lower.contains('limit') || lower.contains('headroom') || lower.contains('1,000,000')) {
      agentReply = 'Understood, Mr. Gayashan. I have elevated your daily outbound wire headroom to \$1,000,000.00. The allocation has been signed on the Swiss SIC interbank core and is available immediately.';
    } else if (lower.contains('card') || lower.contains('metal') || lower.contains('titanium')) {
      agentReply = 'Your order for a custom engraved AeroVault Obsidian Metal Card (Physical Titanium) has been placed on priority Swiss diplomatic courier dispatch to your Zurich residence.';
    } else if (lower.contains('staking') || lower.contains('yield') || lower.contains('crypto')) {
      agentReply = 'Our institutional cold vault staking rates are currently yielding 4.5% APY on Ethereum Validator nodes and 3.8% on Bitcoin liquidity reserves, settled daily at 00:00 UTC.';
    } else if (lower.contains('tax') || lower.contains('finma') || lower.contains('statement') || lower.contains('pack')) {
      agentReply = 'I have generated your official FINMA & SBA certified annual regulatory tax pack with digital PwC seal and itemized ledger proof.';
      attachmentName = 'AeroVault_FINMA_Tax_Audit_2026.pdf';
      attachmentType = 'PDF';
    } else {
      agentReply = 'Thank you for your instruction, Mr. Gayashan. Your request has been logged under Geneva Private Wealth priority protocol and is being executed immediately.';
    }

    final agentMsg = ChatMessageModel(
      id: 'MSG-AGENT-${now.millisecondsSinceEpoch + 1}',
      sender: MessageSender.agent,
      text: agentReply,
      timestampFormatted: timeFormat.format(now),
      attachmentName: attachmentName,
      attachmentType: attachmentType,
    );

    final updatedMessages = List<ChatMessageModel>.from(_session!.messages)
      ..add(userMsg)
      ..add(agentMsg);

    _session = ConciergeSessionModel(
      sessionId: _session!.sessionId,
      encryptionProtocol: _session!.encryptionProtocol,
      agent: _session!.agent,
      messages: updatedMessages,
      quickPrompts: _session!.quickPrompts,
    );

    return _session!;
  }

  @override
  Future<ConciergeSessionModel> resetSession() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.simulatedNetworkDelayMs),
    );
    _session = _buildInitialSession();
    return _session!;
  }
}
