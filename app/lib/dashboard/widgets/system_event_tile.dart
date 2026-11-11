/// System event tile and list widgets
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/theme/edith_theme.dart';
import '../dashboard_state.dart';

/// Individual system event tile
class SystemEventTile extends StatelessWidget {
  const SystemEventTile({
    super.key,
    required this.event,
    this.onTap,
    this.showComponent = true,
    this.compact = false,
  });

  final SystemEvent event;
  final VoidCallback? onTap;
  final bool showComponent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;
    final eventColor = event.type.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radius.md),
        child: Container(
          padding: EdgeInsets.all(compact ? theme.spacing.sm : theme.spacing.md),
          decoration: BoxDecoration(
            color: theme.colors.panel,
            borderRadius: BorderRadius.circular(theme.radius.md),
            border: Border.all(
              color: eventColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: compact ? _buildCompactLayout(theme, eventColor) : _buildFullLayout(theme, eventColor),
        ),
      ),
    ).animate().fadeIn(duration: theme.durations.fast).slideX(begin: -0.1, end: 0);
  }

  Widget _buildCompactLayout(EdithThemeExtension theme, Color eventColor) {
    return Row(
      children: [
        _buildEventIcon(theme, eventColor, size: 32),
        SizedBox(width: theme.spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: theme.typography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildTimestamp(theme),
                ],
              ),
              SizedBox(height: theme.spacing.xs),
              Row(
                children: [
                  if (showComponent && event.component != null) ...[
                    _buildComponentChip(theme),
                    SizedBox(width: theme.spacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      event.message,
                      style: theme.typography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildEventTypeBadge(theme, eventColor),
      ],
    );
  }

  Widget _buildFullLayout(EdithThemeExtension theme, Color eventColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventIcon(theme, eventColor),
            SizedBox(width: theme.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.typography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildTimestamp(theme),
                    ],
                  ),
                  SizedBox(height: theme.spacing.xs),
                  Row(
                    children: [
                      _buildEventTypeBadge(theme, eventColor),
                      if (showComponent && event.component != null) ...[
                        SizedBox(width: theme.spacing.sm),
                        _buildComponentChip(theme),
                      ],
                    ],
                  ),
                  SizedBox(height: theme.spacing.sm),
                  Text(
                    event.message,
                    style: theme.typography.bodyMedium,
                  ),
                  if (event.metadata.isNotEmpty) ...[
                    SizedBox(height: theme.spacing.sm),
                    _buildMetadata(theme),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventIcon(EdithThemeExtension theme, Color color, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(theme.radius.md),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Icon(
        event.type.icon,
        color: color,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildTimestamp(EdithThemeExtension theme) {
    final now = DateTime.now();
    final diff = now.difference(event.timestamp);
    String timeStr;

    if (diff.inMinutes < 1) {
      timeStr = 'Just now';
    } else if (diff.inHours < 1) {
      timeStr = '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      timeStr = '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      timeStr = '${diff.inDays}d ago';
    } else {
      timeStr = DateFormat('MMM d, yyyy').format(event.timestamp);
    }

    return Text(
      timeStr,
      style: theme.typography.labelSmall.copyWith(
        color: theme.colors.textMuted,
      ),
    );
  }

  Widget _buildEventTypeBadge(EdithThemeExtension theme, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(theme.radius.round),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        event.type.label,
        style: theme.typography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildComponentChip(EdithThemeExtension theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colors.panelElevated,
        borderRadius: BorderRadius.circular(theme.radius.round),
        border: Border.all(color: theme.colors.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.layers_outlined,
            size: 10,
            color: theme.colors.textMuted,
          ),
          SizedBox(width: theme.spacing.xs),
          Text(
            event.component!,
            style: theme.typography.labelSmall.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(EdithThemeExtension theme) {
    return Wrap(
      spacing: theme.spacing.sm,
      runSpacing: theme.spacing.xs,
      children: event.metadata.entries.map((entry) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: theme.spacing.sm, vertical: theme.spacing.xs),
          decoration: BoxDecoration(
            color: theme.colors.panelElevated,
            borderRadius: BorderRadius.circular(theme.radius.sm),
            border: Border.all(color: theme.colors.panelBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${entry.key}: ',
                style: theme.typography.labelSmall.copyWith(
                  color: theme.colors.textMuted,
                ),
              ),
              Text(
                entry.value.toString(),
                style: theme.typography.labelSmall.copyWith(
                  color: theme.colors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Flat list of system events
class SystemEventList extends StatelessWidget {
  const SystemEventList({
    super.key,
    required this.events,
    this.onEventTap,
    this.filter,
    this.maxItems,
    this.compact = false,
    this.showHeader = true,
  });

  final List<SystemEvent> events;
  final void Function(SystemEvent)? onEventTap;
  final SystemEventType? filter;
  final int? maxItems;
  final bool compact;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;
    final filteredEvents = filter != null
        ? events.where((e) => e.type == filter).toList()
        : events;

    final displayEvents = maxItems != null
        ? filteredEvents.take(maxItems!).toList()
        : filteredEvents;

    if (displayEvents.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Events',
                style: theme.typography.titleMedium,
              ),
              if (filter != null)
                Text(
                  '${displayEvents.length} ${filter!.label} events',
                  style: theme.typography.bodySmall.copyWith(
                    color: theme.colors.textMuted,
                  ),
                ),
            ],
          ),
          SizedBox(height: theme.spacing.md),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayEvents.length,
          separatorBuilder: (_, __) => SizedBox(height: theme.spacing.sm),
          itemBuilder: (context, index) {
            final event = displayEvents[index];
            return SystemEventTile(
              event: event,
              onTap: () => onEventTap?.call(event),
              compact: compact,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(EdithThemeExtension theme) {
    return Container(
      padding: EdgeInsets.all(theme.spacing.xl),
      decoration: BoxDecoration(
        color: theme.colors.panel,
        borderRadius: BorderRadius.circular(theme.radius.lg),
        border: Border.all(color: theme.colors.panelBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 48,
            color: theme.colors.textMuted,
          ),
          SizedBox(height: theme.spacing.md),
          Text(
            filter != null
                ? 'No ${filter!.label.toLowerCase()} events'
                : 'No system events',
            style: theme.typography.titleSmall.copyWith(
              color: theme.colors.textMuted,
            ),
          ),
          SizedBox(height: theme.spacing.sm),
          Text(
            'Events will appear here as the system runs',
            style: theme.typography.bodySmall.copyWith(
              color: theme.colors.textDisabled,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Grouped event list (grouped by date)
class GroupedSystemEventList extends StatelessWidget {
  const GroupedSystemEventList({
    super.key,
    required this.events,
    this.onEventTap,
    this.filter,
    this.compact = false,
  });

  final List<SystemEvent> events;
  final void Function(SystemEvent)? onEventTap;
  final SystemEventType? filter;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;
    final filteredEvents = filter != null
        ? events.where((e) => e.type == filter).toList()
        : events;

    if (filteredEvents.isEmpty) {
      return SystemEventList(
        events: events,
        filter: filter,
        compact: compact,
        showHeader: false,
      );
    }

    // Group by date
    final groups = <String, List<SystemEvent>>{};
    for (final event in filteredEvents) {
      final dateKey = _getDateKey(event.timestamp);
      groups.putIfAbsent(dateKey, () => []).add(event);
    }

    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Events',
          style: theme.typography.titleMedium,
        ),
        SizedBox(height: theme.spacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedKeys.length,
          separatorBuilder: (_, __) => SizedBox(height: theme.spacing.lg),
          itemBuilder: (context, index) {
            final dateKey = sortedKeys[index];
            final groupEvents = groups[dateKey]!;
            return _buildEventGroup(context, theme, dateKey, groupEvents);
          },
        ),
      ],
    );
  }

  String _getDateKey(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final diff = today.difference(eventDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return 'Last 7 days';
    return DateFormat('MMMM d, yyyy').format(timestamp);
  }

  Widget _buildEventGroup(
    BuildContext context,
    EdithThemeExtension theme,
    String dateKey,
    List<SystemEvent> groupEvents,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: theme.spacing.sm, bottom: theme.spacing.sm),
          child: Text(
            dateKey,
            style: theme.typography.titleSmall.copyWith(
              color: theme.colors.accentMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupEvents.length,
          separatorBuilder: (_, __) => SizedBox(height: theme.spacing.sm),
          itemBuilder: (context, index) {
            final event = groupEvents[index];
            return SystemEventTile(
              event: event,
              onTap: () => onEventTap?.call(event),
              compact: compact,
            );
          },
        ),
      ],
    );
  }
}

/// Filter chips for event types
class EventFilterChips extends StatelessWidget {
  const EventFilterChips({
    super.key,
    required this.events,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.showAll = true,
  });

  final List<SystemEvent> events;
  final SystemEventType? selectedFilter;
  final void Function(SystemEventType?) onFilterChanged;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;
    final types = SystemEventType.values;

    final chips = <Widget>[];

    if (showAll) {
      final allCount = events.length;
      chips.add(_buildFilterChip(
        theme,
        'All',
        Icons.event_outlined,
        theme.colors.accent,
        allCount,
        selectedFilter == null,
        () => onFilterChanged(null),
      ));
    }

    for (final type in types) {
      final count = events.where((e) => e.type == type).length;
      if (count == 0) continue;

      chips.add(_buildFilterChip(
        theme,
        type.label,
        type.icon,
        type.color,
        count,
        selectedFilter == type,
        () => onFilterChanged(type),
      ));
    }

    return Wrap(
      spacing: theme.spacing.sm,
      runSpacing: theme.spacing.sm,
      children: chips,
    );
  }

  Widget _buildFilterChip(
    EdithThemeExtension theme,
    String label,
    IconData icon,
    Color color,
    int count,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radius.round),
        child: AnimatedContainer(
          duration: EdithDurations.fast,
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : theme.colors.panelElevated,
            borderRadius: BorderRadius.circular(theme.radius.round),
            border: Border.all(
              color: isSelected ? color : theme.colors.panelBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? color : theme.colors.textMuted,
              ),
              SizedBox(width: theme.spacing.xs),
              Text(
                label,
                style: theme.typography.labelMedium.copyWith(
                  color: isSelected ? color : theme.colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              SizedBox(width: theme.spacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.3)
                      : theme.colors.panelBorder.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(theme.radius.round),
                ),
                child: Text(
                  count.toString(),
                  style: theme.typography.labelSmall.copyWith(
                    color: isSelected ? color : theme.colors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Event summary card showing counts by type
class EventSummaryCard extends StatelessWidget {
  const EventSummaryCard({
    super.key,
    required this.events,
    this.onTypeTap,
  });

  final List<SystemEvent> events;
  final void Function(SystemEventType)? onTypeTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;

    final counts = <SystemEventType, int>{};
    for (final type in SystemEventType.values) {
      counts[type] = events.where((e) => e.type == type).length;
    }

    return Container(
      padding: EdgeInsets.all(theme.spacing.md),
      decoration: BoxDecoration(
        color: theme.colors.panel,
        borderRadius: BorderRadius.circular(theme.radius.lg),
        border: Border.all(color: theme.colors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Summary',
            style: theme.typography.titleSmall,
          ),
          SizedBox(height: theme.spacing.md),
          Wrap(
            spacing: theme.spacing.md,
            runSpacing: theme.spacing.sm,
            children: SystemEventType.values.map((type) {
              final count = counts[type] ?? 0;
              if (count == 0) return const SizedBox.shrink();

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTypeTap?.call(type),
                  borderRadius: BorderRadius.circular(theme.radius.md),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacing.md,
                      vertical: theme.spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(theme.radius.md),
                      border: Border.all(color: type.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type.icon, size: 16, color: type.color),
                        SizedBox(width: theme.spacing.xs),
                        Text(
                          '${type.label}: $count',
                          style: theme.typography.labelMedium.copyWith(
                            color: type.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}