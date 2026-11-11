/// Dashboard state models and enums
import 'package:flutter/material.dart';
import '../../core/providers/app_providers.dart';

/// Data source indicator for status items
enum DataSource {
  live('Live', Icons.radio_button_checked, Colors.green),
  simulated('Simulated', Icons.science_outlined, Colors.amber),
  unavailable('Unavailable', Icons.radio_button_off, Colors.grey);

  const DataSource(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// System status levels
enum SystemStatus {
  optimal('Optimal', Colors.green),
  warning('Warning', Colors.amber),
  critical('Critical', Colors.red),
  offline('Offline', Colors.grey),
  simulated('Simulated', Colors.blue);

  const SystemStatus(this.label, this.color);

  final String label;
  final Color color;
}

/// System event types
enum SystemEventType {
  info('Info', Icons.info_outline, Colors.blue),
  warning('Warning', Icons.warning_amber_rounded, Colors.amber),
  error('Error', Icons.error_outline, Colors.red),
  success('Success', Icons.check_circle_outline, Colors.green),
  simulation('Simulation', Icons.science_outlined, Colors.purple);

  const SystemEventType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// System event model
class SystemEvent {
  const SystemEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.component,
    this.metadata = const {},
  });

  final String id;
  final SystemEventType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? component;
  final Map<String, dynamic> metadata;

  SystemEvent copyWith({
    String? id,
    SystemEventType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    String? component,
    Map<String, dynamic>? metadata,
  }) {
    return SystemEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      component: component ?? this.component,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          message == other.message &&
          timestamp == other.timestamp &&
          component == other.component;

  @override
  int get hashCode => Object.hash(id, type, title, message, timestamp, component);
}

/// Battery information
class BatteryInfo {
  const BatteryInfo({
    required this.level,
    required this.isCharging,
    required this.health,
    required this.temperature,
    required this.voltage,
    required this.source,
    this.estimatedRuntime,
  });

  final double level; // 0.0 to 1.0
  final bool isCharging;
  final String health;
  final double temperature; // Celsius
  final double voltage; // Volts
  final DataSource source;
  final Duration? estimatedRuntime;

  BatteryInfo copyWith({
    double? level,
    bool? isCharging,
    String? health,
    double? temperature,
    double? voltage,
    DataSource? source,
    Duration? estimatedRuntime,
  }) {
    return BatteryInfo(
      level: level ?? this.level,
      isCharging: isCharging ?? this.isCharging,
      health: health ?? this.health,
      temperature: temperature ?? this.temperature,
      voltage: voltage ?? this.voltage,
      source: source ?? this.source,
      estimatedRuntime: estimatedRuntime ?? this.estimatedRuntime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatteryInfo &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          isCharging == other.isCharging &&
          health == other.health &&
          temperature == other.temperature &&
          voltage == other.voltage &&
          source == other.source &&
          estimatedRuntime == other.estimatedRuntime;

  @override
  int get hashCode => Object.hash(
    level,
    isCharging,
    health,
    temperature,
    voltage,
    source,
    estimatedRuntime,
  );
}

/// Connectivity information
class ConnectivityInfo {
  const ConnectivityInfo({
    required this.isConnected,
    required this.connectionType,
    required this.signalStrength,
    required this.bluetoothConnected,
    required this.wifiConnected,
    required this.source,
    this.deviceName,
    this.ipAddress,
  });

  final bool isConnected;
  final String connectionType; // wifi, mobile, ethernet, bluetooth
  final int signalStrength; // 0-100
  final bool bluetoothConnected;
  final bool wifiConnected;
  final DataSource source;
  final String? deviceName;
  final String? ipAddress;

  ConnectivityInfo copyWith({
    bool? isConnected,
    String? connectionType,
    int? signalStrength,
    bool? bluetoothConnected,
    bool? wifiConnected,
    DataSource? source,
    String? deviceName,
    String? ipAddress,
  }) {
    return ConnectivityInfo(
      isConnected: isConnected ?? this.isConnected,
      connectionType: connectionType ?? this.connectionType,
      signalStrength: signalStrength ?? this.signalStrength,
      bluetoothConnected: bluetoothConnected ?? this.bluetoothConnected,
      wifiConnected: wifiConnected ?? this.wifiConnected,
      source: source ?? this.source,
      deviceName: deviceName ?? this.deviceName,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectivityInfo &&
          runtimeType == other.runtimeType &&
          isConnected == other.isConnected &&
          connectionType == other.connectionType &&
          signalStrength == other.signalStrength &&
          bluetoothConnected == other.bluetoothConnected &&
          wifiConnected == other.wifiConnected &&
          source == other.source &&
          deviceName == other.deviceName &&
          ipAddress == other.ipAddress;

  @override
  int get hashCode => Object.hash(
    isConnected,
    connectionType,
    signalStrength,
    bluetoothConnected,
    wifiConnected,
    source,
    deviceName,
    ipAddress,
  );
}

/// Vision system status
class VisionStatus {
  const VisionStatus({
    required this.isActive,
    required this.cameraState,
    required this.detectionFps,
    required this.objectsDetected,
    required this.latencyMs,
    required this.source,
    this.resolution,
    this.fieldOfView,
  });

  final bool isActive;
  final CameraState cameraState;
  final double detectionFps;
  final int objectsDetected;
  final int latencyMs;
  final DataSource source;
  final String? resolution;
  final double? fieldOfView;

  VisionStatus copyWith({
    bool? isActive,
    CameraState? cameraState,
    double? detectionFps,
    int? objectsDetected,
    int? latencyMs,
    DataSource? source,
    String? resolution,
    double? fieldOfView,
  }) {
    return VisionStatus(
      isActive: isActive ?? this.isActive,
      cameraState: cameraState ?? this.cameraState,
      detectionFps: detectionFps ?? this.detectionFps,
      objectsDetected: objectsDetected ?? this.objectsDetected,
      latencyMs: latencyMs ?? this.latencyMs,
      source: source ?? this.source,
      resolution: resolution ?? this.resolution,
      fieldOfView: fieldOfView ?? this.fieldOfView,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisionStatus &&
          runtimeType == other.runtimeType &&
          isActive == other.isActive &&
          cameraState == other.cameraState &&
          detectionFps == other.detectionFps &&
          objectsDetected == other.objectsDetected &&
          latencyMs == other.latencyMs &&
          source == other.source &&
          resolution == other.resolution &&
          fieldOfView == other.fieldOfView;

  @override
  int get hashCode => Object.hash(
    isActive,
    cameraState,
    detectionFps,
    objectsDetected,
    latencyMs,
    source,
    resolution,
    fieldOfView,
  );
}

enum CameraState {
  active('Active', Icons.videocam),
  standby('Standby', Icons.videocam_off),
  error('Error', Icons.error),
  permissionDenied('Permission Denied', Icons.lock),
  unavailable('Unavailable', Icons.videocam_off);

  const CameraState(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// AI Engine status
class AIEngineStatus {
  const AIEngineStatus({
    required this.isConnected,
    required this.provider,
    required this.model,
    required this.latencyMs,
    required this.tokensPerSecond,
    required this.contextUsage,
    required this.source,
    this.lastError,
  });

  final bool isConnected;
  final String provider;
  final String model;
  final int latencyMs;
  final double tokensPerSecond;
  final double contextUsage; // 0.0 to 1.0
  final DataSource source;
  final String? lastError;

  AIEngineStatus copyWith({
    bool? isConnected,
    String? provider,
    String? model,
    int? latencyMs,
    double? tokensPerSecond,
    double? contextUsage,
    DataSource? source,
    String? lastError,
  }) {
    return AIEngineStatus(
      isConnected: isConnected ?? this.isConnected,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      latencyMs: latencyMs ?? this.latencyMs,
      tokensPerSecond: tokensPerSecond ?? this.tokensPerSecond,
      contextUsage: contextUsage ?? this.contextUsage,
      source: source ?? this.source,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIEngineStatus &&
          runtimeType == other.runtimeType &&
          isConnected == other.isConnected &&
          provider == other.provider &&
          model == other.model &&
          latencyMs == other.latencyMs &&
          tokensPerSecond == other.tokensPerSecond &&
          contextUsage == other.contextUsage &&
          source == other.source &&
          lastError == other.lastError;

  @override
  int get hashCode => Object.hash(
    isConnected,
    provider,
    model,
    latencyMs,
    tokensPerSecond,
    contextUsage,
    source,
    lastError,
  );
}


/// Quick action definition
class QuickAction {
  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.requiresConfirmation = false,
    this.confirmationMessage,
    this.isEnabled = true,
    this.dataSource = DataSource.live,
    this.badge,
  });

  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool requiresConfirmation;
  final String? confirmationMessage;
  final bool isEnabled;
  final DataSource dataSource;
  final String? badge;

  QuickAction copyWith({
    String? id,
    String? label,
    IconData? icon,
    VoidCallback? onTap,
    Color? color,
    bool? requiresConfirmation,
    String? confirmationMessage,
    bool? isEnabled,
    DataSource? dataSource,
    String? badge,
  }) {
    return QuickAction(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
      color: color ?? this.color,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      confirmationMessage: confirmationMessage ?? this.confirmationMessage,
      isEnabled: isEnabled ?? this.isEnabled,
      dataSource: dataSource ?? this.dataSource,
      badge: badge ?? this.badge,
    );
  }
}

/// Component status for the system overview
class ComponentStatus {
  const ComponentStatus({
    required this.id,
    required this.name,
    required this.icon,
    required this.status,
    required this.dataSource,
    this.details = const {},
    this.subtitle,
    this.isCritical = false,
  });

  final String id;
  final String name;
  final IconData icon;
  final SystemStatus status;
  final DataSource dataSource;
  final Map<String, String> details;
  final String? subtitle;
  final bool isCritical;

  ComponentStatus copyWith({
    String? id,
    String? name,
    IconData? icon,
    SystemStatus? status,
    DataSource? dataSource,
    Map<String, String>? details,
    String? subtitle,
    bool? isCritical,
  }) {
    return ComponentStatus(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      dataSource: dataSource ?? this.dataSource,
      details: details ?? this.details,
      subtitle: subtitle ?? this.subtitle,
      isCritical: isCritical ?? this.isCritical,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentStatus &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          status == other.status &&
          dataSource == other.dataSource &&
          details == other.details &&
          subtitle == other.subtitle &&
          isCritical == other.isCritical;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    status,
    dataSource,
    details,
    subtitle,
    isCritical,
  );
}

/// Aggregated dashboard state
class DashboardState {
  const DashboardState({
    this.battery,
    this.connectivity,
    this.vision,
    this.aiEngine,
    this.events = const [],
    this.components = const [],
    this.quickActions = const [],
    this.simulation = const SimulationConfig(),
    this.lastUpdated,
    this.isLoading = false,
  });

  final BatteryInfo? battery;
  final ConnectivityInfo? connectivity;
  final VisionStatus? vision;
  final AIEngineStatus? aiEngine;
  final List<SystemEvent> events;
  final List<ComponentStatus> components;
  final List<QuickAction> quickActions;
  final SimulationConfig simulation;
  final DateTime? lastUpdated;
  final bool isLoading;

  DashboardState copyWith({
    BatteryInfo? battery,
    ConnectivityInfo? connectivity,
    VisionStatus? vision,
    AIEngineStatus? aiEngine,
    List<SystemEvent>? events,
    List<ComponentStatus>? components,
    List<QuickAction>? quickActions,
    SimulationConfig? simulation,
    DateTime? lastUpdated,
    bool? isLoading,
  }) {
    return DashboardState(
      battery: battery ?? this.battery,
      connectivity: connectivity ?? this.connectivity,
      vision: vision ?? this.vision,
      aiEngine: aiEngine ?? this.aiEngine,
      events: events ?? this.events,
      components: components ?? this.components,
      quickActions: quickActions ?? this.quickActions,
      simulation: simulation ?? this.simulation,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}