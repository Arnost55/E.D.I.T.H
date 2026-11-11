import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'providers/settings_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../assistant/providers/assistant_providers.dart';
import '../../core/theme/edith_theme.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationConfig = ref.watch(simulationConfigProvider);
    final displayOptions = ref.watch(displayOptionsProvider);
    final devices = ref.watch(deviceManagerProvider);
    final privacySettings = ref.watch(privacySettingsProvider);
    final aiConfigs = ref.watch(aiProviderConfigProvider);

    return Scaffold(
      backgroundColor: EdithColors.bgPrimary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),
            // Simulation Mode
            _buildSection(
              title: 'SIMULATION MODE',
              icon: Icons.science_outlined,
              children: [
                _buildSimulationToggle(simulationConfig, ref),
                const SizedBox(height: 12),
                ..._buildSimulationToggles(simulationConfig, ref),
              ],
            ),
            const SizedBox(height: 24),
            // AI Provider Configuration
            _buildSection(
              title: 'AI ASSISTANT',
              icon: Icons.auto_awesome_outlined,
              children: [
                _buildAIProviderConfig(aiConfigs, ref),
                const SizedBox(height: 12),
                _buildAIProviderSettings(aiConfigs, ref),
              ],
            ),
            const SizedBox(height: 24),
            // Display Options
            _buildSection(
              title: 'DISPLAY & HUD',
              icon: Icons.display_settings_outlined,
              children: [
                _buildDisplayOptions(displayOptions, ref),
              ],
            ),
            const SizedBox(height: 24),
            // Device Management
            _buildSection(
              title: 'DEVICE MANAGEMENT',
              icon: Icons.devices_outlined,
              children: [
                _buildDeviceList(devices, ref),
              ],
            ),
            const SizedBox(height: 24),
            // Privacy & Security
            _buildSection(
              title: 'PRIVACY & SECURITY',
              icon: Icons.security_outlined,
              children: [
                _buildPrivacySettings(privacySettings, ref),
              ],
            ),
            const SizedBox(height: 24),
            // About
            _buildSection(
              title: 'ABOUT',
              icon: Icons.info_outline,
              children: [
                _buildAboutSection(),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: EdithColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: EdithColors.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            'SETTINGS',
            style: EdithTypography.captionStyle.copyWith(
              color: EdithColors.accentStrong,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'CONFIGURATION',
          style: EdithTypography.headlineStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: EdithColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: EdithColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EdithColors.panelBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: EdithColors.panelBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: EdithColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: EdithColors.accentStrong, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: EdithTypography.headlineStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Section content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSimulationToggle(SimulationConfig config, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.enabled
            ? EdithColors.accent.withValues(alpha: 0.08)
            : EdithColors.panelElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: config.enabled
              ? EdithColors.accent.withValues(alpha: 0.3)
              : EdithColors.panelBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: config.enabled
                    ? [EdithColors.accent, EdithColors.accentStrong]
                    : [EdithColors.textMuted, EdithColors.textMuted],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.science_outlined,
              color: config.enabled ? EdithColors.background : EdithColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulation Mode',
                  style: EdithTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: EdithColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.enabled
                      ? 'All systems running in simulation. No hardware required.'
                      : 'Simulation disabled. Real hardware connections required.',
                  style: EdithTypography.captionStyle.copyWith(
                    color: EdithColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: config.enabled,
            onChanged: (_) => ref.read(simulationConfigProvider.notifier).toggleEnabled(),
            activeColor: EdithColors.accentStrong,
            activeTrackColor: EdithColors.accent.withValues(alpha: 0.3),
            inactiveThumbColor: EdithColors.textMuted,
            inactiveTrackColor: EdithColors.panelBorder,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSimulationToggles(SimulationConfig config, WidgetRef ref) {
    final toggles = [
      ('Battery Simulation', 'Simulate battery drain and charging', config.simulateBattery, 'battery'),
      ('Connectivity', 'Simulate network status and signals', config.simulateConnectivity, 'connectivity'),
      ('Vision System', 'Simulate camera feed and object detection', config.simulateVision, 'vision'),
      ('AI Engine', 'Simulate AI processing and responses', config.simulateAIEngine, 'ai_engine'),
      ('Threat Detection', 'Simulate threat scanning and alerts', config.simulateThreats, 'threats'),
      ('Sensors', 'Simulate IMU and environmental sensors', config.simulateSensors, 'sensors'),
    ];

    return toggles.map((toggle) {
      final (title, subtitle, value, key) = toggle;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: EdithTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: config.enabled ? EdithColors.textPrimary : EdithColors.textMuted,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: EdithTypography.captionStyle.copyWith(
                      color: EdithColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value && config.enabled,
              onChanged: config.enabled
                  ? (newValue) => _updateSimulationConfig(ref, key, newValue)
                  : null,
              activeColor: EdithColors.accentStrong,
              activeTrackColor: EdithColors.accent.withValues(alpha: 0.3),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _updateSimulationConfig(WidgetRef ref, String key, bool value) async {
    final current = ref.read(simulationConfigProvider);
    SimulationConfig updated;
    switch (key) {
      case 'battery':
        updated = current.copyWith(simulateBattery: value);
        break;
      case 'connectivity':
        updated = current.copyWith(simulateConnectivity: value);
        break;
      case 'vision':
        updated = current.copyWith(simulateVision: value);
        break;
      case 'ai_engine':
        updated = current.copyWith(simulateAIEngine: value);
        break;
      case 'threats':
        updated = current.copyWith(simulateThreats: value);
        break;
      case 'sensors':
        updated = current.copyWith(simulateSensors: value);
        break;
      default:
        return;
    }
    await ref.read(simulationConfigProvider.notifier).updateConfig(updated);
  }

  Widget _buildAIProviderConfig(Map<AIProviderType, AIProviderConfig> configs, WidgetRef ref) {
    final activeProvider = configs.entries.firstWhere((e) => e.value.enabled).key;

    return Column(
      children: [
        // Active provider selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: EdithColors.panelElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: EdithColors.panelBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Provider',
                      style: EdithTypography.captionStyle.copyWith(
                        color: EdithColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeProvider.displayName,
                      style: EdithTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: EdithColors.accentStrong,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<AIProviderType>(
                onSelected: (provider) {
                  ref.read(aiProviderConfigProvider.notifier).setActiveProvider(provider);
                  ref.read(aiEngineStatusProvider.notifier).setActiveProvider(provider);
                },
                itemBuilder: (context) => AIProviderType.values.map((provider) {
                  final config = configs[provider]!;
                  if (!config.enabled && provider != AIProviderType.mock) return null;
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
                          style: EdithTypography.bodyMedium.copyWith(
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
                          Icon(Icons.check_circle, size: 18, color: EdithColors.accentStrong),
                        ],
                      ],
                    ),
                  );
                }).whereType<PopupMenuItem<AIProviderType>>().toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        _getProviderIcon(activeProvider),
                        size: 20,
                        color: EdithColors.accentStrong,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Change',
                        style: EdithTypography.bodyMedium.copyWith(
                          color: EdithColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: EdithColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIProviderSettings(Map<AIProviderType, AIProviderConfig> configs, WidgetRef ref) {
    return Column(
      children: AIProviderType.values.map((type) {
        final config = configs[type]!;
        final isMock = type == AIProviderType.mock;

        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: config.enabled
                ? EdithColors.accent.withValues(alpha: 0.05)
                : EdithColors.panelElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: config.enabled
                  ? EdithColors.accent.withValues(alpha: 0.3)
                  : EdithColors.panelBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getProviderIcon(type), color: EdithColors.accentStrong, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: EdithTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: config.enabled ? EdithColors.textPrimary : EdithColors.textMuted,
                          ),
                        ),
                        Text(
                          type.description,
                          style: EdithTypography.captionStyle.copyWith(
                            color: EdithColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMock)
                    Switch.adaptive(
                      value: config.enabled,
                      onChanged: (value) =>
                          ref.read(aiProviderConfigProvider.notifier).toggleProvider(type),
                      activeColor: EdithColors.accentStrong,
                      activeTrackColor: EdithColors.accent.withValues(alpha: 0.3),
                    ),
                ],
              ),
              if (config.enabled && !isMock) ...[
                const SizedBox(height: 16),
                _buildConfigField(
                  'API Key',
                  config.apiKey,
                  obscure: true,
                  onChanged: (value) => _updateAIConfig(ref, type, config.copyWith(apiKey: value)),
                ),
                const SizedBox(height: 12),
                _buildConfigField(
                  'Base URL (optional)',
                  config.baseUrl,
                  onChanged: (value) => _updateAIConfig(ref, type, config.copyWith(baseUrl: value)),
                ),
                const SizedBox(height: 12),
                _buildConfigField(
                  'Model',
                  config.model,
                  onChanged: (value) => _updateAIConfig(ref, type, config.copyWith(model: value)),
                ),
              ],
              if (!config.enabled && !isMock) ...[
                const SizedBox(height: 12),
                Text(
                  'Enable this provider to configure API settings',
                  style: EdithTypography.captionStyle.copyWith(
                    color: EdithColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfigField(
    String label,
    String value, {
    bool obscure = false,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: EdithTypography.captionStyle.copyWith(
            color: EdithColors.textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscure,
          style: EdithTypography.bodyMedium.copyWith(
            color: EdithColors.textPrimary,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: EdithColors.panel,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: EdithColors.panelBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: EdithColors.panelBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: EdithColors.accent, width: 1.5),
            ),
            hintText: 'Enter $label',
            hintStyle: EdithTypography.bodyMedium.copyWith(
              color: EdithColors.textMuted,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _updateAIConfig(WidgetRef ref, AIProviderType type, AIProviderConfig config) {
    ref.read(aiProviderConfigProvider.notifier).updateConfig(type, config);
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

  Widget _buildDisplayOptions(DisplayOptions options, WidgetRef ref) {
    return Column(
      children: [
        // HUD Opacity
        _buildSliderSetting(
          'HUD Opacity',
          'Adjust overlay transparency',
          options.hudOpacity,
          0.1,
          1.0,
          (value) => ref.read(displayOptionsProvider.notifier).setHudOpacity(value),
          valueFormat: (v) => '${(v * 100).toInt()}%',
        ),
        const SizedBox(height: 16),
        // HUD Scale
        _buildSliderSetting(
          'HUD Scale',
          'Adjust overlay size',
          options.hudScale,
          0.5,
          2.0,
          (value) => ref.read(displayOptionsProvider.notifier).setHudScale(value),
          valueFormat: (v) => '${v.toStringAsFixed(1)}x',
        ),
        const SizedBox(height: 16),
        // Color Theme
        _buildDropdownSetting<ColorTheme>(
          'Color Theme',
          'Choose HUD color scheme',
          options.colorTheme,
          ColorTheme.values,
          (theme) => theme.label,
          (theme) => ref.read(displayOptionsProvider.notifier).updateOptions(
            options.copyWith(colorTheme: theme),
          ),
        ),
        const SizedBox(height: 16),
        // Crosshair Style
        _buildDropdownSetting<CrosshairStyle>(
          'Crosshair Style',
          'Select targeting reticle',
          options.crosshairStyle,
          CrosshairStyle.values,
          (style) => style.label,
          (style) => ref.read(displayOptionsProvider.notifier).updateOptions(
            options.copyWith(crosshairStyle: style),
          ),
        ),
        const SizedBox(height: 16),
        // Toggle options
        _buildToggleSetting(
          'Show Compass',
          'Display heading indicator',
          options.showCompass,
          (value) => ref.read(displayOptionsProvider.notifier).updateOptions(
            options.copyWith(showCompass: value),
          ),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          'Show Sensor Data',
          'Display IMU readings on HUD',
          options.showSensorData,
          (value) => ref.read(displayOptionsProvider.notifier).updateOptions(
            options.copyWith(showSensorData: value),
          ),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          'Show Frame Rate',
          'Display FPS counter',
          options.showFrameRate,
          (value) => ref.read(displayOptionsProvider.notifier).updateOptions(
            options.copyWith(showFrameRate: value),
          ),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          'Night Mode',
          'Reduce brightness for dark environments',
          options.nightMode,
          (value) => ref.read(displayOptionsProvider.notifier).toggleNightMode(),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          'Reduce Motion',
          'Minimize animations and transitions',
          options.reduceMotion,
          (value) => ref.read(displayOptionsProvider.notifier).toggleReduceMotion(),
        ),
      ],
    );
  }

  Widget _buildSliderSetting(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    void Function(double) onChanged, {
    required String Function(double) valueFormat,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: EdithTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: EdithTypography.captionStyle.copyWith(
                    color: EdithColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: EdithColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: EdithColors.accent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                valueFormat(value),
                style: EdithTypography.captionStyle.copyWith(
                  color: EdithColors.accentStrong,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: EdithColors.accent,
            inactiveTrackColor: EdithColors.panelBorder,
            thumbColor: EdithColors.accentStrong,
            overlayColor: EdithColors.accent.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSetting<T>(
    String title,
    String subtitle,
    T value,
    List<T> options,
    String Function(T) labelBuilder,
    void Function(T) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: EdithTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: EdithTypography.captionStyle.copyWith(
            color: EdithColors.textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: EdithColors.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: EdithColors.panelBorder,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                dropdownColor: EdithColors.panel,
                style: EdithTypography.bodyMedium.copyWith(color: EdithColors.textPrimary),
                icon: Icon(Icons.keyboard_arrow_down, color: EdithColors.accent),
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: options.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(labelBuilder(option)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) onChanged(newValue);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: EdithTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: EdithTypography.captionStyle.copyWith(
                  color: EdithColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: EdithColors.accentStrong,
          activeTrackColor: EdithColors.accent.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildDeviceList(List<DeviceInfo> devices, WidgetRef ref) {
    return Column(
      children: devices.map((device) => _buildDeviceCard(device, ref)).toList(),
    );
  }

  Widget _buildDeviceCard(DeviceInfo device, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: device.isConnected
            ? EdithColors.success.withValues(alpha: 0.05)
            : EdithColors.panelElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: device.isConnected
              ? EdithColors.success.withValues(alpha: 0.3)
              : EdithColors.panelBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: device.isConnected
                    ? [EdithColors.success.withValues(alpha: 0.3), EdithColors.success.withValues(alpha: 0.1)]
                    : [EdithColors.textMuted.withValues(alpha: 0.3), EdithColors.textMuted.withValues(alpha: 0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              device.type.icon,
              color: device.isConnected ? EdithColors.success : EdithColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device.name,
                      style: EdithTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: device.isConnected ? EdithColors.textPrimary : EdithColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: device.type.label == 'Smart Glasses'
                            ? EdithColors.accent.withValues(alpha: 0.2)
                            : EdithColors.panelElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: device.type.label == 'Smart Glasses'
                              ? EdithColors.accent.withValues(alpha: 0.3)
                              : EdithColors.panelBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        device.type.label,
                        style: EdithTypography.captionStyle.copyWith(
                          color: device.type.label == 'Smart Glasses'
                              ? EdithColors.accentStrong
                              : EdithColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildDeviceMetric(
                      Icons.battery_4_bar,
                      '${device.batteryLevel}%',
                      device.batteryLevel > 20 ? EdithColors.success : EdithColors.danger,
                    ),
                    const SizedBox(width: 16),
                    _buildDeviceMetric(
                      Icons.signal_cellular_alt_outlined,
                      '${device.signalStrength}%',
                      device.signalStrength > 50 ? EdithColors.success : EdithColors.warning,
                    ),
                    const SizedBox(width: 16),
                    _buildDeviceMetric(
                      Icons.tag_outlined,
                      'v${device.firmwareVersion}',
                      EdithColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: device.isConnected,
            onChanged: (_) => ref.read(deviceManagerProvider.notifier).toggleDeviceConnection(device.id),
            activeColor: EdithColors.success,
            activeTrackColor: EdithColors.success.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceMetric(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: EdithTypography.captionStyle.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(Map<String, bool> settings, WidgetRef ref) {
    final settingEntries = [
      ('analytics', 'Analytics', 'Collect anonymous usage analytics'),
      ('crash_reporting', 'Crash Reporting', 'Automatically send crash reports'),
      ('usage_stats', 'Usage Statistics', 'Share feature usage statistics'),
      ('voice_recording', 'Voice Recording', 'Store voice commands for improvement'),
      ('location_tracking', 'Location Tracking', 'Track location for contextual features'),
      ('data_sync', 'Data Synchronization', 'Sync settings across devices'),
      ('telemetry', 'Telemetry', 'Send system performance telemetry'),
      ('share_diagnostics', 'Share Diagnostics', 'Share diagnostic data with developers'),
    ];

    return Column(
      children: settingEntries.map((entry) {
        final (key, title, subtitle) = entry;
        final value = settings[key] ?? false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: EdithTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: EdithTypography.captionStyle.copyWith(
                        color: EdithColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: (newValue) => ref.read(privacySettingsProvider.notifier).toggleSetting(key),
                activeColor: EdithColors.accentStrong,
                activeTrackColor: EdithColors.accent.withValues(alpha: 0.3),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      children: [
        _buildAboutRow('Version', '2.4.1'),
        const SizedBox(height: 12),
        _buildAboutRow('Build', 'EDITH-V2.4.1-20261111'),
        const SizedBox(height: 12),
        _buildAboutRow('Platform', 'Flutter 3.24 / Dart 3.5'),
        const SizedBox(height: 12),
        _buildAboutRow('Architecture', 'Riverpod + go_router + Material 3'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl('https://github.com/edith-project'),
                icon: Icon(Icons.code_outlined, size: 18),
                label: Text('Source Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: EdithColors.accent,
                  side: BorderSide(color: EdithColors.accent.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl('https://edith-project.dev/docs'),
                icon: Icon(Icons.description_outlined, size: 18),
                label: Text('Documentation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: EdithColors.info,
                  side: BorderSide(color: EdithColors.info.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl('https://edith-project.dev/privacy'),
                icon: Icon(Icons.privacy_tip_outlined, size: 18),
                label: Text('Privacy Policy'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: EdithColors.warning,
                  side: BorderSide(color: EdithColors.warning.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showLicenses(),
                icon: Icon(Icons.gavel_outlined, size: 18),
                label: Text('Licenses'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: EdithColors.textSecondary,
                  side: BorderSide(color: EdithColors.panelBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'E.D.I.T.H. — Even Dead, I\'m The Hero\nSmart Glasses Companion Application',
          style: EdithTypography.captionStyle.copyWith(
            color: EdithColors.textMuted,
            fontSize: 11,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: EdithTypography.bodyMedium.copyWith(
            color: EdithColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: EdithTypography.bodyMedium.copyWith(
            color: EdithColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showLicenses() {
    showLicensePage(
      context: navigatorKey.currentContext!,
      applicationName: 'E.D.I.T.H.',
      applicationVersion: '2.4.1',
      applicationIcon: const Icon(Icons.auto_awesome_rounded, color: EdithColors.accent, size: 48),
      applicationLegalese: '© 2026 E.D.I.T.H. Project. All rights reserved.',
    );
  }
}

// Global navigator key for license page
final navigatorKey = GlobalKey<NavigatorState>();