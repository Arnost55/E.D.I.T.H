/// Quick action button widgets
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/edith_theme.dart';
import '../dashboard_state.dart';

/// Individual quick action button
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.action,
    this.onTap,
    this.expanded = false,
  });

  final QuickAction action;
  final VoidCallback? onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;
    final color = action.color ?? theme.colors.accentStrong;
    final isEnabled = action.isEnabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? (onTap ?? action.onTap) : null,
        borderRadius: BorderRadius.circular(theme.radius.md),
        child: Container(
          constraints: BoxConstraints(
            minHeight: theme.touchTarget.min,
            minWidth: expanded ? double.infinity : theme.touchTarget.min,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? theme.spacing.lg : theme.spacing.md,
            vertical: theme.spacing.md,
          ),
          decoration: BoxDecoration(
            color: isEnabled
                ? color.withValues(alpha: 0.15)
                : theme.colors.panelBorder.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(theme.radius.md),
            border: Border.all(
              color: isEnabled
                  ? color.withValues(alpha: 0.5)
                  : theme.colors.panelBorder.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: expanded
              ? _buildExpandedLayout(theme, color, isEnabled)
              : _buildCompactLayout(theme, color, isEnabled),
        ),
      ),
    ).animate().fadeIn(duration: theme.durations.normal).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCompactLayout(EdithThemeExtension theme, Color color, bool isEnabled) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              action.icon,
              color: isEnabled ? color : theme.colors.textDisabled,
              size: 28,
            ),
            if (action.badge != null)
              Positioned(
                right: -6,
                top: -6,
                child: _buildBadge(theme),
              ),
          ],
        ),
        SizedBox(height: theme.spacing.xs),
        Text(
          action.label,
          style: theme.typography.labelSmall.copyWith(
            color: isEnabled ? theme.colors.textPrimary : theme.colors.textDisabled,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildExpandedLayout(EdithThemeExtension theme, Color color, bool isEnabled) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          action.icon,
          color: isEnabled ? color : theme.colors.textDisabled,
          size: 24,
        ),
        SizedBox(width: theme.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action.label,
                style: theme.typography.titleSmall.copyWith(
                  color: isEnabled ? theme.colors.textPrimary : theme.colors.textDisabled,
                ),
              ),
              if (action.requiresConfirmation) ...[
                SizedBox(height: theme.spacing.xs),
                Text(
                  'Requires confirmation',
                  style: theme.typography.labelSmall.copyWith(
                    color: theme.colors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action.badge != null) _buildBadge(theme),
        if (action.requiresConfirmation) ...[
          SizedBox(width: theme.spacing.sm),
          Icon(
            Icons.help_outline,
            color: theme.colors.textMuted,
            size: 20,
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(EdithThemeExtension theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colors.accentStrong.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(theme.radius.round),
        border: Border.all(color: theme.colors.accentStrong.withValues(alpha: 0.5)),
      ),
      child: Text(
        action.badge!,
        style: theme.typography.labelSmall.copyWith(
          color: theme.colors.accentStrong,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Grid of quick action buttons
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.actions,
    this.onActionTap,
    this.crossAxisCount = 3,
    this.compact = false,
  });

  final List<QuickAction> actions;
  final void Function(QuickAction)? onActionTap;
  final int crossAxisCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;

    if (compact) {
      return SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: actions.length,
          separatorBuilder: (_, __) => SizedBox(width: theme.spacing.sm),
          itemBuilder: (context, index) {
            final action = actions[index];
            return SizedBox(
              width: 120,
              child: QuickActionButton(
                action: action,
                onTap: () => _handleTap(action),
              ),
            );
          },
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.1,
        crossAxisSpacing: theme.spacing.md,
        mainAxisSpacing: theme.spacing.md,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return QuickActionButton(
          action: action,
          onTap: () => _handleTap(action),
        );
      },
    );
  }

  void _handleTap(QuickAction action) {
    if (action.requiresConfirmation && action.confirmationMessage != null) {
      // This would show a confirmation dialog in a real implementation
      onActionTap?.call(action);
    } else {
      onActionTap?.call(action);
    }
  }
}

/// Horizontal bar of quick actions
class QuickActionBar extends StatelessWidget {
  const QuickActionBar({
    super.key,
    required this.actions,
    this.onActionTap,
    this.showBadges = true,
  });

  final List<QuickAction> actions;
  final void Function(QuickAction)? onActionTap;
  final bool showBadges;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.sm),
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: EdgeInsets.only(right: theme.spacing.sm),
            child: QuickActionButton(
              action: action.copyWith(badge: showBadges ? action.badge : null),
              onTap: () => _handleTap(action),
              expanded: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleTap(QuickAction action) {
    if (action.requiresConfirmation && action.confirmationMessage != null) {
      onActionTap?.call(action);
    } else {
      onActionTap?.call(action);
    }
  }
}

/// Quick action section with title
class QuickActionSection extends StatelessWidget {
  const QuickActionSection({
    super.key,
    required this.title,
    required this.actions,
    this.onActionTap,
    this.layout = QuickActionLayout.grid,
    this.crossAxisCount = 3,
  });

  final String title;
  final List<QuickAction> actions;
  final void Function(QuickAction)? onActionTap;
  final QuickActionLayout layout;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typography.titleMedium,
        ),
        SizedBox(height: theme.spacing.md),
        switch (layout) {
          QuickActionLayout.grid => QuickActionGrid(
              actions: actions,
              onActionTap: onActionTap,
              crossAxisCount: crossAxisCount,
            ),
          QuickActionLayout.bar => QuickActionBar(
              actions: actions,
              onActionTap: onActionTap,
            ),
          QuickActionLayout.compactGrid => QuickActionGrid(
              actions: actions,
              onActionTap: onActionTap,
              crossAxisCount: crossAxisCount,
              compact: true,
            ),
        },
      ],
    );
  }
}

enum QuickActionLayout {
  grid,
  bar,
  compactGrid,
}