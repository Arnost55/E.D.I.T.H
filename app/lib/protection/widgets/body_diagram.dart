import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

import '../providers/protection_providers.dart';
import '../../core/theme/edith_theme.dart';

class BodyDiagramWidget extends StatelessWidget {
  const BodyDiagramWidget({
    super.key,
    required this.protectionStatus,
    required this.size,
    this.onSectorTap,
  });

  final ProtectionStatus protectionStatus;
  final Size size;
  final void Function(BodySector)? onSectorTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Body outline
          CustomPaint(
            size: size,
            painter: _BodyOutlinePainter(
              sectorStatuses: protectionStatus.sectorStatuses,
              threatLevel: protectionStatus.threatLevel,
            ),
          ),
          // Sector indicators
          ...BodySector.values.map((sector) => _buildSectorIndicator(sector)),
          // Active threat indicators
          ...protectionStatus.activeThreats.map((threat) => _buildThreatIndicator(threat)),
          // Shield effect
          if (protectionStatus.isActive && protectionStatus.shieldIntegrity > 0)
            CustomPaint(
              size: size,
              painter: _ShieldEffectPainter(
                integrity: protectionStatus.shieldIntegrity,
                color: EdithColors.accent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectorIndicator(BodySector sector) {
    final status = protectionStatus.sectorStatuses[sector];
    if (status == null) return const SizedBox.shrink();

    final position = Offset(
      sector.position.dx * size.width,
      sector.position.dy * size.height,
    );

    final threatColor = status.threatLevel.color;
    final isThreatened = status.threatLevel != ThreatLevel.none;

    return Positioned(
      left: position.dx - 30,
      top: position.dy - 30,
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => onSectorTap?.call(sector),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sector ring
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isThreatened ? threatColor : EdithColors.accent.withValues(alpha: 0.4),
                  width: isThreatened ? 3 : 1.5,
                ),
                boxShadow: isThreatened
                    ? [
                        BoxShadow(
                          color: threatColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            // Sector icon
            Icon(
              sector.icon,
              size: 20,
              color: isThreatened ? threatColor : EdithColors.accentStrong,
            ),
            // Integrity indicator
            if (status.integrity < 100)
              Positioned(
                bottom: -4,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: EdithColors.background,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: status.integrity / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getIntegrityColor(status.integrity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            // Threat pulse
            if (isThreatened)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: threatColor.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(period: 1000.ms))
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
                .fadeOut(duration: 1000.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatIndicator(Threat threat) {
    // Position threat relative to body center based on bearing and distance
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2 * 0.9;
    final normalizedDistance = (threat.distance / 300).clamp(0.0, 1.0);
    final radius = maxRadius * (1 - normalizedDistance * 0.7); // Closer = further from center
    final angle = (threat.bearing - 90) * pi / 180; // 0° = forward (top)

    final position = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    return Positioned(
      left: position.dx - 25,
      top: position.dy - 25,
      width: 50,
      height: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Threat marker
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  threat.type.color.withValues(alpha: 0.9),
                  threat.type.color.withValues(alpha: 0.3),
                ],
              ),
              border: Border.all(
                color: threat.type.color,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: threat.type.color.withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                threat.type.icon,
                size: 16,
                color: EdithColors.background,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(period: 800.ms))
            .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15)),
          const SizedBox(height: 4),
          // Distance label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: threat.type.color.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${threat.distance.toInt()}m',
              style: EdithTypography.captionStyle.copyWith(
                color: EdithColors.background,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntegrityColor(double integrity) {
    if (integrity > 70) return EdithColors.success;
    if (integrity > 40) return EdithColors.warning;
    return EdithColors.danger;
  }
}

class _BodyOutlinePainter extends CustomPainter {
  final Map<BodySector, SectorStatus> sectorStatuses;
  final ThreatLevel threatLevel;

  _BodyOutlinePainter({
    required this.sectorStatuses,
    required this.threatLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const scale = 1.0;

    // Define body proportions
    final headRadius = 35.0 * scale;
    final shoulderWidth = 100.0 * scale;
    final chestWidth = 80.0 * scale;
    final waistWidth = 60.0 * scale;
    final hipWidth = 70.0 * scale;
    final torsoHeight = 200.0 * scale;
    final armLength = 120.0 * scale;
    final legLength = 140.0 * scale;

    final headCenter = Offset(centerX, headRadius + 20);
    final neckTop = Offset(centerX, headCenter.dy + headRadius);
    final neckBottom = Offset(centerX, neckTop.dy + 25);
    final shoulderLeft = Offset(centerX - shoulderWidth / 2, neckBottom.dy);
    final shoulderRight = Offset(centerX + shoulderWidth / 2, neckBottom.dy);
    final chestLeft = Offset(centerX - chestWidth / 2, neckBottom.dy + 40);
    final chestRight = Offset(centerX + chestWidth / 2, neckBottom.dy + 40);
    final waistLeft = Offset(centerX - waistWidth / 2, neckBottom.dy + 90);
    final waistRight = Offset(centerX + waistWidth / 2, neckBottom.dy + 90);
    final hipLeft = Offset(centerX - hipWidth / 2, neckBottom.dy + torsoHeight - 40);
    final hipRight = Offset(centerX + hipWidth / 2, neckBottom.dy + torsoHeight - 40);
    final torsoBottom = Offset(centerX, neckBottom.dy + torsoHeight);

    // Arm positions
    final leftElbow = Offset(shoulderLeft.dx - 40, shoulderLeft.dy + 60);
    final leftWrist = Offset(shoulderLeft.dx - 50, shoulderLeft.dy + armLength);
    final rightElbow = Offset(shoulderRight.dx + 40, shoulderRight.dy + 60);
    final rightWrist = Offset(shoulderRight.dx + 50, shoulderRight.dy + armLength);

    // Leg positions
    final leftKnee = Offset(hipLeft.dx - 10, hipLeft.dy + 70);
    final leftAnkle = Offset(hipLeft.dx - 5, hipLeft.dy + legLength);
    final rightKnee = Offset(hipRight.dx + 10, hipRight.dy + 70);
    final rightAnkle = Offset(hipRight.dx + 5, hipRight.dy + legLength);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Color based on threat level
    final baseColor = threatLevel == ThreatLevel.none
        ? EdithColors.accent.withValues(alpha: 0.5)
        : threatLevel.color.withValues(alpha: 0.7);

    paint.color = baseColor;

    // Head
    canvas.drawCircle(headCenter, headRadius, paint);

    // Neck
    canvas.drawLine(neckTop, neckBottom, paint);

    // Shoulders
    canvas.drawLine(shoulderLeft, shoulderRight, paint);

    // Torso outline
    final torsoPath = Path();
    torsoPath.moveTo(shoulderLeft.dx, shoulderLeft.dy);
    torsoPath.lineTo(chestLeft.dx, chestLeft.dy);
    torsoPath.lineTo(waistLeft.dx, waistLeft.dy);
    torsoPath.lineTo(hipLeft.dx, hipLeft.dy);
    torsoPath.lineTo(torsoBottom.dx, torsoBottom.dy);
    torsoPath.lineTo(hipRight.dx, hipRight.dy);
    torsoPath.lineTo(waistRight.dx, waistRight.dy);
    torsoPath.lineTo(chestRight.dx, chestRight.dy);
    torsoPath.lineTo(shoulderRight.dx, shoulderRight.dy);
    torsoPath.close();
    canvas.drawPath(torsoPath, paint);

    // Arms
    canvas.drawLine(shoulderLeft, leftElbow, paint);
    canvas.drawLine(leftElbow, leftWrist, paint);
    canvas.drawLine(shoulderRight, rightElbow, paint);
    canvas.drawLine(rightElbow, rightWrist, paint);

    // Legs
    canvas.drawLine(hipLeft, leftKnee, paint);
    canvas.drawLine(leftKnee, leftAnkle, paint);
    canvas.drawLine(hipRight, rightKnee, paint);
    canvas.drawLine(rightKnee, rightAnkle, paint);

    // Sector highlights
    _drawSectorHighlights(canvas, size);
  }

  void _drawSectorHighlights(Canvas canvas, Size size) {
    for (final entry in sectorStatuses.entries) {
      final sector = entry.key;
      final status = entry.value;

      if (status.threatLevel == ThreatLevel.none) continue;

      final position = Offset(
        sector.position.dx * size.width,
        sector.position.dy * size.height,
      );

      final highlightPaint = Paint()
        ..color = status.threatLevel.color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, 40, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _BodyOutlinePainter &&
        (oldDelegate.threatLevel != threatLevel ||
            oldDelegate.sectorStatuses != sectorStatuses);
  }
}

class _ShieldEffectPainter extends CustomPainter {
  final double integrity;
  final Color color;

  _ShieldEffectPainter({required this.integrity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const baseRadius = 180.0;

    // Shield dome
    final shieldPaint = Paint()
      ..color = color.withValues(alpha: 0.03 * (integrity / 100))
      ..style = PaintingStyle.fill;

    final shieldPath = Path();
    shieldPath.addOval(Rect.fromCircle(
      center: center,
      radius: baseRadius,
    ));
    canvas.drawPath(shieldPath, shieldPaint);

    // Shield hex grid
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.08 * (integrity / 100))
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const hexSize = 25.0;
    final rows = (size.height / (hexSize * 1.5)).ceil() + 1;
    final cols = (size.width / (hexSize * 1.732)).ceil() + 1;

    for (int row = -1; row <= rows; row++) {
      for (int col = -1; col <= cols; col++) {
        final x = col * hexSize * 1.732 + (row.isEven ? hexSize * 0.866 : 0);
        final y = row * hexSize * 1.5;

        if (x > -hexSize && x < size.width + hexSize && y > -hexSize && y < size.height + hexSize) {
          final hexPath = Path();
          for (int i = 0; i < 6; i++) {
            final angle = i * pi / 3;
            final hx = x + hexSize * cos(angle);
            final hy = y + hexSize * sin(angle);
            if (i == 0) {
              hexPath.moveTo(hx, hy);
            } else {
              hexPath.lineTo(hx, hy);
            }
          }
          hexPath.close();
          canvas.drawPath(hexPath, gridPaint);
        }
      }
    }

    // Shield integrity ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.4 * (integrity / 100))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, baseRadius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _ShieldEffectPainter &&
        (oldDelegate.integrity != integrity || oldDelegate.color != color);
  }
}