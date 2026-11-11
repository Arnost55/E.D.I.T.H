import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

import '../providers/vision_providers.dart';
import '../../core/theme/edith_theme.dart';

class HUDOverlay extends StatelessWidget {
  const HUDOverlay({
    super.key,
    required this.visionStatus,
    required this.size,
  });

  final VisionStatus visionStatus;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Crosshair
        _buildCrosshair(),
        // Corner brackets
        _buildCornerBrackets(),
        // Detected objects
        ...visionStatus.detectedObjects.map((obj) => _buildObjectBox(obj)),
        // Sensor data HUD
        _buildSensorHUD(),
        // Recording indicator
        if (visionStatus.isRecording) _buildRecordingIndicator(),
        // Zoom indicator
        if (visionStatus.zoomLevel > 1.0) _buildZoomIndicator(),
        // Frame rate
        _buildFrameRateIndicator(),
        // Compass/heading
        _buildCompass(),
      ],
    );
  }

  Widget _buildCrosshair() {
    return Center(
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: EdithColors.accent.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
            // Inner circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: EdithColors.accentStrong,
                  width: 2,
                ),
              ),
            ),
            // Center dot
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EdithColors.accentStrong,
                boxShadow: [
                  BoxShadow(
                    color: EdithColors.glowColor,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            // Crosshair lines
            ...List.generate(4, (index) {
              final angle = index * pi / 2;
              return Transform.rotate(
                angle: angle,
                child: Container(
                  width: 1,
                  height: 15,
                  margin: const EdgeInsets.only(top: 28),
                  color: EdithColors.accent.withValues(alpha: 0.7),
                ),
              );
            }),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true, period: 2000.ms))
        .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
    );
  }

  Widget _buildCornerBrackets() {
    const bracketSize = 40.0;
    const lineWidth = 2.0;
    const gap = 16.0;

    return Stack(
      children: [
        // Top-left
        Positioned(
          top: gap,
          left: gap,
          child: _buildCornerBracket(
            topLeft: true,
            size: bracketSize,
            lineWidth: lineWidth,
          ),
        ),
        // Top-right
        Positioned(
          top: gap,
          right: gap,
          child: _buildCornerBracket(
            topRight: true,
            size: bracketSize,
            lineWidth: lineWidth,
          ),
        ),
        // Bottom-left
        Positioned(
          bottom: gap,
          left: gap,
          child: _buildCornerBracket(
            bottomLeft: true,
            size: bracketSize,
            lineWidth: lineWidth,
          ),
        ),
        // Bottom-right
        Positioned(
          bottom: gap,
          right: gap,
          child: _buildCornerBracket(
            bottomRight: true,
            size: bracketSize,
            lineWidth: lineWidth,
          ),
        ),
      ],
    );
  }

  Widget _buildCornerBracket({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
    required double size,
    required double lineWidth,
  }) {
    final isTop = topLeft || topRight;
    final isLeft = topLeft || bottomLeft;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerBracketPainter(
          isTop: isTop,
          isLeft: isLeft,
          lineWidth: lineWidth,
          color: EdithColors.accent,
        ),
      ),
    );
  }

  Widget _buildObjectBox(DetectedObject obj) {
    final left = obj.bounds.left * size.width;
    final top = obj.bounds.top * size.height;
    final width = obj.bounds.width * size.width;
    final height = obj.bounds.height * size.height;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: obj.color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            // Corner accents
            ..._buildBoxCorners(obj.color),
            // Label
            Positioned(
              top: -24,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: obj.color.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${obj.label} ${(obj.confidence * 100).toInt()}%',
                  style: EdithTypography.captionStyle.copyWith(
                    color: EdithColors.bgPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Distance
            if (obj.distanceMeters != null)
              Positioned(
                bottom: -20,
                left: 0,
                right: 0,
                child: Text(
                  '${obj.distanceMeters!.toStringAsFixed(1)}m',
                  style: EdithTypography.captionStyle.copyWith(
                    color: obj.color,
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }

  List<Widget> _buildBoxCorners(Color color) {
    const cornerLength = 12.0;
    const cornerWidth = 2.0;

    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: CustomPaint(
          size: const Size(cornerLength, cornerLength),
          painter: _BoxCornerPainter(
            topLeft: true,
            color: color,
            width: cornerWidth,
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: CustomPaint(
          size: const Size(cornerLength, cornerLength),
          painter: _BoxCornerPainter(
            topRight: true,
            color: color,
            width: cornerWidth,
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: CustomPaint(
          size: const Size(cornerLength, cornerLength),
          painter: _BoxCornerPainter(
            bottomLeft: true,
            color: color,
            width: cornerWidth,
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: CustomPaint(
          size: const Size(cornerLength, cornerLength),
          painter: _BoxCornerPainter(
            bottomRight: true,
            color: color,
            width: cornerWidth,
          ),
        ),
      ),
    ];
  }

  Widget _buildSensorHUD() {
    return Positioned(
      top: 80,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: EdithColors.panel.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: EdithColors.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSensorRow('HEADING', '${visionStatus.sensorData.orientation.toStringAsFixed(0)}°', Icons.explore_outlined),
            const SizedBox(height: 8),
            _buildSensorRow('PITCH', '${visionStatus.sensorData.pitch.toStringAsFixed(1)}°', Icons.keyboard_arrow_up_outlined),
            const SizedBox(height: 8),
            _buildSensorRow('ROLL', '${visionStatus.sensorData.roll.toStringAsFixed(1)}°', Icons.rotate_right_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: EdithColors.accent),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: EdithTypography.captionStyle.copyWith(
            color: EdithColors.textMuted,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: EdithTypography.captionStyle.copyWith(
            color: EdithColors.textPrimary,
            fontSize: 10,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingIndicator() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: EdithColors.danger.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: EdithColors.danger.withValues(alpha: 0.5),
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
                color: EdithColors.danger,
              ),
            ).animate(onPlay: (controller) => controller.repeat(period: 1000.ms))
              .fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms),
            const SizedBox(width: 8),
            Text(
              'REC',
              style: EdithTypography.captionStyle.copyWith(
                color: EdithColors.danger,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: EdithColors.panel.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: EdithColors.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.zoom_in_outlined,
              size: 14,
              color: EdithColors.accent,
            ),
            const SizedBox(width: 6),
            Text(
              '${visionStatus.zoomLevel.toStringAsFixed(1)}x',
              style: EdithTypography.captionStyle.copyWith(
                color: EdithColors.textPrimary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameRateIndicator() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: EdithColors.panel.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: EdithColors.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_outlined,
              size: 12,
              color: visionStatus.isActive ? EdithColors.success : EdithColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              '${visionStatus.frameRate} FPS',
              style: EdithTypography.captionStyle.copyWith(
                color: visionStatus.isActive ? EdithColors.success : EdithColors.textMuted,
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return Positioned(
      top: 16,
      right: 16,
      child: SizedBox(
        width: 80,
        height: 80,
        child: CustomPaint(
          painter: _CompassPainter(
            heading: visionStatus.sensorData.orientation,
            color: EdithColors.accent,
          ),
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final double lineWidth;
  final Color color;

  _CornerBracketPainter({
    required this.isTop,
    required this.isLeft,
    required this.lineWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const length = 20.0;

    if (isTop && isLeft) {
      // Top-left
      path.moveTo(0, length);
      path.lineTo(0, 0);
      path.lineTo(length, 0);
    } else if (isTop && !isLeft) {
      // Top-right
      path.moveTo(size.width - length, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, length);
    } else if (!isTop && isLeft) {
      // Bottom-left
      path.moveTo(0, size.height - length);
      path.lineTo(0, size.height);
      path.lineTo(length, size.height);
    } else {
      // Bottom-right
      path.moveTo(size.width, size.height - length);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width - length, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BoxCornerPainter extends CustomPainter {
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;
  final Color color;
  final double width;

  _BoxCornerPainter({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const length = 12.0;

    if (topLeft) {
      canvas.drawLine(const Offset(0, length), Offset.zero, paint);
      canvas.drawLine(Offset.zero, const Offset(length, 0), paint);
    } else if (topRight) {
      canvas.drawLine(Offset(size.width - length, 0), Offset(size.width, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
    } else if (bottomLeft) {
      canvas.drawLine(Offset(0, size.height - length), Offset(0, size.height), paint);
      canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    } else if (bottomRight) {
      canvas.drawLine(Offset(size.width, size.height - length), Offset(size.width, size.height), paint);
      canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassPainter extends CustomPainter {
  final double heading;
  final Color color;

  _CompassPainter({required this.heading, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, ringPaint);

    // Cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) - (heading * pi / 180);
      final x = center.dx + (radius - 12) * cos(angle);
      final y = center.dy + (radius - 12) * sin(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    // Heading indicator (triangle at top)
    final indicatorPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final indicatorPath = Path();
    indicatorPath.moveTo(center.dx, center.dy - radius + 4);
    indicatorPath.lineTo(center.dx - 6, center.dy - radius + 14);
    indicatorPath.lineTo(center.dx + 6, center.dy - radius + 14);
    indicatorPath.close();
    canvas.drawPath(indicatorPath, indicatorPaint);

    // Heading text
    textPainter.text = TextSpan(
      text: '${heading.toStringAsFixed(0)}°',
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        fontFamily: 'monospace',
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    ));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _CompassPainter && oldDelegate.heading != heading;
  }
}