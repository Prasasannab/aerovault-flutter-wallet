import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/concierge_bloc.dart';
import '../bloc/concierge_event.dart';
import '../bloc/concierge_state.dart';

class ConciergeScreen extends StatefulWidget {
  const ConciergeScreen({super.key});

  static Future<void> navigate(BuildContext context) {
    HapticFeedback.lightImpact();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<ConciergeBloc>(
          create: (_) => sl<ConciergeBloc>()..add(const LoadConciergeSessionEvent()),
          child: const ConciergeScreen(),
        ),
      ),
    );
  }

  @override
  State<ConciergeScreen> createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends State<ConciergeScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _textController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    context.read<ConciergeBloc>().add(SendChatMessageEvent(text));
    if (customText == null) {
      _textController.clear();
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors),
      body: BlocConsumer<ConciergeBloc, ConciergeState>(
        listener: (context, state) {
          if (state is ConciergeLoaded) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is ConciergeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.emerald),
            );
          }

          if (state is ConciergeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_clock_outlined, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium(color: colors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    BounceButton(
                      onTap: () => context.read<ConciergeBloc>().add(const LoadConciergeSessionEvent()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Reconnect E2EE Node',
                          style: AppTextStyles.label(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ConciergeLoaded) {
            return _buildChatBody(context, colors, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AeroVaultColors colors) {
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
      title: Row(
        children: [
          // Banker Avatar with Online Indicator
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.emerald, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.emeraldGlow,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/sample_avatar.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: colors.surfaceElevated,
                      child: const Center(
                        child: Text('CD', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Claire Delacroix',
                      style: AppTextStyles.heading3(color: colors.textPrimary).copyWith(fontSize: 14.5),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: AppColors.emerald, size: 14),
                  ],
                ),
                Text(
                  'Geneva Private Wealth • < 1 min SLA',
                  style: AppTextStyles.label(color: AppColors.emerald, fontSize: 8.5),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shield_outlined, color: AppColors.emerald, size: 20),
          tooltip: 'E2EE Session Details',
          onPressed: () => _showEncryptionDetailsDialog(context),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: colors.border, height: 1),
      ),
    );
  }

  Widget _buildChatBody(
    BuildContext context,
    AeroVaultColors colors,
    ConciergeLoaded state,
  ) {
    final session = state.session;

    return Column(
      children: [
        // 1. Encryption Banner
        _buildEncryptionBanner(colors, session.encryptionProtocol),

        // 2. Message History
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: session.messages.length + (state.isAgentTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < session.messages.length) {
                final message = session.messages[index];
                return _buildMessageItem(context, colors, message);
              }
              // Typing indicator
              return _buildTypingIndicator(colors);
            },
          ),
        ),

        // 3. Quick Action Prompts Bar
        _buildQuickPromptsBar(colors, session.quickPrompts),

        // 4. Chat Input Bar
        _buildInputBar(colors),
      ],
    );
  }

  Widget _buildEncryptionBanner(AeroVaultColors colors, String protocol) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.6),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 12, color: AppColors.emerald),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$protocol • Swiss Banking Act Art. 47 Secrecy Protected',
              style: AppTextStyles.label(color: colors.textMuted, fontSize: 8.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    AeroVaultColors colors,
    ChatMessage message,
  ) {
    if (message.sender == MessageSender.system) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.security_rounded, size: 14, color: AppColors.emerald),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.text,
                style: AppTextStyles.bodySmall(color: colors.textMuted).copyWith(fontSize: 10.5),
              ),
            ),
          ],
        ),
      );
    }

    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceElevated,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/sample_avatar.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.person, size: 16, color: AppColors.emerald),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.emerald.withValues(alpha: 0.15)
                    : colors.surfaceElevated,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.emerald.withValues(alpha: 0.4)
                      : colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppTextStyles.bodyMedium(color: colors.textPrimary).copyWith(fontSize: 13.5),
                  ),
                  if (message.attachmentName != null) ...[
                    const SizedBox(height: 10),
                    _buildAttachmentCard(context, colors, message.attachmentName!, message.attachmentType ?? 'PDF'),
                  ],
                  if (message.actionPrompts != null && message.actionPrompts!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.actionPrompts!.map((prompt) {
                        return BounceButton(
                          onTap: () => _sendMessage(prompt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded, size: 12, color: AppColors.emerald),
                                const SizedBox(width: 4),
                                Text(
                                  prompt,
                                  style: AppTextStyles.label(color: AppColors.emerald, fontSize: 9.5),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timestampFormatted,
                        style: AppTextStyles.label(color: colors.textMuted, fontSize: 8.5),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all_rounded, size: 13, color: AppColors.emerald),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(
    BuildContext context,
    AeroVaultColors colors,
    String fileName,
    String type,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.emeraldGlow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.emerald, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.bodySmall(color: colors.textPrimary).copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'FINMA Sealed • 2.4 MB PDF',
                  style: AppTextStyles.label(color: colors.textMuted, fontSize: 8.5),
                ),
              ],
            ),
          ),
          BounceButton(
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: colors.surfaceElevated,
                  behavior: SnackBarBehavior.floating,
                  content: Row(
                    children: [
                      const Icon(Icons.download_done_rounded, color: AppColors.emerald, size: 18),
                      const SizedBox(width: 8),
                      Text('Downloaded $fileName', style: AppTextStyles.bodySmall(color: colors.textPrimary)),
                    ],
                  ),
                ),
              );
            },
            child: const Icon(Icons.download_rounded, color: AppColors.emerald, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(AeroVaultColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceElevated,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/sample_avatar.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.person, size: 16, color: AppColors.emerald),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Claire Delacroix is typing',
                  style: AppTextStyles.bodySmall(color: colors.textMuted).copyWith(fontSize: 11),
                ),
                const SizedBox(width: 6),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.emerald),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPromptsBar(AeroVaultColors colors, List<String> prompts) {
    if (prompts.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return BounceButton(
            onTap: () => _sendMessage(prompt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.electric_bolt_rounded, size: 12, color: AppColors.emerald),
                  const SizedBox(width: 6),
                  Text(
                    prompt,
                    style: AppTextStyles.label(color: colors.textPrimary, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(AeroVaultColors colors) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          // Attachment Button
          BounceButton(
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: colors.surfaceElevated,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Attach Origin of Wealth Statement / Passport Document',
                    style: AppTextStyles.bodySmall(color: colors.textPrimary),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Icon(Icons.attach_file_rounded, size: 18, color: colors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),

          // Text Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: AppTextStyles.bodyMedium(color: colors.textPrimary),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Instruction to Private Wealth Desk...',
                  hintStyle: AppTextStyles.bodySmall(color: colors.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send Button
          BounceButton(
            onTap: () => _sendMessage(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.emerald,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.emeraldGlow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_upward_rounded, size: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showEncryptionDetailsDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border),
        ),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.emerald),
            const SizedBox(width: 8),
            Text('E2EE Banking Security', style: AppTextStyles.heading3(color: colors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This conversation is secured via Signal Double Ratchet protocol with AES-256-GCM symmetric session keys held inside hardware Secure Enclave.',
              style: AppTextStyles.bodySmall(color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              '• Node: Geneva Private Banking Core #07\n• Protocol: E2EE Ratchet Ephemeral Keys\n• Secrecy: Swiss Federal Banking Act Art. 47\n• Guaranteed Concierge SLA: < 60 seconds',
              style: AppTextStyles.monospace(color: AppColors.emerald, fontSize: 10.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgContext),
            child: Text('Understood', style: AppTextStyles.label(color: AppColors.emerald, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
