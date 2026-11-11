/// System status card widget
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/edith_theme.dart';
import '../dashboard_state.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({
    super.key,
    required this.component,
    this.onTap,
    this.compact = false,
  });

  final ComponentStatus component;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;
    final statusColor = component.status.color;

    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(theme.radius.lg),
            child: Container(
              padding: EdgeInsets.all(
                compact ? theme.spacing.sm : theme.spacing.md,
              ),
              decoration: BoxDecoration(
                color: theme.colors.panel,
                borderRadius: BorderRadius.circular(theme.radius.lg),
                border: Border.all(
                  color: compact
                      ? theme.colors.panelBorder
                      : statusColor.withValues(alpha: 0.3),
                  width: compact ? 1 : 1.5,
                ),
              ),
              child: compact
                  ? _buildCompactLayout(theme, statusColor)
                  : _buildFullLayout(theme, statusColor),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: theme.durations.normal)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildCompactLayout(EdithThemeExtension theme, Color statusColor) {
    return Row(
      children: [
        _buildStatusIndicator(theme, statusColor, size: 32),
        SizedBox(width: theme.spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    component.name,
                    style: theme.typography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: theme.spacing.xs),
                  _buildDataSourceBadge(theme),
                ],
              ),
              if (component.subtitle != null)
                Text(
                  component.subtitle!,
                  style: theme.typography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        _buildStatusBadge(theme, statusColor),
      ],
    );
  }

  Widget _buildFullLayout(EdithThemeExtension theme, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatusIndicator(theme, statusColor),
            SizedBox(width: theme.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          component.name,
                          style: theme.typography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: theme.spacing.sm),
                      _buildDataSourceBadge(theme),
                      if (component.isCritical) ...[
                        SizedBox(width: theme.spacing.sm),
                        _buildCriticalBadge(theme),
                      ],
                    ],
                  ),
                  if (component.subtitle != null) ...[
                    SizedBox(height: theme.spacing.xs),
                    Text(
                      component.subtitle!,
                      style: theme.typography.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            _buildStatusBadge(theme, statusColor),
          ],
        ),
        if (component.details.isNotEmpty) ...[
          SizedBox(height: theme.spacing.md),
          Divider(color: theme.colors.panelBorder),
          SizedBox(height: theme.spacing.sm),
          Wrap(
            spacing: theme.spacing.md,
            runSpacing: theme.spacing.sm,
            children: component.details.entries.map((entry) {
              return _buildDetailChip(theme, entry.key, entry.value);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator(
    EdithThemeExtension theme,
    Color color, {
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(theme.radius.md),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Icon(component.icon, color: color, size: size * 0.5),
    );
  }

  Widget _buildDataSourceBadge(EdithThemeExtension theme) {
    final source = component.dataSource;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: source.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(theme.radius.round),
        border: Border.all(
          color: source.color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(source.icon, size: 10, color: source.color),
          const SizedBox(width: 4),
          Text(
            source.label,
            style: theme.typography.labelSmall.copyWith(color: source.color),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalBadge(EdithThemeExtension theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colors.statusError.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(theme.radius.round),
        border: Border.all(
          color: theme.colors.statusError.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 10, color: theme.colors.statusError),
          const SizedBox(width: 4),
          Text(
            'CRITICAL',
            style: theme.typography.labelSmall.copyWith(
              color: theme.colors.statusError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(EdithThemeExtension theme, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(theme.radius.round),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        component.status.label,
        style: theme.typography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    EdithThemeExtension theme,
    String label,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: EdithSpacing.sm,
        vertical: EdithSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colors.panelElevated,
        borderRadius: BorderRadius.circular(EdithRadius.sm),
        border: Border.all(color: theme.colors.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.typography.labelSmall.copyWith(
              color: theme.colors.textMuted,
            ),
          ),
          Text(
            value,
            style: theme.typography.labelSmall.copyWith(
              color: theme.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid of system status cards
class SystemStatusGrid extends StatelessWidget {
  const SystemStatusGrid({
    super.key,
    required this.components,
    this.onComponentTap,
    this.compact = false,
  });

  final List<ComponentStatus> components;
  final void Function(ComponentStatus)? onComponentTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;
    final width = MediaQuery.sizeOf(context).width;

    // Determine cross axis count based on width
    int crossAxisCount;
    if (width < 400) {
      crossAxisCount = 1;
    } else if (width < 600) {
      crossAxisCount = 1;
    } else if (width < 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    if (compact) {
      // Horizontal list for compact mode
      return SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: components.length,
          separatorBuilder: (_, __) => SizedBox(width: theme.spacing.sm),
          itemBuilder: (context, index) {
            final component = components[index];
            return SizedBox(
              width: 280,
              child: SystemStatusCard(
                component: component,
                onTap: () => onComponentTap?.call(component),
                compact: true,
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
        childAspectRatio: compact ? 2.5 : 1.3,
        crossAxisSpacing: theme.spacing.md,
        mainAxisSpacing: theme.spacing.md,
      ),
      itemCount: components.length,
      itemBuilder: (context, index) {
        final component = components[index];
        return SystemStatusCard(
          component: component,
          onTap: () => onComponentTap?.call(component),
          compact: compact,
        );
      },
    );
  }
}
