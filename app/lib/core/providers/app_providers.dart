import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

/// Simulation configuration that controls all simulation behaviors
class SimulationConfig {
  const SimulationConfig({
    this.enabled = true,
    this.simulateBattery = true,
    this.simulateConnectivity = true,
    this.simulateVision = true,
    this.simulateAIEngine = true,
    this.simulateThreats = true,
    this.simulateSensors = true,
    this.updateIntervalMs = 1000,
    this.simulationSpeed = 1.0,
  });

  final bool enabled;
  final bool simulateBattery;
  final bool simulateConnectivity;
  final bool simulateVision;
  final bool simulateAIEngine;
  final bool simulateThreats;
  final bool simulateSensors;
  final int updateIntervalMs;
  final double simulationSpeed;

  SimulationConfig copyWith({
    bool? enabled,
    bool? simulateBattery,
    bool? simulateConnectivity,
    bool? simulateVision,
    bool? simulateAIEngine,
    bool? simulateThreats,
    bool? simulateSensors,
    int? updateIntervalMs,
    double? simulationSpeed,
  }) {
    return SimulationConfig(
      enabled: enabled ?? this.enabled,
      simulateBattery: simulateBattery ?? this.simulateBattery,
      simulateConnectivity: simulateConnectivity ?? this.simulateConnectivity,
      simulateVision: simulateVision ?? this.simulateVision,
      simulateAIEngine: simulateAIEngine ?? this.simulateAIEngine,
      simulateThreats: simulateThreats ?? this.simulateThreats,
      simulateSensors: simulateSensors ?? this.simulateSensors,
      updateIntervalMs: updateIntervalMs ?? this.updateIntervalMs,
      simulationSpeed: simulationSpeed ?? this.simulationSpeed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulationConfig &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          simulateBattery == other.simulateBattery &&
          simulateConnectivity == other.simulateConnectivity &&
          simulateVision == other.simulateVision &&
          simulateAIEngine == other.simulateAIEngine &&
          simulateThreats == other.simulateThreats &&
          simulateSensors == other.simulateSensors &&
          updateIntervalMs == other.updateIntervalMs &&
          simulationSpeed == other.simulationSpeed;

  @override
  int get hashCode => Object.hash(
    enabled,
    simulateBattery,
    simulateConnectivity,
    simulateVision,
    simulateAIEngine,
    simulateThreats,
    simulateSensors,
    updateIntervalMs,
    simulationSpeed,
  );
}

/// Notifier for persisting and managing simulation configuration
class SimulationConfigNotifier extends StateNotifier<SimulationConfig> {
  static const _prefsKey = 'edith_simulation_config';

  SimulationConfigNotifier(this._prefs) : super(const SimulationConfig()) {
    _loadConfig();
  }

  final SharedPreferences _prefs;

  Future<void> _loadConfig() async {
    final enabled = _prefs.getBool('${_prefsKey}_enabled') ?? true;
    final simulateBattery = _prefs.getBool('${_prefsKey}_battery') ?? true;
    final simulateConnectivity = _prefs.getBool('${_prefsKey}_connectivity') ?? true;
    final simulateVision = _prefs.getBool('${_prefsKey}_vision') ?? true;
    final simulateAIEngine = _prefs.getBool('${_prefsKey}_ai_engine') ?? true;
    final simulateThreats = _prefs.getBool('${_prefsKey}_threats') ?? true;
    final simulateSensors = _prefs.getBool('${_prefsKey}_sensors') ?? true;
    final updateIntervalMs = _prefs.getInt('${_prefsKey}_interval') ?? 1000;
    final simulationSpeed = _prefs.getDouble('${_prefsKey}_speed') ?? 1.0;

    state = SimulationConfig(
      enabled: enabled,
      simulateBattery: simulateBattery,
      simulateConnectivity: simulateConnectivity,
      simulateVision: simulateVision,
      simulateAIEngine: simulateAIEngine,
      simulateThreats: simulateThreats,
      simulateSensors: simulateSensors,
      updateIntervalMs: updateIntervalMs,
      simulationSpeed: simulationSpeed,
    );
  }

  Future<void> updateConfig(SimulationConfig config) async {
    state = config;
    await _prefs.setBool('${_prefsKey}_enabled', config.enabled);
    await _prefs.setBool('${_prefsKey}_battery', config.simulateBattery);
    await _prefs.setBool('${_prefsKey}_connectivity', config.simulateConnectivity);
    await _prefs.setBool('${_prefsKey}_vision', config.simulateVision);
    await _prefs.setBool('${_prefsKey}_ai_engine', config.simulateAIEngine);
    await _prefs.setBool('${_prefsKey}_threats', config.simulateThreats);
    await _prefs.setBool('${_prefsKey}_sensors', config.simulateSensors);
    await _prefs.setInt('${_prefsKey}_interval', config.updateIntervalMs);
    await _prefs.setDouble('${_prefsKey}_speed', config.simulationSpeed);
  }

  Future<void> toggleEnabled() async {
    await updateConfig(state.copyWith(enabled: !state.enabled));
  }

  Future<void> setSimulationSpeed(int speed) async {
    await updateConfig(state.copyWith(simulationSpeed: speed.toDouble()));
  }

  Future<void> toggleSimulation() async {
    await updateConfig(state.copyWith(enabled: !state.enabled));
  }
}

/// Provider for simulation configuration
final simulationConfigProvider = StateNotifierProvider<SimulationConfigNotifier, SimulationConfig>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SimulationConfigNotifier(prefs);
});

/// Provider for whether simulation mode is enabled (convenience)
final simulationModeProvider = Provider<bool>((ref) {
  return ref.watch(simulationConfigProvider).enabled;
});