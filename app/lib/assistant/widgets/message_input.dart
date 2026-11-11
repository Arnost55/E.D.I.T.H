import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/assistant_providers.dart';
import '../../core/theme/edith_theme.dart';

class MessageInputWidget extends ConsumerStatefulWidget {
  const MessageInputWidget({super.key});

  @override
  ConsumerState<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends ConsumerState<MessageInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
      provider: ref.read(activeAIProviderProvider),
    );

    ref.read(chatMessagesProvider.notifier).addMessage(userMessage);
    _controller.clear();
    _focusNode.requestFocus();

    // Generate AI response
    _generateResponse(userMessage);
  }

  Future<void> _generateResponse(ChatMessage userMessage) async {
    final engineStatus = ref.read(aiEngineStatusProvider.notifier);
    final messagesNotifier = ref.read(chatMessagesProvider.notifier);

    engineStatus.setProcessing(true);
    final loadingId = 'loading_${DateTime.now().millisecondsSinceEpoch}';
    final loadingMessage = ChatMessage(
      id: loadingId,
      role: ChatRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      provider: ref.read(activeAIProviderProvider),
    );
    messagesNotifier.addMessage(loadingMessage);

    try {
      final response = await MockAIProvider.generateMockResponse(userMessage);

      // Replace the loading message with actual response
      messagesNotifier.replaceMessage(loadingId, response);
    } catch (e) {
      // Handle error - replace loading with error message
      messagesNotifier.replaceMessage(loadingId, ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: ChatRole.assistant,
        content: 'Error: Unable to process request. Please try again.',
        timestamp: DateTime.now(),
        provider: ref.read(activeAIProviderProvider),
      ));
    } finally {
      engineStatus.setProcessing(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final engineStatus = ref.watch(aiEngineStatusProvider);
    final isProcessing = engineStatus.isProcessing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EdithColors.panel,
        border: Border(
          top: BorderSide(
            color: EdithColors.borderColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Provider selector
            _buildProviderSelector(),
            const SizedBox(width: 12),
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: EdithColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isComposing || _controller.text.isNotEmpty
                        ? EdithColors.accent
                        : EdithColors.borderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (_isComposing || _controller.text.isNotEmpty)
                      BoxShadow(
                        color: EdithColors.glowColor.withValues(alpha: 0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: EdithTypography.bodyStyle.copyWith(color: EdithColors.textPrimary),
                  cursorColor: EdithColors.accent,
                  maxLines: null,
                  minLines: 1,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: isProcessing ? 'E.D.I.T.H. is thinking...' : 'Ask E.D.I.T.H. anything...',
                    hintStyle: EdithTypography.bodyStyle.copyWith(
                      color: EdithColors.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    counterStyle: EdithTypography.captionStyle.copyWith(
                      color: EdithColors.textMuted,
                      fontSize: 10,
                    ),
                    suffixIcon: _controller.text.isNotEmpty && !isProcessing
                        ? IconButton(
                            icon: Icon(
                              Icons.send_rounded,
                              color: EdithColors.accentStrong,
                            ),
                            onPressed: _sendMessage,
                            tooltip: 'Send',
                          )
                        : isProcessing
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(EdithColors.accent),
                                  ),
                                ),
                              )
                            : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isComposing = value.isNotEmpty;
                    });
                  },
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !isProcessing,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildProviderSelector() {
    final configs = ref.watch(aiProviderConfigProvider);
    final activeProvider = ref.watch(activeAIProviderProvider);
    final enabledProviders = configs.entries
        .where((e) => e.value.enabled)
        .map((e) => e.key)
        .toList();

    return PopupMenuButton<AIProviderType>(
      initialValue: activeProvider,
      onSelected: (provider) {
        ref.read(aiProviderConfigProvider.notifier).setActiveProvider(provider);
        ref.read(aiEngineStatusProvider.notifier).setActiveProvider(provider);
      },
      itemBuilder: (context) => enabledProviders.map((provider) {
        return PopupMenuItem(
          value: provider,
          child: Row(
            children: [
              Icon(
                _getProviderIcon(provider),
                size: 18,
                color: provider == activeProvider
                    ? EdithColors.accentStrong
                    : EdithColors.textMuted,
              ),
              const SizedBox(width: 12),
              Text(
                provider.displayName,
                style: EdithTypography.bodyStyle.copyWith(
                  color: provider == activeProvider
                      ? EdithColors.accentStrong
                      : EdithColors.textPrimary,
                  fontWeight: provider == activeProvider
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (provider == activeProvider) ...[
                const Spacer(),
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: EdithColors.accentStrong,
                ),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: EdithColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: EdithColors.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getProviderIcon(activeProvider),
              size: 18,
              color: EdithColors.accentStrong,
            ),
            const SizedBox(width: 8),
            Text(
              activeProvider.displayName,
              style: EdithTypography.bodyStyle.copyWith(
                color: EdithColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: EdithColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(AIProviderType type) {
    switch (type) {
      case AIProviderType.mock:
        return Icons.memory_outlined;
      case AIProviderType.openai:
        return Icons.cloud_outlined;
      case AIProviderType.anthropic:
        return Icons.psychology_outlined;
      case AIProviderType.ollama:
        return Icons.computer_outlined;
      case AIProviderType.helpex:
        return Icons.shield_outlined;
    }
  }
}