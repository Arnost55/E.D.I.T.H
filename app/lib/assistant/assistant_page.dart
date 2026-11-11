import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets/chat_message.dart';
import 'widgets/message_input.dart';
import 'providers/assistant_providers.dart';
import '../../core/theme/edith_theme.dart';

class AssistantPage extends ConsumerWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider);
    final engineStatus = ref.watch(aiEngineStatusProvider);

    return Scaffold(
      backgroundColor: EdithColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(engineStatus),
            // Chat messages
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return ChatMessageWidget(
                    message: message,
                    showProvider: true,
                  );
                },
              ),
            ),
            // Message input
            const MessageInputWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AIEngineStatus engineStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: EdithColors.panel,
        border: Border(
          bottom: BorderSide(
            color: EdithColors.panelBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // E.D.I.T.H. logo/title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: EdithColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: EdithColors.accent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: EdithColors.accentStrong,
                ),
                const SizedBox(width: 8),
                Text(
                  'E.D.I.T.H.',
                  style: EdithTypography.headlineSmall.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: EdithColors.accentStrong,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Connection status
          _buildStatusIndicator(engineStatus),
          const SizedBox(width: 16),
          // Latency indicator
          if (engineStatus.latencyMs > 0) _buildLatencyIndicator(engineStatus),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(AIEngineStatus status) {
    final isConnected = status.isConnected;
    final isProcessing = status.isProcessing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected
            ? EdithColors.statusLive.withValues(alpha: 0.1)
            : EdithColors.statusWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? EdithColors.statusLive.withValues(alpha: 0.3)
              : EdithColors.statusWarning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isProcessing
                  ? EdithColors.accent
                  : (isConnected ? EdithColors.statusLive : EdithColors.statusWarning),
              boxShadow: isConnected
                  ? [
                      BoxShadow(
                        color: (isProcessing ? EdithColors.accent : EdithColors.statusLive)
                            .withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isProcessing
                ? 'PROCESSING'
                : (isConnected ? 'CONNECTED' : 'OFFLINE'),
            style: EdithTypography.bodySmall.copyWith(
              color: isProcessing
                  ? EdithColors.accentStrong
                  : (isConnected ? EdithColors.statusLive : EdithColors.statusWarning),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate(
      target: isProcessing ? 1 : 0,
    ).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: 1000.ms,
    );
  }

  Widget _buildLatencyIndicator(AIEngineStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: EdithColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EdithColors.panelBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.speed_rounded,
            size: 14,
            color: EdithColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            '${status.latencyMs}ms',
            style: EdithTypography.bodySmall.copyWith(
              color: EdithColors.textSecondary,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '· ${status.tokensPerSecond.toStringAsFixed(1)} tok/s',
            style: EdithTypography.bodySmall.copyWith(
              color: EdithColors.textMuted,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}