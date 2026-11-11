/// Dashboard providers using Riverpod
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

import '../dashboard_state.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/edith_theme.dart';

/// Battery info provider (stream-based)
final batteryInfoProvider = StreamProvider<BatteryInfo>((ref) async* {
  final battery = Battery();
  try {
    while (true) {
      final level = await battery.batteryLevel;
      final state = await battery.batteryState;
      yield BatteryInfo(
        level: level / 100.0,
        isCharging: state == BatteryState.charging,
        health: 'Not reported by phone',
        temperature: 0,
        voltage: 0,
        source: DataSource.live,
      );
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  } catch (_) {
    yield BatteryInfo(
      level: 0,
      isCharging: false,
      health: 'Unknown',
      temperature: 0,
      voltage: 0,
      source: DataSource.unavailable,
    );
  }
});

/// Connectivity info provider
final connectivityInfoProvider = StreamProvider<ConnectivityInfo>((ref) async* {
  yield ConnectivityInfo(isConnected: false, connectionType: 'Not monitored',
    signalStrength: 0, bluetoothConnected: false, wifiConnected: false,
    source: DataSource.unavailable);
});

/// Vision status provider
final visionStatusProvider = StreamProvider<VisionStatus>((ref) async* {
  yield VisionStatus(isActive: false, cameraState: CameraState.unavailable,
    detectionFps: 0, objectsDetected: 0, latencyMs: 0,
    source: DataSource.unavailable);
});

/// AI Engine status provider
final aiEngineStatusProvider = StreamProvider<AIEngineStatus>((ref) async* {
  yield AIEngineStatus(isConnected: false, provider: 'Not configured',
    model: 'Not configured', latencyMs: 0, tokensPerSecond: 0,
    contextUsage: 0, source: DataSource.unavailable);
});

/// System events provider
final systemEventsProvider = StreamProvider<List<SystemEvent>>((ref) async* {
  yield const <SystemEvent>[];
});

/// Component statuses provider (derived from other providers)
final componentStatusesProvider = Provider<List<ComponentStatus>>((ref) {
  final battery = ref.watch(batteryInfoProvider);
  final connectivity = ref.watch(connectivityInfoProvider);
  final vision = ref.watch(visionStatusProvider);
  final aiEngine = ref.watch(aiEngineStatusProvider);

  return [
    ComponentStatus(
      id: 'battery',
      name: 'Battery',
      icon: Icons.battery_6_bar,
      status: battery.when(
        data: (b) => b.source != DataSource.live ? SystemStatus.offline : b.level > 0.5 ? SystemStatus.optimal :
              b.level > 0.2 ? SystemStatus.warning : SystemStatus.critical,
        loading: () => SystemStatus.offline,
        error: (_, __) => SystemStatus.offline,
      ),
      dataSource: battery.when(
        data: (b) => b.source,
        loading: () => DataSource.unavailable,
        error: (_, __) => DataSource.unavailable,
      ),
      subtitle: battery.when(
        data: (b) => b.source == DataSource.live
            ? '${(b.level * 100).round()}%${b.isCharging ? ' • Charging' : ''}'
            : 'Unavailable',
        loading: () => 'Loading...',
        error: (_, __) => 'Unavailable',
      ),
      details: {
        'Health': battery.when(data: (b) => b.health, loading: () => '--', error: (_, __) => '--'),
        'Source': battery.when(data: (b) => b.source == DataSource.live ? 'Phone battery' : 'Unavailable', loading: () => '--', error: (_, __) => '--'),
      },
    ),
    ComponentStatus(
      id: 'connectivity',
      name: 'Connectivity',
      icon: Icons.wifi,
      status: connectivity.when(
        data: (c) => c.source == DataSource.live && c.isConnected ? SystemStatus.optimal : SystemStatus.offline,
        loading: () => SystemStatus.offline,
        error: (_, __) => SystemStatus.offline,
      ),
      dataSource: connectivity.when(
        data: (c) => c.source,
        loading: () => DataSource.unavailable,
        error: (_, __) => DataSource.unavailable,
      ),
      subtitle: connectivity.when(
        data: (c) => c.source == DataSource.live ? (c.isConnected ? c.connectionType : 'Disconnected') : 'Not monitored',
        loading: () => 'Loading...',
        error: (_, __) => 'Unavailable',
      ),
      details: {
        'Bluetooth': connectivity.when(data: (c) => c.source == DataSource.live ? (c.bluetoothConnected ? 'Connected' : 'Disconnected') : 'Not monitored', loading: () => '--', error: (_, __) => '--'),
        'WiFi': connectivity.when(data: (c) => c.source == DataSource.live ? (c.wifiConnected ? 'Connected' : 'Disconnected') : 'Not monitored', loading: () => '--', error: (_, __) => '--'),
      },
    ),
    ComponentStatus(
      id: 'vision',
      name: 'Vision System',
      icon: Icons.visibility,
      status: vision.when(
        data: (v) => v.source == DataSource.live && v.isActive ? SystemStatus.optimal : SystemStatus.offline,
        loading: () => SystemStatus.offline,
        error: (_, __) => SystemStatus.offline,
      ),
      dataSource: vision.when(
        data: (v) => v.source,
        loading: () => DataSource.unavailable,
        error: (_, __) => DataSource.unavailable,
      ),
      subtitle: vision.when(
        data: (v) => v.source == DataSource.live && v.isActive ? '${v.detectionFps.toStringAsFixed(0)} FPS • ${v.objectsDetected} objects' : 'Camera integration unavailable',
        loading: () => 'Loading...',
        error: (_, __) => 'Unavailable',
      ),
      details: {
        'Latency': vision.when(data: (v) => v.source == DataSource.live ? '${v.latencyMs}ms' : 'Not measured', loading: () => '--', error: (_, __) => '--'),
        'Camera': vision.when(data: (v) => v.source == DataSource.live ? v.cameraState.label : 'Not running', loading: () => '--', error: (_, __) => '--'),
      },
    ),
    ComponentStatus(
      id: 'ai_engine',
      name: 'AI Engine',
      icon: Icons.psychology,
      status: aiEngine.when(
        data: (a) => a.source == DataSource.live && a.isConnected ? SystemStatus.optimal : SystemStatus.offline,
        loading: () => SystemStatus.offline,
        error: (_, __) => SystemStatus.offline,
      ),
      dataSource: aiEngine.when(
        data: (a) => a.source,
        loading: () => DataSource.unavailable,
        error: (_, __) => DataSource.unavailable,
      ),
      subtitle: aiEngine.when(
        data: (a) => a.source == DataSource.live ? (a.isConnected ? '${a.latencyMs}ms • ${a.tokensPerSecond.toStringAsFixed(0)} tok/s' : 'Disconnected') : 'Not configured',
        loading: () => 'Loading...',
        error: (_, __) => 'Unavailable',
      ),
      details: {
        'Provider': aiEngine.when(data: (a) => a.provider, loading: () => '--', error: (_, __) => '--'),
        'Model': aiEngine.when(data: (a) => a.model, loading: () => '--', error: (_, __) => '--'),
        'Context': aiEngine.when(data: (a) => a.source == DataSource.live ? '${(a.contextUsage * 100).round()}%' : 'Not measured', loading: () => '--', error: (_, __) => '--'),
      },
    ),
    ComponentStatus(
      id: 'protection',
      name: 'Protection',
      icon: Icons.shield,
      status: SystemStatus.offline,
      dataSource: DataSource.unavailable,
      subtitle: 'Not configured',
      details: {
        'Mode': 'Not configured',
      },
    ),
    ComponentStatus(
      id: 'sensors',
      name: 'Sensors',
      icon: Icons.sensors,
      status: SystemStatus.offline,
      dataSource: DataSource.unavailable,
      subtitle: 'Not monitored',
      details: {
        'IMU': 'Not monitored',
        'GPS': 'Not monitored',
      },
    ),
  ];
});

/// Quick actions provider
final quickActionsProvider = Provider<List<QuickAction>>((ref) {
  final simulation = ref.watch(simulationConfigProvider);
  final battery = ref.watch(batteryInfoProvider);
  final connectivity = ref.watch(connectivityInfoProvider);

  return [
    QuickAction(
      id: 'protection_scan',
      label: 'Protection Scan',
      icon: Icons.radar,
      onTap: () {},
      color: EdithColors.accentStrong,
      requiresConfirmation: false,
      dataSource: simulation.enabled ? DataSource.simulated : DataSource.unavailable,
      badge: simulation.enabled ? 'SIM' : 'N/A',
    ),
    QuickAction(
      id: 'vision_toggle',
      label: 'Vision HUD',
      icon: Icons.visibility,
      onTap: () {},
      color: EdithColors.accent,
      dataSource: simulation.enabled ? DataSource.simulated : DataSource.unavailable,
      badge: simulation.enabled ? 'SIM' : 'N/A',
    ),
    QuickAction(
      id: 'device_pair',
      label: 'Pair Device',
      icon: Icons.bluetooth_searching,
      onTap: () {},
      color: EdithColors.accentMuted,
      dataSource: DataSource.live,
    ),
    QuickAction(
      id: 'diagnostics',
      label: 'Run Diagnostics',
      icon: Icons.medical_services,
      onTap: () {},
      requiresConfirmation: true,
      confirmationMessage: 'Run full system diagnostics?',
      dataSource: DataSource.live,
    ),
    QuickAction(
      id: 'simulation_toggle',
      label: simulation.enabled ? 'Disable Sim' : 'Enable Sim',
      icon: simulation.enabled ? Icons.science_outlined : Icons.science_outlined,
      onTap: () => ref.read(simulationConfigProvider.notifier).toggleEnabled(),
      color: simulation.enabled ? EdithColors.statusWarning : EdithColors.statusLive,
      dataSource: DataSource.live,
    ),
    QuickAction(
      id: 'refresh',
      label: 'Refresh Data',
      icon: Icons.refresh,
      onTap: () => ref.invalidate(batteryInfoProvider),
      dataSource: DataSource.live,
    ),
  ];
});

/// Aggregated dashboard state notifier
final dashboardStateProvider = StateNotifierProvider<DashboardStateNotifier, DashboardState>((ref) {
  return DashboardStateNotifier(ref);
});

class DashboardStateNotifier extends StateNotifier<DashboardState> {
  final Ref _ref;
  late final List<ProviderSubscription<dynamic>> _subscriptions;

  DashboardStateNotifier(this._ref) : super(const DashboardState()) {
    _subscriptions = [];
    _initializeSubscriptions();
  }

  void _initializeSubscriptions() {
    _subscriptions.add(
      _ref.listen(batteryInfoProvider, (_, next) {
        next.when(
          data: (battery) => state = state.copyWith(battery: battery, lastUpdated: DateTime.now()),
          loading: () {},
          error: (_, __) {},
        );
      }),
    );

    _subscriptions.add(
      _ref.listen(connectivityInfoProvider, (_, next) {
        next.when(
          data: (connectivity) => state = state.copyWith(connectivity: connectivity, lastUpdated: DateTime.now()),
          loading: () {},
          error: (_, __) {},
        );
      }),
    );

    _subscriptions.add(
      _ref.listen(visionStatusProvider, (_, next) {
        next.when(
          data: (vision) => state = state.copyWith(vision: vision, lastUpdated: DateTime.now()),
          loading: () {},
          error: (_, __) {},
        );
      }),
    );

    _subscriptions.add(
      _ref.listen(aiEngineStatusProvider, (_, next) {
        next.when(
          data: (aiEngine) => state = state.copyWith(aiEngine: aiEngine, lastUpdated: DateTime.now()),
          loading: () {},
          error: (_, __) {},
        );
      }),
    );

    _subscriptions.add(
      _ref.listen(systemEventsProvider, (_, next) {
        next.when(
          data: (events) => state = state.copyWith(events: events),
          loading: () {},
          error: (_, __) {},
        );
      }),
    );

    _subscriptions.add(
      _ref.listen(simulationConfigProvider, (_, next) {
        state = state.copyWith(simulation: next);
      }),
    );
  }

  void refresh() {
    _ref.invalidate(batteryInfoProvider);
    _ref.invalidate(connectivityInfoProvider);
    _ref.invalidate(visionStatusProvider);
    _ref.invalidate(aiEngineStatusProvider);
    _ref.invalidate(systemEventsProvider);
    state = state.copyWith(isLoading: true, lastUpdated: DateTime.now());

    // Reset loading after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    });
  }

  void addCustomEvent(SystemEvent event) {
    state = state.copyWith(events: [event, ...state.events]);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.close();
    }
    super.dispose();
  }
}
