/// Dashboard providers using Riverpod
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

import '../dashboard_state.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/edith_theme.dart';

/// Battery info provider (stream-based)
final batteryInfoProvider = StreamProvider<BatteryInfo>((ref) async* {
  final simulation = ref.watch(simulationConfigProvider);

  if (simulation.enabled && simulation.simulateBattery) {
    // Simulated battery stream
    double level = 0.85;
    bool charging = false;
    final random = Random();

    yield BatteryInfo(
      level: level,
      isCharging: charging,
      health: 'Good',
      temperature: 32.5,
      voltage: 3.82,
      source: DataSource.simulated,
      estimatedRuntime: Duration(hours: (level * 8).round()),
    );

    final interval = Duration(milliseconds: (1000 / simulation.simulationSpeed).round());
    final streamController = StreamController<void>();

    Timer.periodic(interval, (_) {
      streamController.add(null);
    });

    await for (final _ in streamController.stream) {
      // Simulate battery drain/charge
      if (charging) {
        level = min(1.0, level + 0.01 * simulation.simulationSpeed);
        if (level >= 1.0) charging = false;
      } else {
        level = max(0.0, level - 0.002 * simulation.simulationSpeed);
        if (level <= 0.15) charging = true;
      }

      yield BatteryInfo(
        level: level,
        isCharging: charging,
        health: level > 0.2 ? 'Good' : 'Low',
        temperature: 32.5 + random.nextDouble() * 5,
        voltage: 3.82 - (1.0 - level) * 0.4,
        source: DataSource.simulated,
        estimatedRuntime: charging
            ? Duration(minutes: ((1.0 - level) * 120).round())
            : Duration(hours: (level * 8).round()),
      );
    }

    await streamController.close();
  } else {
    // Real battery stream
    final battery = Battery();
    yield* _realBatteryStream(battery);
  }
});

Stream<BatteryInfo> _realBatteryStream(Battery battery) async* {
  try {
    final level = await battery.batteryLevel;
    final state = await battery.batteryState;

    yield BatteryInfo(
      level: level / 100.0,
      isCharging: state == BatteryState.charging,
      health: 'Good',
      temperature: 0,
      voltage: 0,
      source: DataSource.live,
    );

    // Listen to battery state changes
    final streamController = StreamController<void>();

    final sub = battery.onBatteryStateChanged.listen((_) {
      streamController.add(null);
    });

    await for (final _ in streamController.stream) {
      final newLevel = await battery.batteryLevel;
      final newState = await battery.batteryState;

      yield BatteryInfo(
        level: newLevel / 100.0,
        isCharging: newState == BatteryState.charging,
        health: 'Good',
        temperature: 0,
        voltage: 0,
        source: DataSource.live,
      );
    }

    await sub.cancel();
    await streamController.close();
  } catch (e) {
    yield BatteryInfo(
      level: 0,
      isCharging: false,
      health: 'Unknown',
      temperature: 0,
      voltage: 0,
      source: DataSource.unavailable,
    );
  }
}

/// Connectivity info provider
final connectivityInfoProvider = StreamProvider<ConnectivityInfo>((ref) async* {
  final simulation = ref.watch(simulationConfigProvider);

  if (simulation.enabled && simulation.simulateConnectivity) {
    // Simulated connectivity
    bool connected = true;
    final types = ['WiFi', '5G', '4G', 'Ethernet'];
    int typeIndex = 0;
    final random = Random();

    yield ConnectivityInfo(
      isConnected: connected,
      connectionType: types[typeIndex],
      signalStrength: 85 + random.nextInt(15),
      bluetoothConnected: true,
      wifiConnected: true,
      source: DataSource.simulated,
      deviceName: 'E.D.I.T.H. Glasses',
      ipAddress: '192.168.1.100',
    );

    final interval = Duration(seconds: (5 / simulation.simulationSpeed).clamp(1, 30).round());
    final streamController = StreamController<void>();

    Timer.periodic(interval, (_) {
      streamController.add(null);
    });

    await for (final _ in streamController.stream) {
      // Occasionally change connection type
      if (random.nextDouble() < 0.1) {
        typeIndex = (typeIndex + 1) % types.length;
      }
      connected = random.nextDouble() > 0.05;

      yield ConnectivityInfo(
        isConnected: connected,
        connectionType: types[typeIndex],
        signalStrength: connected ? 50 + random.nextInt(50) : 0,
        bluetoothConnected: connected && random.nextDouble() > 0.1,
        wifiConnected: connected && types[typeIndex] != '5G' && types[typeIndex] != '4G',
        source: DataSource.simulated,
        deviceName: connected ? 'E.D.I.T.H. Glasses' : null,
        ipAddress: connected ? '192.168.1.100' : null,
      );
    }

    await streamController.close();
  } else {
    // Real connectivity would go here
    yield ConnectivityInfo(
      isConnected: false,
      connectionType: 'Unknown',
      signalStrength: 0,
      bluetoothConnected: false,
      wifiConnected: false,
      source: DataSource.unavailable,
    );
  }
});

/// Vision status provider
final visionStatusProvider = StreamProvider<VisionStatus>((ref) async* {
  final simulation = ref.watch(simulationConfigProvider);

  if (simulation.enabled && simulation.simulateVision) {
    final random = Random();
    CameraState cameraState = CameraState.active;
    double fps = 30.0;

    yield VisionStatus(
      isActive: true,
      cameraState: cameraState,
      detectionFps: fps,
      objectsDetected: 3 + random.nextInt(5),
      latencyMs: 25 + random.nextInt(20),
      source: DataSource.simulated,
      resolution: '1920x1080',
      fieldOfView: 90.0,
    );

    final interval = Duration(milliseconds: (1000 / simulation.simulationSpeed).round());
    final streamController = StreamController<void>();

    Timer.periodic(interval, (_) {
      streamController.add(null);
    });

    await for (final _ in streamController.stream) {
      // Simulate occasional state changes
      if (random.nextDouble() < 0.02) {
        final states = CameraState.values;
        cameraState = states[random.nextInt(states.length)];
      }

      fps = cameraState == CameraState.active
          ? 25.0 + random.nextDouble() * 10
          : 0;

      yield VisionStatus(
        isActive: cameraState == CameraState.active,
        cameraState: cameraState,
        detectionFps: fps,
        objectsDetected: cameraState == CameraState.active ? 2 + random.nextInt(8) : 0,
        latencyMs: cameraState == CameraState.active ? 20 + random.nextInt(30) : 0,
        source: DataSource.simulated,
        resolution: '1920x1080',
        fieldOfView: 90.0,
      );
    }

    await streamController.close();
  } else {
    yield VisionStatus(
      isActive: false,
      cameraState: CameraState.unavailable,
      detectionFps: 0,
      objectsDetected: 0,
      latencyMs: 0,
      source: DataSource.unavailable,
    );
  }
});

/// AI Engine status provider
final aiEngineStatusProvider = StreamProvider<AIEngineStatus>((ref) async* {
  final simulation = ref.watch(simulationConfigProvider);

  if (simulation.enabled && simulation.simulateAIEngine) {
    final random = Random();
    bool connected = true;

    yield AIEngineStatus(
      isConnected: connected,
      provider: 'HelpeX Backend',
      model: 'EDITH-Large-v2.4',
      latencyMs: 45 + random.nextInt(30),
      tokensPerSecond: 45.0 + random.nextDouble() * 20,
      contextUsage: 0.3 + random.nextDouble() * 0.4,
      source: DataSource.simulated,
    );

    final interval = Duration(seconds: (3 / simulation.simulationSpeed).clamp(1, 10).round());
    final streamController = StreamController<void>();

    Timer.periodic(interval, (_) {
      streamController.add(null);
    });

    await for (final _ in streamController.stream) {
      if (random.nextDouble() < 0.05) {
        connected = false;
      } else if (!connected && random.nextDouble() < 0.3) {
        connected = true;
      }

      yield AIEngineStatus(
        isConnected: connected,
        provider: connected ? 'HelpeX Backend' : 'Offline',
        model: connected ? 'EDITH-Large-v2.4' : 'N/A',
        latencyMs: connected ? 35 + random.nextInt(50) : 0,
        tokensPerSecond: connected ? 40.0 + random.nextDouble() * 30 : 0,
        contextUsage: connected ? 0.2 + random.nextDouble() * 0.5 : 0,
        source: DataSource.simulated,
        lastError: connected ? null : 'Connection timeout',
      );
    }

    await streamController.close();
  } else {
    yield AIEngineStatus(
      isConnected: false,
      provider: 'Unavailable',
      model: 'N/A',
      latencyMs: 0,
      tokensPerSecond: 0,
      contextUsage: 0,
      source: DataSource.unavailable,
    );
  }
});

/// System events provider
final systemEventsProvider = StreamProvider<List<SystemEvent>>((ref) async* {
  final simulation = ref.watch(simulationConfigProvider);
  final events = <SystemEvent>[
    SystemEvent(
      id: 'evt_001',
      type: SystemEventType.success,
      title: 'System Initialized',
      message: 'E.D.I.T.H. core systems online',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      component: 'Core',
    ),
    SystemEvent(
      id: 'evt_002',
      type: SystemEventType.info,
      title: 'Glasses Connected',
      message: 'E.D.I.T.H. V2.4 paired via Bluetooth',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      component: 'Connectivity',
    ),
  ];

  yield events;

  if (simulation.enabled) {
    final eventTypes = SystemEventType.values;
    final components = ['Core', 'Vision', 'AI Engine', 'Protection', 'Connectivity', 'Battery'];
    final messages = [
      'Sensor calibration complete',
      'New object detected: Person at 2.3m',
      'AI inference latency: 42ms',
      'Battery level: 72%',
      'Network latency: 18ms',
      'Thermal status: Nominal',
      'Firmware check: Up to date',
      'Threat scan: No anomalies',
    ];
    int eventCounter = 3;
    final random = Random();

    final interval = Duration(seconds: (10 / simulation.simulationSpeed).clamp(2, 30).round());
    final streamController = StreamController<void>();

    Timer.periodic(interval, (_) {
      streamController.add(null);
    });

    await for (final _ in streamController.stream) {
      final newEvent = SystemEvent(
        id: 'evt_${eventCounter.toString().padLeft(3, '0')}',
        type: eventTypes[random.nextInt(eventTypes.length)],
        title: components[random.nextInt(components.length)],
        message: messages[random.nextInt(messages.length)],
        timestamp: DateTime.now(),
        component: components[random.nextInt(components.length)],
      );

      events.insert(0, newEvent);
      if (events.length > 50) events.removeLast();
      eventCounter++;

      yield List.from(events);
    }

    await streamController.close();
  }
});

/// Component statuses provider (derived from other providers)
final componentStatusesProvider = Provider<List<ComponentStatus>>((ref) {
  final battery = ref.watch(batteryInfoProvider);
  final connectivity = ref.watch(connectivityInfoProvider);
  final vision = ref.watch(visionStatusProvider);
  final aiEngine = ref.watch(aiEngineStatusProvider);
  final simulation = ref.watch(simulationConfigProvider);

  return [
    ComponentStatus(
      id: 'battery',
      name: 'Battery',
      icon: Icons.battery_6_bar,
      status: battery.when(
        data: (b) => b.level > 0.5 ? SystemStatus.optimal :
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
        data: (b) => '${(b.level * 100).round()}% ${b.isCharging ? '⚡' : ''}',
        loading: () => 'Loading...',
        error: (_, __) => 'Unavailable',
      ),
      details: {
        'Health': battery.when(data: (b) => b.health, loading: () => '--', error: (_, __) => '--'),
        'Temp': battery.when(data: (b) => '${b.temperature.toStringAsFixed(1)}°C', loading: () => '--', error: (_, __) => '--'),
      },
    ),
    ComponentStatus(
      id: 'connectivity',
      name: 'Connectivity',
      icon: Icons.wifi,
      status: connectivity.when(
        data: (c) => c.isConnected ? SystemStatus.optimal : SystemStatus.critical,
        loading: () => SystemStatus.offline,
        error: (_, __) => SystemStatus.offline,
      ),
      dataSource: connectivity.when(
        data: (c) => c.source,
        loading: () => DataSource.unavailable,
        error: (_, __) => DataSource.unavailable,
      ),
      subtitle: connectivity.when(
        data: (c) => c.isConnected ? '${c.connectionType} • ${c.signalStrength}%' : 'Disconnected',
        loading: () => 'Loading...',
        error: (_, __) => 'Unavailable',
      ),
      details: {
        'Bluetooth': connectivity.when(data: (c) => c.bluetoothConnected ? 'Connected' : 'Disconnected', loading: () => '--', error: (_, __) => '--'),
        'WiFi': connectivity.when(data: (c) => c.wifiConnected ? 'Connected' : 'Disconnected', loading: () => '--', error: (_, __) => '--'),
      },
    ),
    ComponentStatus(
      id: 'vision',
      name: 'Vision System',
      icon: Icons.visibility,
      status: vision.when(
        data: (v) => v.isActive ? SystemStatus.optimal : SystemStatus.warning,
        loading: () => SystemStatus.offline,
        error: (_, __) => SystemStatus.offline,
      ),
      dataSource: vision.when(
        data: (v) => v.source,
        loading: () => DataSource.unavailable,
        error: (_, __) => DataSource.unavailable,
      ),
      subtitle: vision.when(
        data: (v) => v.isActive ? '${v.detectionFps.toStringAsFixed(0)} FPS • ${v.objectsDetected} objects' : 'Standby',
        loading: () => 'Loading...',
        error: (_, __) => 'Unavailable',
      ),
      details: {
        'Latency': vision.when(data: (v) => '${v.latencyMs}ms', loading: () => '--', error: (_, __) => '--'),
        'Camera': vision.when(data: (v) => v.cameraState.label, loading: () => '--', error: (_, __) => '--'),
      },
    ),
    ComponentStatus(
      id: 'ai_engine',
      name: 'AI Engine',
      icon: Icons.psychology,
      status: aiEngine.when(
        data: (a) => a.isConnected ? SystemStatus.optimal : SystemStatus.critical,
        loading: () => SystemStatus.offline,
        error: (_, __) => SystemStatus.offline,
      ),
      dataSource: aiEngine.when(
        data: (a) => a.source,
        loading: () => DataSource.unavailable,
        error: (_, __) => DataSource.unavailable,
      ),
      subtitle: aiEngine.when(
        data: (a) => a.isConnected ? '${a.latencyMs}ms • ${a.tokensPerSecond.toStringAsFixed(0)} tok/s' : 'Disconnected',
        loading: () => 'Loading...',
        error: (_, __) => 'Unavailable',
      ),
      details: {
        'Provider': aiEngine.when(data: (a) => a.provider, loading: () => '--', error: (_, __) => '--'),
        'Model': aiEngine.when(data: (a) => a.model, loading: () => '--', error: (_, __) => '--'),
        'Context': aiEngine.when(data: (a) => '${(a.contextUsage * 100).round()}%', loading: () => '--', error: (_, __) => '--'),
      },
    ),
    ComponentStatus(
      id: 'protection',
      name: 'Protection',
      icon: Icons.shield,
      status: simulation.enabled ? SystemStatus.simulated : SystemStatus.offline,
      dataSource: simulation.enabled ? DataSource.simulated : DataSource.unavailable,
      subtitle: simulation.enabled ? 'Simulation Active' : 'Unavailable',
      details: {
        'Mode': simulation.enabled ? 'Simulated' : 'Offline',
      },
    ),
    ComponentStatus(
      id: 'sensors',
      name: 'Sensors',
      icon: Icons.sensors,
      status: simulation.enabled && simulation.simulateSensors ? SystemStatus.simulated : SystemStatus.offline,
      dataSource: simulation.enabled && simulation.simulateSensors ? DataSource.simulated : DataSource.unavailable,
      subtitle: simulation.enabled && simulation.simulateSensors ? 'Simulated Data' : 'Unavailable',
      details: {
        'IMU': simulation.simulateSensors ? 'Active (Sim)' : 'Offline',
        'GPS': simulation.simulateSensors ? 'Active (Sim)' : 'Offline',
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