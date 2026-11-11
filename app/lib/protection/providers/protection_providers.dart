import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import '../../../core/providers/app_providers.dart';
import '../../core/theme/edith_theme.dart';

/// Protection system status
class ProtectionStatus {
  const ProtectionStatus({
    this.isActive = false,
    this.threatLevel = ThreatLevel.none,
    this.activeThreats = const [],
    this.sectorStatuses = const {},
    this.shieldIntegrity = 100.0,
    this.empHardening = true,
    this.kineticBarrier = true,
    this.lastScan = 0,
    this.scanProgress = 0.0,
    this.isScanning = false,
  });

  final bool isActive;
  final ThreatLevel threatLevel;
  final List<Threat> activeThreats;
  final Map<BodySector, SectorStatus> sectorStatuses;
  final double shieldIntegrity; // 0-100
  final bool empHardening;
  final bool kineticBarrier;
  final int lastScan;
  final double scanProgress; // 0-1
  final bool isScanning;

  ProtectionStatus copyWith({
    bool? isActive,
    ThreatLevel? threatLevel,
    List<Threat>? activeThreats,
    Map<BodySector, SectorStatus>? sectorStatuses,
    double? shieldIntegrity,
    bool? empHardening,
    bool? kineticBarrier,
    int? lastScan,
    double? scanProgress,
    bool? isScanning,
  }) {
    return ProtectionStatus(
      isActive: isActive ?? this.isActive,
      threatLevel: threatLevel ?? this.threatLevel,
      activeThreats: activeThreats ?? this.activeThreats,
      sectorStatuses: sectorStatuses ?? this.sectorStatuses,
      shieldIntegrity: shieldIntegrity ?? this.shieldIntegrity,
      empHardening: empHardening ?? this.empHardening,
      kineticBarrier: kineticBarrier ?? this.kineticBarrier,
      lastScan: lastScan ?? this.lastScan,
      scanProgress: scanProgress ?? this.scanProgress,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

enum ThreatLevel {
  none(0, 'NONE', 'No threats detected'),
  low(1, 'LOW', 'Minor anomalies detected'),
  medium(2, 'MEDIUM', 'Potential threats identified'),
  high(3, 'HIGH', 'Imminent threat detected'),
  critical(4, 'CRITICAL', 'Active engagement required');

  const ThreatLevel(this.value, this.label, this.description);
  final int value;
  final String label;
  final String description;

  Color get color {
    switch (this) {
      case ThreatLevel.none:
        return EdithColors.success;
      case ThreatLevel.low:
        return EdithColors.info;
      case ThreatLevel.medium:
        return EdithColors.warning;
      case ThreatLevel.high:
        return EdithColors.danger;
      case ThreatLevel.critical:
        return EdithColors.danger;
    }
  }
}

/// Body sectors for protection monitoring
enum BodySector {
  head('Head', 'HEAD', Icons.circle_outlined),
  neck('Neck', 'NECK', Icons.more_horiz_outlined),
  chest('Chest', 'CHEST', Icons.favorite_outline),
  abdomen('Abdomen', 'ABDOMEN', Icons.center_focus_weak_outlined),
  leftArm('Left Arm', 'L-ARM', Icons.west_outlined),
  rightArm('Right Arm', 'R-ARM', Icons.east_outlined),
  leftLeg('Left Leg', 'L-LEG', Icons.keyboard_arrow_down_outlined),
  rightLeg('Right Leg', 'R-LEG', Icons.keyboard_arrow_down_outlined),
  upperBack('Upper Back', 'U-BACK', Icons.keyboard_arrow_up_outlined),
  lowerBack('Lower Back', 'L-BACK', Icons.keyboard_arrow_down_outlined);

  const BodySector(this.name, this.shortName, this.icon);
  final String name;
  final String shortName;
  final IconData icon;

  // Relative position on body diagram (normalized 0-1)
  Offset get position {
    switch (this) {
      case BodySector.head:
        return const Offset(0.5, 0.08);
      case BodySector.neck:
        return const Offset(0.5, 0.18);
      case BodySector.chest:
        return const Offset(0.5, 0.3);
      case BodySector.abdomen:
        return const Offset(0.5, 0.48);
      case BodySector.leftArm:
        return const Offset(0.12, 0.35);
      case BodySector.rightArm:
        return const Offset(0.88, 0.35);
      case BodySector.upperBack:
        return const Offset(0.5, 0.32);
      case BodySector.lowerBack:
        return const Offset(0.5, 0.55);
      case BodySector.leftLeg:
        return const Offset(0.35, 0.85);
      case BodySector.rightLeg:
        return const Offset(0.65, 0.85);
    }
  }
}

/// Sector status
class SectorStatus {
  const SectorStatus({
    this.sector = BodySector.head,
    this.integrity = 100.0,
    this.threatLevel = ThreatLevel.none,
    this.activeThreats = const [],
    this.shieldActive = true,
    this.temperature = 37.0,
    this.heartRate = 72,
  });

  final BodySector sector;
  final double integrity; // 0-100
  final ThreatLevel threatLevel;
  final List<Threat> activeThreats;
  final bool shieldActive;
  final double temperature; // Celsius
  final int heartRate; // BPM (for chest sector)

  SectorStatus copyWith({
    BodySector? sector,
    double? integrity,
    ThreatLevel? threatLevel,
    List<Threat>? activeThreats,
    bool? shieldActive,
    double? temperature,
    int? heartRate,
  }) {
    return SectorStatus(
      sector: sector ?? this.sector,
      integrity: integrity ?? this.integrity,
      threatLevel: threatLevel ?? this.threatLevel,
      activeThreats: activeThreats ?? this.activeThreats,
      shieldActive: shieldActive ?? this.shieldActive,
      temperature: temperature ?? this.temperature,
      heartRate: heartRate ?? this.heartRate,
    );
  }
}

/// Threat model
class Threat {
  const Threat({
    required this.id,
    required this.type,
    required this.sector,
    required this.severity,
    required this.distance,
    required this.bearing,
    this.velocity,
    this.description = '',
    this.timestamp = 0,
  });

  final String id;
  final ThreatType type;
  final BodySector sector;
  final ThreatLevel severity;
  final double distance; // Meters
  final double bearing; // Degrees from forward
  final Offset? velocity; // m/s
  final String description;
  final int timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Threat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          sector == other.sector &&
          severity == other.severity;

  @override
  int get hashCode => Object.hash(id, type, sector, severity);
}

enum ThreatType {
  ballistic('Ballistic', Icons.grain_outlined),
  explosive('Explosive', Icons.local_fire_department_outlined),
  energy('Energy Weapon', Icons.bolt_outlined),
  chemical('Chemical', Icons.science_outlined),
  biological('Biological', Icons.biotech_outlined),
  cyber('Cyber', Icons.memory_outlined),
  drone('Drone/UAV', Icons.airplanemode_active_outlined),
  unknown('Unknown', Icons.help_outline);

  const ThreatType(this.label, this.icon);
  final String label;
  final IconData icon;

  Color get color {
    switch (this) {
      case ThreatType.ballistic:
        return EdithColors.danger;
      case ThreatType.explosive:
        return EdithColors.warning;
      case ThreatType.energy:
        return EdithColors.accent;
      case ThreatType.chemical:
        return EdithColors.success;
      case ThreatType.biological:
        return Colors.purpleAccent;
      case ThreatType.cyber:
        return EdithColors.info;
      case ThreatType.drone:
        return EdithColors.warning;
      case ThreatType.unknown:
        return EdithColors.textMuted;
    }
  }
}

/// Notifier for protection status
class ProtectionStatusNotifier extends StateNotifier<ProtectionStatus> {
  final Ref _ref;
  Timer? _simulationTimer;
  Timer? _scanTimer;
  final _random = Random();
  final _threatTypes = ThreatType.values;

  ProtectionStatusNotifier(this._ref) : super(const ProtectionStatus()) {
    _initializeSectors();
    _startSimulation();
  }

  void _initializeSectors() {
    final sectors = <BodySector, SectorStatus>{};
    for (final sector in BodySector.values) {
      sectors[sector] = SectorStatus(sector: sector);
    }
    state = state.copyWith(sectorStatuses: sectors);
  }

  void _startSimulation() {
    _ref.listen(simulationConfigProvider, (prev, next) {
      if (next.simulateThreats && next.enabled) {
        _simulationTimer?.cancel();
        _simulationTimer = Timer.periodic(
          Duration(milliseconds: next.updateIntervalMs * 2),
          (_) => _simulateThreatUpdate(),
        );
      } else {
        _simulationTimer?.cancel();
        _simulationTimer = null;
        _clearThreats();
      }
    });

    final config = _ref.read(simulationConfigProvider);
    if (config.simulateThreats && config.enabled) {
      _simulateThreatUpdate();
    }
  }

  void _simulateThreatUpdate() {
    if (!state.isActive) return;

    // Random chance of new threat
    if (_random.nextDouble() < 0.15) {
      _generateRandomThreat();
    }

    // Update existing threats
    final updatedThreats = state.activeThreats.map((threat) {
      // Threats move closer or dissipate
      final newDistance = (max(0, threat.distance - _random.nextDouble() * 5)).toDouble();
      if (newDistance <= 0) {
        return null; // Threat reached target or dissipated
      }
      return threat.copyWith(
        distance: newDistance,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }).whereType<Threat>().toList();

    // Update sector statuses based on threats
    final updatedSectors = Map<BodySector, SectorStatus>.from(state.sectorStatuses);
    for (final sector in BodySector.values) {
      final sectorThreats = updatedThreats.where((t) => t.sector == sector).toList();
      final maxSeverity = sectorThreats.isEmpty
          ? ThreatLevel.none
          : sectorThreats.map((t) => t.severity).reduce((a, b) => a.value > b.value ? a : b);
      final integrity = max(0, 100 - sectorThreats.length * 15 - _random.nextInt(10));

      updatedSectors[sector] = updatedSectors[sector]!.copyWith(
        integrity: integrity.toDouble(),
        threatLevel: maxSeverity,
        activeThreats: sectorThreats,
      );
    }

    // Calculate overall threat level
    ThreatLevel overallLevel = ThreatLevel.none;
    for (final threat in updatedThreats) {
      if (threat.severity.value > overallLevel.value) {
        overallLevel = threat.severity;
      }
    }

    // Update shield integrity based on threats
    final shieldLoss = updatedThreats.length * 2.0;
    final newShieldIntegrity = (max(0, state.shieldIntegrity - shieldLoss + _random.nextDouble() * 5)).toDouble();

    state = state.copyWith(
      threatLevel: overallLevel,
      activeThreats: updatedThreats,
      sectorStatuses: updatedSectors,
      shieldIntegrity: newShieldIntegrity,
    );
  }

  void _generateRandomThreat() {
    final sector = BodySector.values[_random.nextInt(BodySector.values.length)];
    final type = _threatTypes[_random.nextInt(_threatTypes.length)];
    final severityValues = ThreatLevel.values.where((t) => t != ThreatLevel.none).toList();
    final severity = severityValues[_random.nextInt(severityValues.length)];

    final threat = Threat(
      id: 'threat_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      sector: sector,
      severity: severity,
      distance: 50 + _random.nextDouble() * 200,
      bearing: _random.nextDouble() * 360,
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 10,
        (_random.nextDouble() - 0.5) * 10,
      ),
      description: _getThreatDescription(type, severity),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final updatedThreats = [...state.activeThreats, threat];
    state = state.copyWith(activeThreats: updatedThreats);
  }

  String _getThreatDescription(ThreatType type, ThreatLevel severity) {
    const descriptions = {
      ThreatType.ballistic: 'Incoming projectile detected',
      ThreatType.explosive: 'Explosive device signature',
      ThreatType.energy: 'Directed energy weapon lock',
      ThreatType.chemical: 'Chemical agent dispersion',
      ThreatType.biological: 'Biological contamination alert',
      ThreatType.cyber: 'Network intrusion attempt',
      ThreatType.drone: 'Hostile UAV approach',
      ThreatType.unknown: 'Unidentified threat signature',
    };
    return '${descriptions[type] ?? 'Threat detected'} - ${severity.label}';
  }

  void _clearThreats() {
    final sectors = <BodySector, SectorStatus>{};
    for (final sector in BodySector.values) {
      sectors[sector] = SectorStatus(sector: sector);
    }
    state = state.copyWith(
      threatLevel: ThreatLevel.none,
      activeThreats: [],
      sectorStatuses: sectors,
      shieldIntegrity: 100.0,
    );
  }

  void startSectorScan() {
    if (state.isScanning) return;

    state = state.copyWith(isScanning: true, scanProgress: 0.0);

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final progress = state.scanProgress + 0.02;
      if (progress >= 1.0) {
        _scanTimer?.cancel();
        _scanTimer = null;
        _completeScan();
      } else {
        state = state.copyWith(scanProgress: progress);
      }
    });
  }

  void _completeScan() {
    // Simulate scan results
    final sectors = <BodySector, SectorStatus>{};
    for (final sector in BodySector.values) {
      final hasThreat = _random.nextDouble() < 0.2;
      ThreatLevel level = ThreatLevel.none;
      double integrity = 100.0;

      if (hasThreat) {
        final levels = [ThreatLevel.low, ThreatLevel.medium, ThreatLevel.high];
        level = levels[_random.nextInt(levels.length)];
        integrity = (100.0 - (level.value * 20.0) - _random.nextInt(15));
      }

      sectors[sector] = SectorStatus(
        sector: sector,
        integrity: integrity,
        threatLevel: level,
        shieldActive: true,
        temperature: 36.5 + _random.nextDouble() * 2,
        heartRate: sector == BodySector.chest ? 65 + _random.nextInt(20) : 72,
      );
    }

    state = state.copyWith(
      isScanning: false,
      scanProgress: 1.0,
      sectorStatuses: sectors,
      lastScan: DateTime.now().millisecondsSinceEpoch,
    );

    // Reset progress after a delay
    Future.delayed(const Duration(seconds: 2), () {
      // Check if notifier is still active by checking if we can access state
      try {
        state = state.copyWith(scanProgress: 0.0);
      } catch (_) {
        // Notifier disposed, ignore
      }
    });
  }

  void toggleProtection() {
    state = state.copyWith(isActive: !state.isActive);
    if (!state.isActive) {
      _clearThreats();
    }
  }

  void toggleEmpHardening() {
    state = state.copyWith(empHardening: !state.empHardening);
  }

  void toggleKineticBarrier() {
    state = state.copyWith(kineticBarrier: !state.kineticBarrier);
  }
}

extension ThreatCopyWith on Threat {
  Threat copyWith({
    String? id,
    ThreatType? type,
    BodySector? sector,
    ThreatLevel? severity,
    double? distance,
    double? bearing,
    Offset? velocity,
    String? description,
    int? timestamp,
  }) {
    return Threat(
      id: id ?? this.id,
      type: type ?? this.type,
      sector: sector ?? this.sector,
      severity: severity ?? this.severity,
      distance: distance ?? this.distance,
      bearing: bearing ?? this.bearing,
      velocity: velocity ?? this.velocity,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Providers
final protectionStatusProvider = StateNotifierProvider<ProtectionStatusNotifier, ProtectionStatus>((ref) {
  return ProtectionStatusNotifier(ref);
});