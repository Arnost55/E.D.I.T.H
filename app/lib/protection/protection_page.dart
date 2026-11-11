import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets/body_diagram.dart';
import 'providers/protection_providers.dart';
import '../../core/theme/edith_theme.dart';

class ProtectionPage extends ConsumerStatefulWidget {
  const ProtectionPage({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  ConsumerState<ProtectionPage> createState() => _ProtectionPageState();
}

class _ProtectionPageState extends ConsumerState<ProtectionPage> {
  BodySector? _selectedSector;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(protectionStatusProvider);

    return Scaffold(
      backgroundColor: EdithColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(status),
            // Body diagram
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.9,
                        maxHeight: constraints.maxHeight * 0.85,
                      ),
                      child: BodyDiagramWidget(
                        protectionStatus: status,
                        size: Size(
                          constraints.maxWidth * 0.9,
                          constraints.maxHeight * 0.85,
                        ),
                        onSectorTap: (sector) {
                          setState(() => _selectedSector = sector);
                          _showSectorDetails(sector, status.sectorStatuses[sector]!);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom controls
            _buildBottomControls(status),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ProtectionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: EdithColors.panel,
        border: Border(
          bottom: BorderSide(
            color: EdithColors.panelBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.onBack != null) ...[
            IconButton(tooltip: 'Back to dashboard', onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 4),
          ],
          // Title and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: EdithColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: EdithColors.accent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'PROTECTION',
                      style: EdithTypography.bodySmall.copyWith(
                        color: EdithColors.accentStrong,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'TACTICAL DISPLAY',
                    style: EdithTypography.headlineSmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: EdithColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Threat level indicator
              _buildThreatLevelBadge(status.threatLevel),
            ],
          ),
          const Spacer(),
          // Shield integrity
          _buildShieldIntegrity(status.shieldIntegrity),
          const SizedBox(width: 16),
          // System toggles
          _buildSystemToggle('EMP', status.empHardening, Icons.shield_outlined,
              () => ref.read(protectionStatusProvider.notifier).toggleEmpHardening()),
          const SizedBox(width: 8),
          _buildSystemToggle('KINETIC', status.kineticBarrier, Icons.grain_outlined,
              () => ref.read(protectionStatusProvider.notifier).toggleKineticBarrier()),
        ],
      ),
    );
  }

  Widget _buildThreatLevelBadge(ThreatLevel level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: level.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: level.color,
            ),
          ).animate(onPlay: (controller) => level == ThreatLevel.critical
              ? controller.repeat(period: 500.ms)
              : controller.stop())
            .fadeIn(duration: 250.ms).then().fadeOut(duration: 250.ms),
          const SizedBox(width: 8),
          Text(
            'THREAT LEVEL: ${level.label}',
            style: EdithTypography.bodySmall.copyWith(
              color: level.color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          if (level == ThreatLevel.critical) ...[
            const SizedBox(width: 8),
            Text(
              'IMMEDIATE ACTION REQUIRED',
              style: EdithTypography.bodySmall.copyWith(
                color: EdithColors.statusError,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ).animate(onPlay: (controller) => controller.repeat(period: 1000.ms))
              .fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildShieldIntegrity(double integrity) {
    return Container(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SHIELD',
                style: EdithTypography.bodySmall.copyWith(
                  color: EdithColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${integrity.toStringAsFixed(0)}%',
                style: EdithTypography.bodySmall.copyWith(
                  color: _getIntegrityColor(integrity),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: EdithColors.background,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: integrity / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getIntegrityColor(integrity),
                      _getIntegrityColor(integrity).withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntegrityColor(double integrity) {
    if (integrity > 70) return EdithColors.statusLive;
    if (integrity > 40) return EdithColors.statusWarning;
    return EdithColors.statusError;
  }

  Widget _buildSystemToggle(String label, bool enabled, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled
              ? EdithColors.accent.withValues(alpha: 0.15)
              : EdithColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? EdithColors.accent.withValues(alpha: 0.4)
                : EdithColors.panelBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: enabled ? EdithColors.accentStrong : EdithColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: EdithTypography.bodySmall.copyWith(
                color: enabled ? EdithColors.accentStrong : EdithColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? EdithColors.statusLive : EdithColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(ProtectionStatus status) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EdithColors.panel,
        border: Border(
          top: BorderSide(
            color: EdithColors.panelBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main action button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(protectionStatusProvider.notifier).toggleProtection(),
              icon: Icon(
                status.isActive ? Icons.shield_outlined : Icons.shield_outlined,
                size: 24,
              ),
              label: Text(
                status.isActive ? 'PROTECTION ACTIVE' : 'ACTIVATE PROTECTION',
                style: EdithTypography.bodyMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: status.isActive ? EdithColors.statusLive : EdithColors.accent,
                foregroundColor: EdithColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                side: BorderSide(
                  color: status.isActive
                      ? EdithColors.statusLive.withValues(alpha: 0.5)
                      : EdithColors.accent.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Secondary actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: status.isScanning
                      ? null
                      : () => ref.read(protectionStatusProvider.notifier).startSectorScan(),
                  icon: status.isScanning
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(EdithColors.accent),
                          ),
                        )
                      : Icon(Icons.radar_outlined, size: 20),
                  label: Text(
                    status.isScanning
                        ? 'SCANNING ${(status.scanProgress * 100).toInt()}%'
                        : 'SECTOR SCAN',
                    style: EdithTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EdithColors.accent,
                    side: BorderSide(
                      color: EdithColors.accent.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showThreatLog(status),
                  icon: Icon(Icons.list_alt_outlined, size: 20),
                  label: Text(
                    'THREAT LOG (${status.activeThreats.length})',
                    style: EdithTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EdithColors.statusWarning,
                    side: BorderSide(
                      color: EdithColors.statusWarning.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Active threats summary
          if (status.activeThreats.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildThreatSummary(status),
          ],
        ],
      ),
    );
  }

  Widget _buildThreatSummary(ProtectionStatus status) {
    final criticalThreats = status.activeThreats.where((t) => t.severity == ThreatLevel.critical).length;
    final highThreats = status.activeThreats.where((t) => t.severity == ThreatLevel.high).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EdithColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EdithColors.panelBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: EdithColors.statusWarning,
              ),
              const SizedBox(width: 8),
              Text(
                'ACTIVE THREATS',
                style: EdithTypography.bodySmall.copyWith(
                  color: EdithColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (criticalThreats > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: EdithColors.statusError.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$criticalThreats CRITICAL',
                    style: EdithTypography.bodySmall.copyWith(
                      color: EdithColors.statusError,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              if (highThreats > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: EdithColors.statusWarning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$highThreats HIGH',
                    style: EdithTypography.bodySmall.copyWith(
                      color: EdithColors.statusWarning,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: status.activeThreats.length.clamp(0, 5),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final threat = status.activeThreats[index];
                return _buildThreatCard(threat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreatCard(Threat threat) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: threat.type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: threat.type.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                threat.type.icon,
                size: 14,
                color: threat.type.color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  threat.type.label,
                  style: EdithTypography.bodySmall.copyWith(
                    color: threat.type.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            threat.sector.name,
            style: EdithTypography.bodySmall.copyWith(
              color: EdithColors.textPrimary,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                '${threat.distance.toInt()}m',
                style: EdithTypography.bodySmall.copyWith(
                  color: EdithColors.textMuted,
                  fontSize: 9,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: threat.severity.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  threat.severity.label,
                  style: EdithTypography.bodySmall.copyWith(
                    color: threat.severity.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSectorDetails(BodySector sector, SectorStatus status) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildSectorDetailsSheet(sector, status),
    );
  }

  Widget _buildSectorDetailsSheet(BodySector sector, SectorStatus status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EdithColors.panel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: EdithColors.panelBorder,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EdithColors.accent.withValues(alpha: 0.1),
                  border: Border.all(
                    color: EdithColors.accent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  sector.icon,
                  color: EdithColors.accentStrong,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sector.name,
                      style: EdithTypography.headlineSmall.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      status.threatLevel == ThreatLevel.none
                          ? 'SECURE'
                          : 'THREAT: ${status.threatLevel.label}',
                      style: EdithTypography.bodyMedium.copyWith(
                        color: status.threatLevel == ThreatLevel.none
                            ? EdithColors.statusLive
                            : status.threatLevel.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildMetric('INTEGRITY', '${status.integrity.toStringAsFixed(0)}%', _getIntegrityColor(status.integrity)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildMetric('TEMPERATURE', '${status.temperature.toStringAsFixed(1)}°C', EdithColors.accent)),
              Expanded(child: _buildMetric('HEART RATE', '${status.heartRate} BPM', EdithColors.statusError)),
              Expanded(child: _buildMetric('SHIELD', status.shieldActive ? 'ACTIVE' : 'INACTIVE', status.shieldActive ? EdithColors.statusLive : EdithColors.statusError)),
            ],
          ),
          if (status.activeThreats.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'SECTOR THREATS',
              style: EdithTypography.bodySmall.copyWith(
                color: EdithColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...status.activeThreats.map((threat) => _buildThreatDetailRow(threat)),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: EdithTypography.bodySmall.copyWith(
            color: EdithColors.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: EdithTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildThreatDetailRow(Threat threat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: threat.type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: threat.type.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(threat.type.icon, size: 20, color: threat.type.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  threat.type.label,
                  style: EdithTypography.bodyMedium.copyWith(
                    color: threat.type.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${threat.distance.toInt()}m · ${threat.severity.label}',
                  style: EdithTypography.bodySmall.copyWith(
                    color: EdithColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: threat.severity.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              threat.severity.label,
              style: EdithTypography.bodySmall.copyWith(
                color: threat.severity.color,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThreatLog(ProtectionStatus status) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildThreatLogSheet(status),
    );
  }

  Widget _buildThreatLogSheet(ProtectionStatus status) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: EdithColors.panel,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: EdithColors.panelBorder,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: EdithColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'THREAT LOG',
                    style: EdithTypography.headlineSmall.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: EdithColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: EdithColors.accent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${status.activeThreats.length} ACTIVE',
                      style: EdithTypography.bodySmall.copyWith(
                        color: EdithColors.accentStrong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Threat list
            Expanded(
              child: status.activeThreats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: EdithColors.statusLive.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Active Threats',
                            style: EdithTypography.headlineSmall.copyWith(
                              fontSize: 18,
                              color: EdithColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All sectors secure',
                            style: EdithTypography.bodyMedium.copyWith(
                              color: EdithColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: status.activeThreats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final threat = status.activeThreats[index];
                        return _buildThreatLogItem(threat);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatLogItem(Threat threat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EdithColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: threat.type.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: threat.type.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  threat.type.icon,
                  size: 24,
                  color: threat.type.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      threat.type.label,
                      style: EdithTypography.bodyMedium.copyWith(
                        color: threat.type.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      threat.description,
                      style: EdithTypography.bodySmall.copyWith(
                        color: EdithColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: threat.severity.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      threat.severity.label,
                      style: EdithTypography.bodySmall.copyWith(
                        color: threat.severity.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${threat.distance.toInt()}m away',
                    style: EdithTypography.bodySmall.copyWith(
                      color: EdithColors.textMuted,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThreatDetailChip(Icons.directions_outlined, '${threat.bearing.toInt()}°', EdithColors.accent),
              const SizedBox(width: 8),
              _buildThreatDetailChip(Icons.accessibility_outlined, threat.sector.name, EdithColors.accent),
              if (threat.velocity != null) ...[
                const SizedBox(width: 8),
                _buildThreatDetailChip(Icons.speed_outlined, '${threat.velocity!.distance.toStringAsFixed(1)} m/s', EdithColors.statusWarning),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThreatDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: EdithTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
