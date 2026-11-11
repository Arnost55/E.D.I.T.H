import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/app_providers.dart';

/// Display options for the HUD
class DisplayOptions {
  const DisplayOptions({
    this.hudOpacity = 0.85,
    this.hudScale = 1.0,
    this.showCompass = true,
    this.showSensorData = true,
    this.showFrameRate = true,
    this.crosshairStyle = CrosshairStyle.standard,
    this.colorTheme = ColorTheme.cyan,
    this.nightMode = false,
    this.reduceMotion = false,
  });

  final double hudOpacity; // 0-1
  final double hudScale; // 0.5-2.0
  final bool showCompass;
  final bool showSensorData;
  final bool showFrameRate;
  final CrosshairStyle crosshairStyle;
  final ColorTheme colorTheme;
  final bool nightMode;
  final bool reduceMotion;

  DisplayOptions copyWith({
    double? hudOpacity,
    double? hudScale,
    bool? showCompass,
    bool? showSensorData,
    bool? showFrameRate,
    CrosshairStyle? crosshairStyle,
    ColorTheme? colorTheme,
    bool? nightMode,
    bool? reduceMotion,
  }) {
    return DisplayOptions(
      hudOpacity: hudOpacity ?? this.hudOpacity,
      hudScale: hudScale ?? this.hudScale,
      showCompass: showCompass ?? this.showCompass,
      showSensorData: showSensorData ?? this.showSensorData,
      showFrameRate: showFrameRate ?? this.showFrameRate,
      crosshairStyle: crosshairStyle ?? this.crosshairStyle,
      colorTheme: colorTheme ?? this.colorTheme,
      nightMode: nightMode ?? this.nightMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

enum CrosshairStyle {
  standard('Standard', Icons.center_focus_strong_outlined),
  minimal('Minimal', Icons.remove_outlined),
  tactical('Tactical', Icons.gps_fixed_outlined),
  dot('Dot Only', Icons.circle_outlined);

  const CrosshairStyle(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum ColorTheme {
  cyan('Cyan (Default)', '#00FFFF', '#00D4FF', '#00FFFF'),
  blue('Ice Blue', '#00B4FF', '#0099E5', '#4DA6FF'),
  green('Matrix Green', '#00FF41', '#00CC33', '#39FF14'),
  amber('Amber', '#FFB000', '#E6A000', '#FFBF00'),
  red('Tactical Red', '#FF3333', '#E62E2E', '#FF4444'),
  white('High Contrast', '#FFFFFF', '#E0E0E0', '#FFFFFF');

  const ColorTheme(this.label, this.primary, this.secondary, this.accent);
  final String label;
  final String primary;
  final String secondary;
  final String accent;

  Color get primaryColor => Color(int.parse('FF${primary.substring(1)}', radix: 16));
  Color get secondaryColor => Color(int.parse('FF${secondary.substring(1)}', radix: 16));
  Color get accentColor => Color(int.parse('FF${accent.substring(1)}', radix: 16));
}

/// Device connection info
class DeviceInfo {
  const DeviceInfo({
    required this.id,
    required this.name,
    required this.type,
    this.isConnected = false,
    this.batteryLevel = 0,
    this.signalStrength = 0,
    this.firmwareVersion = '',
    this.lastSeen = 0,
  });

  final String id;
  final String name;
  final DeviceType type;
  final bool isConnected;
  final int batteryLevel; // 0-100
  final int signalStrength; // 0-100
  final String firmwareVersion;
  final int lastSeen;

  DeviceInfo copyWith({
    String? id,
    String? name,
    DeviceType? type,
    bool? isConnected,
    int? batteryLevel,
    int? signalStrength,
    String? firmwareVersion,
    int? lastSeen,
  }) {
    return DeviceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      signalStrength: signalStrength ?? this.signalStrength,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

enum DeviceType {
  glasses('Smart Glasses', Icons.visibility_outlined),
  watch('Smart Watch', Icons.watch_outlined),
  phone('Phone', Icons.phone_android_outlined),
  drone('Drone', Icons.airplanemode_active_outlined),
  sensor('External Sensor', Icons.sensors_outlined);

  const DeviceType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Notifier for display options
class DisplayOptionsNotifier extends StateNotifier<DisplayOptions> {
  static const _prefsPrefix = 'edith_display_';

  DisplayOptionsNotifier(this._prefs) : super(const DisplayOptions()) {
    _loadOptions();
  }

  final SharedPreferences _prefs;

  Future<void> _loadOptions() async {
    final opacity = _prefs.getDouble('${_prefsPrefix}opacity') ?? 0.85;
    final scale = _prefs.getDouble('${_prefsPrefix}scale') ?? 1.0;
    final showCompass = _prefs.getBool('${_prefsPrefix}compass') ?? true;
    final showSensorData = _prefs.getBool('${_prefsPrefix}sensors') ?? true;
    final showFrameRate = _prefs.getBool('${_prefsPrefix}framerate') ?? true;
    final crosshairIndex = _prefs.getInt('${_prefsPrefix}crosshair') ?? 0;
    final colorThemeIndex = _prefs.getInt('${_prefsPrefix}colortheme') ?? 0;
    final nightMode = _prefs.getBool('${_prefsPrefix}nightmode') ?? false;
    final reduceMotion = _prefs.getBool('${_prefsPrefix}reducemotion') ?? false;

    state = DisplayOptions(
      hudOpacity: opacity,
      hudScale: scale,
      showCompass: showCompass,
      showSensorData: showSensorData,
      showFrameRate: showFrameRate,
      crosshairStyle: CrosshairStyle.values[crosshairIndex.clamp(0, CrosshairStyle.values.length - 1)],
      colorTheme: ColorTheme.values[colorThemeIndex.clamp(0, ColorTheme.values.length - 1)],
      nightMode: nightMode,
      reduceMotion: reduceMotion,
    );
  }

  Future<void> updateOptions(DisplayOptions options) async {
    state = options;
    await _prefs.setDouble('${_prefsPrefix}opacity', options.hudOpacity);
    await _prefs.setDouble('${_prefsPrefix}scale', options.hudScale);
    await _prefs.setBool('${_prefsPrefix}compass', options.showCompass);
    await _prefs.setBool('${_prefsPrefix}sensors', options.showSensorData);
    await _prefs.setBool('${_prefsPrefix}framerate', options.showFrameRate);
    await _prefs.setInt('${_prefsPrefix}crosshair', options.crosshairStyle.index);
    await _prefs.setInt('${_prefsPrefix}colortheme', options.colorTheme.index);
    await _prefs.setBool('${_prefsPrefix}nightmode', options.nightMode);
    await _prefs.setBool('${_prefsPrefix}reducemotion', options.reduceMotion);
  }

  Future<void> setHudOpacity(double value) async {
    await updateOptions(state.copyWith(hudOpacity: value.clamp(0.1, 1.0)));
  }

  Future<void> setHudScale(double value) async {
    await updateOptions(state.copyWith(hudScale: value.clamp(0.5, 2.0)));
  }

  Future<void> toggleNightMode() async {
    await updateOptions(state.copyWith(nightMode: !state.nightMode));
  }

  Future<void> toggleReduceMotion() async {
    await updateOptions(state.copyWith(reduceMotion: !state.reduceMotion));
  }
}

/// Notifier for device management
class DeviceManagerNotifier extends StateNotifier<List<DeviceInfo>> {
  DeviceManagerNotifier() : super(_getMockDevices()) {
    _startSimulation();
  }

  Timer? _simulationTimer;
  final _random = Random();

  static List<DeviceInfo> _getMockDevices() {
    return [
      DeviceInfo(
        id: 'edith_glasses_01',
        name: 'E.D.I.T.H. Glasses V2.4',
        type: DeviceType.glasses,
        isConnected: true,
        batteryLevel: 87,
        signalStrength: 94,
        firmwareVersion: '2.4.1',
        lastSeen: DateTime.now().millisecondsSinceEpoch,
      ),
      DeviceInfo(
        id: 'edith_watch_01',
        name: 'Tactical Watch',
        type: DeviceType.watch,
        isConnected: true,
        batteryLevel: 92,
        signalStrength: 88,
        firmwareVersion: '1.3.0',
        lastSeen: DateTime.now().millisecondsSinceEpoch,
      ),
      DeviceInfo(
        id: 'phone_primary',
        name: 'Primary Phone',
        type: DeviceType.phone,
        isConnected: true,
        batteryLevel: 78,
        signalStrength: 96,
        firmwareVersion: '14.2.1',
        lastSeen: DateTime.now().millisecondsSinceEpoch,
      ),
      DeviceInfo(
        id: 'drone_01',
        name: 'Recon Drone Alpha',
        type: DeviceType.drone,
        isConnected: false,
        batteryLevel: 65,
        signalStrength: 0,
        firmwareVersion: '3.1.0',
        lastSeen: DateTime.now().millisecondsSinceEpoch - 3600000,
      ),
    ];
  }

  void _startSimulation() {
    // Listen to simulation config
    // Note: We can't listen here without ref, so we'll just run a timer
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateDeviceStatuses();
    });
  }

  void _updateDeviceStatuses() {
    final updated = state.map((device) {
      if (!device.isConnected) return device;

      // Simulate battery drain
      final newBattery = max(0, device.batteryLevel - _random.nextInt(2));
      // Simulate signal fluctuation
      final newSignal = (device.signalStrength + _random.nextInt(10) - 5).clamp(0, 100);

      return device.copyWith(
        batteryLevel: newBattery,
        signalStrength: newSignal,
        lastSeen: DateTime.now().millisecondsSinceEpoch,
      );
    }).toList();

    state = updated;
  }

  void toggleDeviceConnection(String deviceId) {
    final index = state.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      final device = state[index];
      final updated = [...state];
      updated[index] = device.copyWith(
        isConnected: !device.isConnected,
        signalStrength: device.isConnected ? 0 : 80 + _random.nextInt(20),
        lastSeen: DateTime.now().millisecondsSinceEpoch,
      );
      state = updated;
    }
  }

  void removeDevice(String deviceId) {
    state = state.where((d) => d.id != deviceId).toList();
  }

  void addDevice(DeviceInfo device) {
    state = [...state, device];
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

/// Notifier for privacy settings
class PrivacySettingsNotifier extends StateNotifier<Map<String, bool>> {
  static const _prefsPrefix = 'edith_privacy_';

  PrivacySettingsNotifier(this._prefs) : super({}) {
    _loadSettings();
  }

  final SharedPreferences _prefs;

  static const _defaultSettings = {
    'analytics': false,
    'crash_reporting': true,
    'usage_stats': false,
    'voice_recording': false,
    'location_tracking': false,
    'data_sync': false,
    'telemetry': false,
    'share_diagnostics': false,
  };

  Future<void> _loadSettings() async {
    final settings = <String, bool>{};
    for (final key in _defaultSettings.keys) {
      settings[key] = _prefs.getBool('${_prefsPrefix}$key') ?? _defaultSettings[key]!;
    }
    state = settings;
  }

  Future<void> toggleSetting(String key) async {
    final newValue = !(state[key] ?? false);
    state = {...state, key: newValue};
    await _prefs.setBool('${_prefsPrefix}$key', newValue);
  }

  Future<void> setSetting(String key, bool value) async {
    state = {...state, key: value};
    await _prefs.setBool('${_prefsPrefix}$key', value);
  }
}

/// Providers
final displayOptionsProvider = StateNotifierProvider<DisplayOptionsNotifier, DisplayOptions>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DisplayOptionsNotifier(prefs);
});

final deviceManagerProvider = StateNotifierProvider<DeviceManagerNotifier, List<DeviceInfo>>((ref) {
  return DeviceManagerNotifier();
});

final privacySettingsProvider = StateNotifierProvider<PrivacySettingsNotifier, Map<String, bool>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PrivacySettingsNotifier(prefs);
});

/// Convenience providers
final hudOpacityProvider = Provider<double>((ref) => ref.watch(displayOptionsProvider).hudOpacity);
final hudScaleProvider = Provider<double>((ref) => ref.watch(displayOptionsProvider).hudScale);
final nightModeProvider = Provider<bool>((ref) => ref.watch(displayOptionsProvider).nightMode);
final connectedDevicesProvider = Provider<List<DeviceInfo>>((ref) =>
    ref.watch(deviceManagerProvider).where((d) => d.isConnected).toList());