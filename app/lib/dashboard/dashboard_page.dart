/// Main Dashboard Page
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/edith_theme.dart';
import 'dashboard_state.dart';
import 'providers/dashboard_providers.dart';
import 'widgets/system_status_card.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/simulation_controls.dart';
import 'widgets/system_event_tile.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _fabController;
  SystemEventType? _selectedEventFilter;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabController = AnimationController(
      duration: EdithDurations.normal,
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;
    final dashboardState = ref.watch(dashboardStateProvider);
    final components = ref.watch(componentStatusesProvider);
    final quickActions = ref.watch(quickActionsProvider);
    final simulation = ref.watch(simulationConfigProvider);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(theme, simulation),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSystemOverview(theme, dashboardState, components),
                  SizedBox(height: theme.spacing.xl),
                  _buildQuickActions(theme, quickActions),
                  SizedBox(height: theme.spacing.xl),
                  _buildSimulationControls(theme),
                  SizedBox(height: theme.spacing.xl),
                  _buildEventSection(theme, dashboardState),
                  SizedBox(height: theme.spacing.xxl), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildRefreshFAB(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSliverAppBar(EdithThemeExtension theme, SimulationConfig simulation) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      snap: false,
      backgroundColor: theme.colors.background,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: theme.spacing.md,
          right: theme.spacing.md,
          bottom: theme.spacing.md,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E.D.I.T.H. Dashboard',
                  style: theme.typography.headlineSmall,
                ),
                Text(
                  'System Status Overview',
                  style: theme.typography.bodySmall.copyWith(
                    color: theme.colors.textMuted,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (simulation.enabled)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacing.sm,
                      vertical: theme.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colors.statusWarning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(theme.radius.round),
                      border: Border.all(
                        color: theme.colors.statusWarning.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 12,
                          color: theme.colors.statusWarning,
                        ),
                        SizedBox(width: theme.spacing.xs),
                        Text(
                          'SIM ${simulation.simulationSpeed}x',
                          style: theme.typography.labelSmall.copyWith(
                            color: theme.colors.statusWarning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: theme.spacing.sm),
                _buildLiveIndicator(theme),
              ],
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colors.background,
                theme.colors.background.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveIndicator(EdithThemeExtension theme) {
    return Consumer(
      builder: (context, ref, _) {
        final simulation = ref.watch(simulationConfigProvider);
        final isLive = !simulation.enabled;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.sm,
            vertical: theme.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: isLive
                ? theme.colors.statusLive.withValues(alpha: 0.15)
                : theme.colors.panelBorder.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(theme.radius.round),
            border: Border.all(
              color: isLive
                  ? theme.colors.statusLive.withValues(alpha: 0.5)
                  : theme.colors.panelBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isLive ? theme.colors.statusLive : theme.colors.textMuted,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: EdithDurations.slow)
                  .fadeOut(duration: EdithDurations.slow),
              SizedBox(width: theme.spacing.xs),
              Text(
                isLive ? 'LIVE' : 'OFFLINE',
                style: theme.typography.labelSmall.copyWith(
                  color: isLive ? theme.colors.statusLive : theme.colors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemOverview(
    EdithThemeExtension theme,
    DashboardState state,
    List<ComponentStatus> components,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'System Overview',
              style: theme.typography.titleLarge,
            ),
            Consumer(
              builder: (context, ref, _) {
                return IconButton(
                  onPressed: () => ref.read(dashboardStateProvider.notifier).refresh(),
                  icon: Icon(Icons.refresh, color: theme.colors.accent),
                  tooltip: 'Refresh all data',
                );
              },
            ),
          ],
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Real-time status of all E.D.I.T.H. subsystems',
          style: theme.typography.bodyMedium.copyWith(
            color: theme.colors.textMuted,
          ),
        ),
        SizedBox(height: theme.spacing.lg),
        SystemStatusGrid(
          components: components,
          onComponentTap: (component) => _showComponentDetails(context, component),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    EdithThemeExtension theme,
    List<QuickAction> actions,
  ) {
    return QuickActionSection(
      title: 'Quick Actions',
      actions: actions,
      onActionTap: (action) => _handleQuickAction(context, action),
      layout: QuickActionLayout.grid,
      crossAxisCount: 3,
    );
  }

  Widget _buildSimulationControls(EdithThemeExtension theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Simulation Controls',
          style: theme.typography.titleLarge,
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Configure simulated data for development and testing',
          style: theme.typography.bodyMedium.copyWith(
            color: theme.colors.textMuted,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        const SimulationControls(initiallyExpanded: false),
      ],
    );
  }

  Widget _buildEventSection(
    EdithThemeExtension theme,
    DashboardState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'System Events',
              style: theme.typography.titleLarge,
            ),
            EventFilterChips(
              events: state.events,
              selectedFilter: _selectedEventFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedEventFilter = filter;
                });
              },
              showAll: true,
            ),
          ],
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Recent system activity and notifications',
          style: theme.typography.bodyMedium.copyWith(
            color: theme.colors.textMuted,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        SystemEventList(
          events: state.events,
          filter: _selectedEventFilter,
          maxItems: 20,
          compact: false,
          showHeader: false,
          onEventTap: (event) => _showEventDetails(context, event),
        ),
        if (state.events.length > 20)
          Center(
            child: TextButton(
              onPressed: () => _showAllEvents(context, state.events),
              child: Text(
                'View all ${state.events.length} events',
                style: theme.typography.labelMedium.copyWith(
                  color: theme.colors.accent,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRefreshFAB(EdithThemeExtension theme) {
    return ScaleTransition(
      scale: _fabController,
      child: FloatingActionButton(
        onPressed: () {
          ref.read(dashboardStateProvider.notifier).refresh();
          _scrollController.animateTo(
            0,
            duration: EdithDurations.normal,
            curve: EdithCurves.standard,
          );
        },
        backgroundColor: theme.colors.accentStrong,
        foregroundColor: theme.colors.background,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.radius.round),
        ),
        child: const Icon(Icons.refresh, size: 24),
      ),
    );
  }

  void _handleQuickAction(BuildContext context, QuickAction action) {
    final theme = context.edithTheme;

    if (action.requiresConfirmation && action.confirmationMessage != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colors.panel,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.radius.xl),
            side: BorderSide(color: theme.colors.panelBorder),
          ),
          title: Text('Confirm Action', style: theme.typography.titleMedium),
          content: Text(
            action.confirmationMessage!,
            style: theme.typography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: theme.typography.labelMedium),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                action.onTap();
                _showSnackBar(context, '${action.label} executed');
              },
              child: Text('Confirm', style: theme.typography.labelMedium),
            ),
          ],
        ),
      );
    } else {
      action.onTap();
      _showSnackBar(context, '${action.label} triggered');
    }
  }

  void _showComponentDetails(BuildContext context, ComponentStatus component) {
    final theme = context.edithTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(theme.spacing.lg),
        decoration: BoxDecoration(
          color: theme.colors.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radius.xl)),
          border: Border.all(color: theme.colors.panelBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(theme.spacing.md),
                  decoration: BoxDecoration(
                    color: component.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(theme.radius.md),
                  ),
                  child: Icon(component.icon, color: component.status.color, size: 28),
                ),
                SizedBox(width: theme.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(component.name, style: theme.typography.titleLarge),
                      _buildDataSourceBadge(theme, component.dataSource),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.md,
                    vertical: theme.spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: component.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(theme.radius.round),
                    border: Border.all(color: component.status.color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    component.status.label,
                    style: theme.typography.labelMedium.copyWith(
                      color: component.status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (component.subtitle != null) ...[
              SizedBox(height: theme.spacing.md),
              Text(component.subtitle!, style: theme.typography.bodyLarge),
            ],
            if (component.details.isNotEmpty) ...[
              SizedBox(height: theme.spacing.lg),
              Text('Details', style: theme.typography.titleMedium),
              SizedBox(height: theme.spacing.md),
              ...component.details.entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: theme.spacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: theme.typography.bodyMedium.copyWith(color: theme.colors.textMuted)),
                    Text(entry.value, style: theme.typography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
            ],
            SizedBox(height: theme.spacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSourceBadge(EdithThemeExtension theme, DataSource source) {
    return Container(
      margin: EdgeInsets.only(top: theme.spacing.xs),
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.sm, vertical: theme.spacing.xs),
      decoration: BoxDecoration(
        color: source.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(theme.radius.round),
        border: Border.all(color: source.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(source.icon, size: 10, color: source.color),
          SizedBox(width: theme.spacing.xs),
          Text(source.label, style: theme.typography.labelSmall.copyWith(color: source.color)),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, SystemEvent event) {
    final theme = context.edithTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(theme.spacing.lg),
        decoration: BoxDecoration(
          color: theme.colors.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radius.xl)),
          border: Border.all(color: theme.colors.panelBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(theme.spacing.md),
                  decoration: BoxDecoration(
                    color: event.type.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(theme.radius.md),
                  ),
                  child: Icon(event.type.icon, color: event.type.color, size: 28),
                ),
                SizedBox(width: theme.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: theme.typography.titleLarge),
                      Text(
                        _formatTimestamp(event.timestamp),
                        style: theme.typography.bodySmall.copyWith(color: theme.colors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.md,
                    vertical: theme.spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: event.type.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(theme.radius.round),
                    border: Border.all(color: event.type.color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    event.type.label,
                    style: theme.typography.labelMedium.copyWith(
                      color: event.type.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (event.component != null) ...[
              SizedBox(height: theme.spacing.md),
              Row(
                children: [
                  Icon(Icons.layers_outlined, size: 16, color: theme.colors.textMuted),
                  SizedBox(width: theme.spacing.sm),
                  Text('Component: ', style: theme.typography.bodyMedium.copyWith(color: theme.colors.textMuted)),
                  Text(event.component!, style: theme.typography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
            SizedBox(height: theme.spacing.md),
            Text(event.message, style: theme.typography.bodyLarge),
            if (event.metadata.isNotEmpty) ...[
              SizedBox(height: theme.spacing.lg),
              Text('Metadata', style: theme.typography.titleMedium),
              SizedBox(height: theme.spacing.md),
              ...event.metadata.entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: theme.spacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: theme.typography.bodyMedium.copyWith(color: theme.colors.textMuted)),
                    Text(entry.value.toString(), style: theme.typography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
            ],
            SizedBox(height: theme.spacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} minutes ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _showAllEvents(BuildContext context, List<SystemEvent> events) {
    final theme = context.edithTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colors.panel,
            borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radius.xl)),
            border: Border.all(color: theme.colors.panelBorder),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(theme.spacing.md),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.colors.panelBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All System Events', style: theme.typography.titleLarge),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: theme.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GroupedSystemEventList(
                  events: events,
                  onEventTap: (event) {
                    Navigator.pop(context);
                    _showEventDetails(context, event);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final theme = context.edithTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: theme.typography.bodyMedium),
        backgroundColor: theme.colors.panelElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(theme.radius.md)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}