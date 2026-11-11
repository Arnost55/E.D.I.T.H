import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import '../../../core/providers/app_providers.dart';
import '../../core/theme/edith_theme.dart';

/// Vision system status
class VisionStatus {
  const VisionStatus({
    this.isActive = false,
    this.cameraPermission = false,
    this.isRecording = false,
    this.frameRate = 0,
    this.resolution = const Size(1920, 1080),
    this.zoomLevel = 1.0,
    this.focusMode = FocusMode.auto,
    this.detectedObjects = const [],
    this.sensorData = const SensorData(),
  });

  final bool isActive;
  final bool cameraPermission;
  final bool isRecording;
  final int frameRate;
  final Size resolution;
  final double zoomLevel;
  final FocusMode focusMode;
  final List<DetectedObject> detectedObjects;
  final SensorData sensorData;

  VisionStatus copyWith({
    bool? isActive,
    bool? cameraPermission,
    bool? isRecording,
    int? frameRate,
    Size? resolution,
    double? zoomLevel,
    FocusMode? focusMode,
    List<DetectedObject>? detectedObjects,
    SensorData? sensorData,
  }) {
    return VisionStatus(
      isActive: isActive ?? this.isActive,
      cameraPermission: cameraPermission ?? this.cameraPermission,
      isRecording: isRecording ?? this.isRecording,
      frameRate: frameRate ?? this.frameRate,
      resolution: resolution ?? this.resolution,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      focusMode: focusMode ?? this.focusMode,
      detectedObjects: detectedObjects ?? this.detectedObjects,
      sensorData: sensorData ?? this.sensorData,
    );
  }
}

enum FocusMode { auto, manual, locked, macro }

/// Detected object in vision system
class DetectedObject {
  const DetectedObject({
    required this.id,
    required this.label,
    required this.confidence,
    required this.bounds, // Normalized 0-1 rect
    required this.color,
    this.distanceMeters,
    this.velocity,
    this.classification = ObjectClassification.unknown,
  });

  final String id;
  final String label;
  final double confidence; // 0-1
  final Rect bounds;
  final Color color;
  final double? distanceMeters;
  final Offset? velocity;
  final ObjectClassification classification;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectedObject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          confidence == other.confidence &&
          bounds == other.bounds;

  @override
  int get hashCode => Object.hash(id, label, confidence, bounds);
}

enum ObjectClassification {
  unknown,
  person,
  vehicle,
  drone,
  aircraft,
  threat,
  landmark,
  navigation,
}

/// Sensor data from IMU
class SensorData {
  const SensorData({
    this.accelerometer = Offset.zero,
    this.gyroscope = Offset.zero,
    this.magnetometer = Offset.zero,
    this.orientation = 0.0,
    this.pitch = 0.0,
    this.roll = 0.0,
    this.timestamp = 0,
  });

  final Offset accelerometer;
  final Offset gyroscope;
  final Offset magnetometer;
  final double orientation; // Heading in degrees
  final double pitch; // Degrees
  final double roll; // Degrees
  final int timestamp;

  SensorData copyWith({
    Offset? accelerometer,
    Offset? gyroscope,
    Offset? magnetometer,
    double? orientation,
    double? pitch,
    double? roll,
    int? timestamp,
  }) {
    return SensorData(
      accelerometer: accelerometer ?? this.accelerometer,
      gyroscope: gyroscope ?? this.gyroscope,
      magnetometer: magnetometer ?? this.magnetometer,
      orientation: orientation ?? this.orientation,
      pitch: pitch ?? this.pitch,
      roll: roll ?? this.roll,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Notifier for vision status
class VisionStatusNotifier extends StateNotifier<VisionStatus> {
  final Ref _ref;
  Timer? _simulationTimer;
  Timer? _sensorTimer;
  Timer? _detectionTimer;
  final _random = Random();
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();

  VisionStatusNotifier(this._ref) : super(const VisionStatus()) {
    _startSimulation();
  }

  void _startSimulation() {
    _ref.listen(simulationConfigProvider, (prev, next) {
      if (next.simulateVision && next.enabled) {
        _startVisionSimulation();
        _startSensorSimulation();
        _startDetectionSimulation();
      } else {
        _stopAllSimulations();
        state = state.copyWith(isActive: false, frameRate: 0);
      }
    });

    final config = _ref.read(simulationConfigProvider);
    if (config.simulateVision && config.enabled) {
      _startVisionSimulation();
      _startSensorSimulation();
      _startDetectionSimulation();
    }
  }

  void _startVisionSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      // ~30 FPS simulation
      _frameCount++;
      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameTime).inMilliseconds;
      if (elapsed >= 1000) {
        state = state.copyWith(
          frameRate: _frameCount,
          isActive: true,
        );
        _frameCount = 0;
        _lastFrameTime = now;
      }
    });
  }

  void _startSensorSimulation() {
    _sensorTimer?.cancel();
    _sensorTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!state.isActive) return;

      // Simulate sensor data
      final orientation = (state.sensorData.orientation + _random.nextDouble() * 2 - 1) % 360;
      final pitch = (_random.nextDouble() - 0.5) * 10; // -5 to 5 degrees
      final roll = (_random.nextDouble() - 0.5) * 10;

      state = state.copyWith(
        sensorData: state.sensorData.copyWith(
          accelerometer: Offset(
            (_random.nextDouble() - 0.5) * 2,
            (_random.nextDouble() - 0.5) * 2,
          ),
          gyroscope: Offset(
            (_random.nextDouble() - 0.5) * 0.5,
            (_random.nextDouble() - 0.5) * 0.5,
          ),
          magnetometer: Offset(
            cos(orientation * pi / 180) * 50,
            sin(orientation * pi / 180) * 50,
          ),
          orientation: orientation,
          pitch: pitch,
          roll: roll,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  void _startDetectionSimulation() {
    _detectionTimer?.cancel();
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!state.isActive) return;

      // Simulate object detection
      final shouldDetect = _random.nextDouble() < 0.3; // 30% chance per cycle
      if (shouldDetect) {
        final numObjects = _random.nextInt(3) + 1;
        final objects = <DetectedObject>[];

        for (int i = 0; i < numObjects; i++) {
          final classifications = ObjectClassification.values;
          final classification = classifications[_random.nextInt(classifications.length - 1) + 1]; // Skip unknown
          final labels = _getLabelsForClassification(classification);
          final label = labels[_random.nextInt(labels.length)];

          objects.add(DetectedObject(
            id: 'obj_${DateTime.now().millisecondsSinceEpoch}_$i',
            label: label,
            confidence: 0.7 + _random.nextDouble() * 0.3,
            bounds: Rect.fromLTWH(
              _random.nextDouble() * 0.7,
              _random.nextDouble() * 0.7,
              0.15 + _random.nextDouble() * 0.2,
              0.15 + _random.nextDouble() * 0.2,
            ),
            color: _getColorForClassification(classification),
            distanceMeters: 5 + _random.nextDouble() * 50,
            classification: classification,
          ));
        }

        state = state.copyWith(detectedObjects: objects);
      } else if (_random.nextDouble() < 0.1) {
        // Clear detections occasionally
        state = state.copyWith(detectedObjects: []);
      }
    });
  }

  void _stopAllSimulations() {
    _simulationTimer?.cancel();
    _sensorTimer?.cancel();
    _detectionTimer?.cancel();
    _simulationTimer = null;
    _sensorTimer = null;
    _detectionTimer = null;
  }

  List<String> _getLabelsForClassification(ObjectClassification classification) {
    switch (classification) {
      case ObjectClassification.person:
        return ['Person', 'Civilian', 'Target', 'Hostile'];
      case ObjectClassification.vehicle:
        return ['Vehicle', 'Car', 'Truck', 'Motorcycle'];
      case ObjectClassification.drone:
        return ['Drone', 'UAV', 'Quadcopter', 'Surveillance Drone'];
      case ObjectClassification.aircraft:
        return ['Aircraft', 'Helicopter', 'Jet', 'Cargo Plane'];
      case ObjectClassification.threat:
        return ['Threat', 'Missile', 'Projectile', 'Explosive'];
      case ObjectClassification.landmark:
        return ['Building', 'Tower', 'Bridge', 'Monument'];
      case ObjectClassification.navigation:
        return ['Waypoint', 'Marker', 'Beacon', 'Nav Point'];
      default:
        return ['Unknown Object'];
    }
  }

  Color _getColorForClassification(ObjectClassification classification) {
    switch (classification) {
      case ObjectClassification.person:
        return EdithColors.accent;
      case ObjectClassification.vehicle:
        return EdithColors.info;
      case ObjectClassification.drone:
        return EdithColors.warning;
      case ObjectClassification.aircraft:
        return EdithColors.accentStrong;
      case ObjectClassification.threat:
        return EdithColors.danger;
      case ObjectClassification.landmark:
        return EdithColors.success;
      case ObjectClassification.navigation:
        return EdithColors.info;
      default:
        return EdithColors.textMuted;
    }
  }

  void setCameraPermission(bool granted) {
    state = state.copyWith(cameraPermission: granted);
  }

  void toggleRecording() {
    state = state.copyWith(isRecording: !state.isRecording);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoomLevel: zoom.clamp(1.0, 10.0));
  }

  void setFocusMode(FocusMode mode) {
    state = state.copyWith(focusMode: mode);
  }

  @override
  void dispose() {
    _stopAllSimulations();
    super.dispose();
  }
}

/// Providers
final visionStatusProvider = StateNotifierProvider<VisionStatusNotifier, VisionStatus>((ref) {
  return VisionStatusNotifier(ref);
});

/// Camera controller provider (placeholder for real camera integration)
final cameraControllerProvider = Provider<dynamic>((ref) {
  // Will be implemented with camera package when hardware is available
  return null;
});