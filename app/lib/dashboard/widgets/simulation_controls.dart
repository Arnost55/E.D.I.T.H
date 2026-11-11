/// Simulation controls widget
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/edith_theme.dart';
import '../dashboard_state.dart';

/// Expandable simulation controls panel
class SimulationControls extends ConsumerStatefulWidget {
  const SimulationControls({
    super.key,
    this.initiallyExpanded = false,
  });

  final bool initiallyExpanded;

  @override
  ConsumerState<SimulationControls> createState() => _SimulationControlsState();
}

class _SimulationControlsState extends ConsumerState<SimulationControls>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;

    _animationController = AnimationController(
      duration: EdithDurations.normal,
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: EdithCurves.standard,
    );

    if (_expanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.edithTheme;
    final simulation = ref.watch(simulationConfigProvider);

    return Column(
      children: [
        // Header - always visible
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(theme.radius.lg),
            child: Container(
              padding: EdgeInsets.all(theme.spacing.md),
              decoration: BoxDecoration(
                color: theme.colors.panel,
                borderRadius: BorderRadius.circular(theme.radius.lg),
                border: Border.all(
                  color: simulation.enabled
                      ? theme.colors.statusWarning.withValues(alpha: 0.5)
                      : theme.colors.panelBorder,
                  width: simulation.enabled ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(theme.spacing.sm),
                    decoration: BoxDecoration(
                      color: simulation.enabled
                          ? theme.colors.statusWarning.withValues(alpha: 0.15)
                          : theme.colors.panelElevated,
                      borderRadius: BorderRadius.circular(theme.radius.md),
                    ),
                    child: Icon(
                      Icons.science_outlined,
                      color: simulation.enabled
                          ? theme.colors.statusWarning
                          : theme.colors.textMuted,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: theme.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simulation Controls',
                          style: theme.typography.titleMedium,
                        ),
                        SizedBox(height: theme.spacing.xs),
                        Text(
                          simulation.enabled
                              ? 'Active • ${simulation.simulationSpeed}x speed'
                              : 'Disabled • Live data only',
                          style: theme.typography.bodySmall.copyWith(
                            color: simulation.enabled
                                ? theme.colors.statusWarning
                                : theme.colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: EdithDurations.normal,
                    child: Icon(
                      Icons.expand_more,
                      color: theme.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Expandable content
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Column(
            children: [
              SizedBox(height: theme.spacing.md),
              _buildExpandedContent(context, theme, simulation),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context, EdithThemeExtension theme, SimulationConfig simulation) {
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
          // Master toggle
          _buildMasterToggle(theme, simulation),
          SizedBox(height: theme.spacing.lg),

          if (simulation.enabled) ...[
            // Speed control
            _buildSpeedControl(theme, simulation),
            SizedBox(height: theme.spacing.lg),

            // Individual toggles
            _buildIndividualToggles(theme, simulation),
            SizedBox(height: theme.spacing.lg),

            // Preset scenarios
            _buildPresetScenarios(theme, simulation),
            SizedBox(height: theme.spacing.lg),

            // Data source legend
            _buildDataSourceLegend(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildMasterToggle(EdithThemeExtension theme, SimulationConfig simulation) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simulation Mode',
                style: theme.typography.titleSmall,
              ),
              SizedBox(height: theme.spacing.xs),
              Text(
                'Enable simulated data for all subsystems',
                style: theme.typography.bodySmall.copyWith(
                  color: theme.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: simulation.enabled,
          onChanged: (_) => ref.read(simulationConfigProvider.notifier).toggleEnabled(),
          activeColor: theme.colors.statusWarning,
          inactiveThumbColor: theme.colors.textMuted,
          inactiveTrackColor: theme.colors.panelBorder,
        ),
      ],
    );
  }

  Widget _buildSpeedControl(EdithThemeExtension theme, SimulationConfig simulation) {
    final speeds = [1, 2, 5, 10];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Simulation Speed',
              style: theme.typography.titleSmall,
            ),
            Text(
              '${simulation.simulationSpeed}x',
              style: theme.typography.titleSmall.copyWith(
                color: theme.colors.accentStrong,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.sm),
        Slider(
          value: simulation.simulationSpeed.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '${simulation.simulationSpeed}x',
          activeColor: theme.colors.accentStrong,
          inactiveColor: theme.colors.panelBorder,
          onChanged: (value) {
            ref.read(simulationConfigProvider.notifier).setSimulationSpeed(value.round());
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: speeds.map((speed) {
            return GestureDetector(
              onTap: () => ref.read(simulationConfigProvider.notifier).setSimulationSpeed(speed),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.sm,
                  vertical: theme.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: simulation.simulationSpeed == speed
                      ? theme.colors.accentStrong.withValues(alpha: 0.2)
                      : theme.colors.panelElevated,
                  borderRadius: BorderRadius.circular(theme.radius.sm),
                  border: Border.all(
                    color: simulation.simulationSpeed == speed
                        ? theme.colors.accentStrong
                        : theme.colors.panelBorder,
                  ),
                ),
                child: Text(
                  '${speed}x',
                  style: theme.typography.labelSmall.copyWith(
                    color: simulation.simulationSpeed == speed
                        ? theme.colors.accentStrong
                        : theme.colors.textSecondary,
                    fontWeight: simulation.simulationSpeed == speed
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIndividualToggles(EdithThemeExtension theme, SimulationConfig simulation) {
    final toggles = [
      ('Battery', Icons.battery_6_bar, simulation.simulateBattery,
          (v) => simulation.copyWith(simulateBattery: v)),
      ('Connectivity', Icons.wifi, simulation.simulateConnectivity,
          (v) => simulation.copyWith(simulateConnectivity: v)),
      ('Vision System', Icons.visibility, simulation.simulateVision,
          (v) => simulation.copyWith(simulateVision: v)),
      ('AI Engine', Icons.psychology, simulation.simulateAIEngine,
          (v) => simulation.copyWith(simulateAIEngine: v)),
      ('Threat Detection', Icons.shield, simulation.simulateThreats,
          (v) => simulation.copyWith(simulateThreats: v)),
      ('Sensors', Icons.sensors, simulation.simulateSensors,
          (v) => simulation.copyWith(simulateSensors: v)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subsystem Simulation',
          style: theme.typography.titleSmall,
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Toggle individual subsystem simulations',
          style: theme.typography.bodySmall.copyWith(
            color: theme.colors.textMuted,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        Wrap(
          spacing: theme.spacing.md,
          runSpacing: theme.spacing.sm,
          children: toggles.map((toggle) {
            final (label, icon, value, updater) = toggle;
            return _buildToggleChip(
              theme,
              label,
              icon,
              value,
              () => ref.read(simulationConfigProvider.notifier).updateConfig(updater(!value)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleChip(
    EdithThemeExtension theme,
    String label,
    IconData icon,
    bool value,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radius.md),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: value
                ? theme.colors.accentStrong.withValues(alpha: 0.15)
                : theme.colors.panelElevated,
            borderRadius: BorderRadius.circular(theme.radius.md),
            border: Border.all(
              color: value
                  ? theme.colors.accentStrong.withValues(alpha: 0.5)
                  : theme.colors.panelBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: value ? theme.colors.accentStrong : theme.colors.textMuted,
              ),
              SizedBox(width: theme.spacing.sm),
              Text(
                label,
                style: theme.typography.labelMedium.copyWith(
                  color: value ? theme.colors.textPrimary : theme.colors.textSecondary,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              SizedBox(width: theme.spacing.sm),
              Icon(
                value ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: value ? theme.colors.statusLive : theme.colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetScenarios(EdithThemeExtension theme, SimulationConfig simulation) {
    final presets = [
      SimulationPreset(
        name: 'Demo Mode',
        description: 'All systems simulated at normal speed',
        config: const SimulationConfig(
          enabled: true,
          simulateBattery: true,
          simulateConnectivity: true,
          simulateVision: true,
          simulateAIEngine: true,
          simulateThreats: true,
          simulateSensors: true,
          simulationSpeed: 1,
        ),
      ),
      SimulationPreset(
        name: 'High Speed',
        description: 'Fast simulation for testing',
        config: const SimulationConfig(
          enabled: true,
          simulateBattery: true,
          simulateConnectivity: true,
          simulateVision: true,
          simulateAIEngine: true,
          simulateThreats: true,
          simulateSensors: true,
          simulationSpeed: 10,
        ),
      ),
      SimulationPreset(
        name: 'Battery Focus',
        description: 'Only battery simulation enabled',
        config: const SimulationConfig(
          enabled: true,
          simulateBattery: true,
          simulateConnectivity: false,
          simulateVision: false,
          simulateAIEngine: false,
          simulateThreats: false,
          simulateSensors: false,
          simulationSpeed: 2,
        ),
      ),
      SimulationPreset(
        name: 'Live Only',
        description: 'Disable all simulation',
        config: const SimulationConfig(
          enabled: false,
          simulationSpeed: 1,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preset Scenarios',
          style: theme.typography.titleSmall,
        ),
        SizedBox(height: theme.spacing.sm),
        Wrap(
          spacing: theme.spacing.sm,
          runSpacing: theme.spacing.sm,
          children: presets.map((preset) {
            final isActive = _isPresetActive(simulation, preset.config);
            return _buildPresetButton(theme, preset, isActive);
          }).toList(),
        ),
      ],
    );
  }

  bool _isPresetActive(SimulationConfig current, SimulationConfig preset) {
    return current.enabled == preset.enabled &&
        current.simulateBattery == preset.simulateBattery &&
        current.simulateConnectivity == preset.simulateConnectivity &&
        current.simulateVision == preset.simulateVision &&
        current.simulateAIEngine == preset.simulateAIEngine &&
        current.simulateThreats == preset.simulateThreats &&
        current.simulateSensors == preset.simulateSensors &&
        current.simulationSpeed == preset.simulationSpeed;
  }

  Widget _buildPresetButton(
    EdithThemeExtension theme,
    SimulationPreset preset,
    bool isActive,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(simulationConfigProvider.notifier).updateConfig(preset.config),
        borderRadius: BorderRadius.circular(theme.radius.md),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colors.accentStrong.withValues(alpha: 0.2)
                : theme.colors.panelElevated,
            borderRadius: BorderRadius.circular(theme.radius.md),
            border: Border.all(
              color: isActive
                  ? theme.colors.accentStrong
                  : theme.colors.panelBorder,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    preset.name,
                    style: theme.typography.labelMedium.copyWith(
                      color: isActive ? theme.colors.accentStrong : theme.colors.textPrimary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (isActive) ...[
                    SizedBox(width: theme.spacing.xs),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: theme.colors.accentStrong,
                    ),
                  ],
                ],
              ),
              SizedBox(height: theme.spacing.xs),
              Text(
                preset.description,
                style: theme.typography.bodySmall.copyWith(
                  color: theme.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSourceLegend(EdithThemeExtension theme) {
    final sources = [
      DataSource.live,
      DataSource.simulated,
      DataSource.unavailable,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Source Indicators',
          style: theme.typography.titleSmall,
        ),
        SizedBox(height: theme.spacing.sm),
        Wrap(
          spacing: theme.spacing.md,
          runSpacing: theme.spacing.sm,
          children: sources.map((source) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: source.color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: theme.spacing.sm),
                Text(
                  source.label,
                  style: theme.typography.labelMedium.copyWith(
                    color: theme.colors.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SimulationPreset {
  const SimulationPreset({
    required this.name,
    required this.description,
    required this.config,
  });

  final String name;
  final String description;
  final SimulationConfig config;
}

/// Compact simulation status indicator
class SimulationStatusIndicator extends ConsumerWidget {
  const SimulationStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.edithTheme;
    final simulation = ref.watch(simulationConfigProvider);

    if (!simulation.enabled) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.sm,
        vertical: theme.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colors.statusWarning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(theme.radius.round),
        border: Border.all(color: theme.colors.statusWarning.withValues(alpha: 0.5)),
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
    );
  }
}

/// Floating simulation toggle button
class SimulationFloatButton extends ConsumerWidget {
  const SimulationFloatButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.edithTheme;
    final simulation = ref.watch(simulationConfigProvider);

    return FloatingActionButton.small(
      onPressed: () => ref.read(simulationConfigProvider.notifier).toggleEnabled(),
      backgroundColor: simulation.enabled
          ? theme.colors.statusWarning
          : theme.colors.panelElevated,
      foregroundColor: simulation.enabled
          ? theme.colors.background
          : theme.colors.textPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.radius.round),
        side: BorderSide(
          color: simulation.enabled
              ? theme.colors.statusWarning
              : theme.colors.panelBorder,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.science_outlined,
        size: 20,
      ),
    ).animate().scale(duration: EdithDurations.normal, curve: EdithCurves.emphasized);
  }
}