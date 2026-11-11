import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../providers/assistant_providers.dart';
import '../../core/theme/edith_theme.dart';

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    super.key,
    required this.message,
    this.showProvider = false,
  });

  final ChatMessage message;
  final bool showProvider;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final timeFormat = DateFormat.Hms();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(false),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showProvider && message.provider != null)
                  _buildProviderBadge(message.provider!),
                if (showProvider && message.provider != null)
                  const SizedBox(height: 4),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? EdithColors.accent.withValues(alpha: 0.15)
                        : EdithColors.panel,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: Border.all(
                      color: isUser
                          ? EdithColors.accent.withValues(alpha: 0.3)
                          : EdithColors.borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: EdithColors.glowColor.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SelectableText(
                    message.content,
                    style: EdithTypography.bodyStyle.copyWith(
                      color: isUser ? EdithColors.accentStrong : EdithColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeFormat.format(message.timestamp),
                      style: EdithTypography.captionStyle.copyWith(
                        color: EdithColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    if (message.latencyMs != null && message.tokensUsed != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: EdithColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${message.latencyMs}ms · ${message.tokensUsed} tok',
                          style: EdithTypography.captionStyle.copyWith(
                            color: EdithColors.accent,
                            fontSize: 9,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            _buildAvatar(true),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUser
            ? LinearGradient(
                colors: [EdithColors.accent, EdithColors.accentStrong],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [EdithColors.panel, EdithColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isUser ? EdithColors.accentStrong : EdithColors.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUser ? EdithColors.accent : EdithColors.glowColor).withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person_outline : Icons.auto_awesome_outlined,
          size: 18,
          color: isUser ? EdithColors.bgPrimary : EdithColors.accentStrong,
        ),
      ),
    );
  }

  Widget _buildProviderBadge(AIProviderType provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: EdithColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EdithColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getProviderIcon(provider),
            size: 10,
            color: EdithColors.accent,
          ),
          const SizedBox(width: 4),
          Text(
            provider.displayName,
            style: EdithTypography.captionStyle.copyWith(
              color: EdithColors.accent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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