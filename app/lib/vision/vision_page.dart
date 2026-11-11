import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widgets/hud_overlay.dart';
import 'providers/vision_providers.dart';
import '../../core/theme/edith_theme.dart';

class VisionPage extends ConsumerStatefulWidget {
  const VisionPage({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  ConsumerState<VisionPage> createState() => _VisionPageState();
}

class _VisionPageState extends ConsumerState<VisionPage> {
  bool _showControls = true;

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    ref
        .read(visionStatusProvider.notifier)
        .setCameraPermission(status.isGranted);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    final visionStatus = ref.watch(visionStatusProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Camera preview (simulated)
            _buildCameraPreview(visionStatus),
            // HUD Overlay
            LayoutBuilder(
              builder: (context, constraints) {
                return HUDOverlay(
                  visionStatus: visionStatus,
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                );
              },
            ),
            // Top controls
            if (_showControls) _buildTopControls(visionStatus),
            // Bottom controls
            if (_showControls) _buildBottomControls(visionStatus),
            // Permission overlay
            if (!visionStatus.cameraPermission) _buildPermissionOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(VisionStatus status) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Simulated camera feed
          Container(
            color: Colors.black,
            child: CustomPaint(
              painter: _CameraFeedPainter(
                isActive: status.isActive,
                frameRate: status.frameRate,
              ),
            ),
          ),
          // Vignette effect
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          // Scan lines
          if (status.isActive)
            CustomPaint(
              painter: _ScanLinesPainter(
                color: EdithColors.accent.withValues(alpha: 0.05),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopControls(VisionStatus status) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                EdithColors.background.withValues(alpha: 0.9),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              if (widget.onBack != null)
                IconButton(tooltip: 'Back to dashboard', onPressed: widget.onBack, icon: const Icon(Icons.arrow_back, color: Colors.white)),
              // Title
              Text(
                'VISION SYSTEM',
                style: EdithTypography.headlineSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: EdithColors.accentStrong,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              // Status badges
              _buildStatusBadge(
                'CAM',
                status.cameraPermission ? 'OK' : 'DENIED',
                status.cameraPermission
                    ? EdithColors.statusLive
                    : EdithColors.statusError,
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(
                'HUD',
                status.isActive ? 'ACTIVE' : 'STANDBY',
                status.isActive
                    ? EdithColors.statusLive
                    : EdithColors.statusWarning,
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(
                'REC',
                status.isRecording ? 'ON' : 'OFF',
                status.isRecording
                    ? EdithColors.statusError
                    : EdithColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(VisionStatus status) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                EdithColors.background.withValues(alpha: 0.95),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom slider
              if (status.isActive) ...[
                Row(
                  children: [
                    Icon(
                      Icons.zoom_out_map_outlined,
                      size: 20,
                      color: EdithColors.textMuted,
                    ),
                    Expanded(
                      child: Slider(
                        value: status.zoomLevel,
                        min: 1.0,
                        max: 10.0,
                        divisions: 18,
                        activeColor: EdithColors.accent,
                        inactiveColor: EdithColors.panelBorder,
                        thumbColor: EdithColors.accentStrong,
                        onChanged: (value) => ref
                            .read(visionStatusProvider.notifier)
                            .setZoom(value),
                      ),
                    ),
                    Icon(
                      Icons.zoom_in_outlined,
                      size: 20,
                      color: EdithColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${status.zoomLevel.toStringAsFixed(1)}x',
                      style: EdithTypography.bodySmall.copyWith(
                        color: EdithColors.accent,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: status.isRecording
                        ? Icons.stop_circle_outlined
                        : Icons.videocam_outlined,
                    label: status.isRecording ? 'STOP' : 'RECORD',
                    color: status.isRecording
                        ? EdithColors.statusError
                        : EdithColors.accent,
                    onPressed: () => ref
                        .read(visionStatusProvider.notifier)
                        .toggleRecording(),
                  ),
                  _buildControlButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'CAPTURE',
                    color: EdithColors.accent,
                    onPressed: _capturePhoto,
                  ),
                  _buildControlButton(
                    icon: Icons.center_focus_strong_outlined,
                    label: 'FOCUS',
                    color: EdithColors.statusWarning,
                    onPressed: _toggleFocus,
                  ),
                  _buildControlButton(
                    icon: Icons.mode_night_outlined,
                    label: 'NIGHT',
                    color: EdithColors.statusLive,
                    onPressed: _toggleNightVision,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: EdithTypography.bodySmall.copyWith(
              color: EdithColors.textMuted,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: EdithTypography.bodySmall.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EdithColors.panel,
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: EdithTypography.bodySmall.copyWith(
            color: EdithColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionOverlay() {
    return Container(
      color: EdithColors.background.withValues(alpha: 0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EdithColors.statusError.withValues(alpha: 0.1),
                  border: Border.all(
                    color: EdithColors.statusError.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 48,
                  color: EdithColors.statusError,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Camera Permission Required',
                style: EdithTypography.headlineSmall.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: EdithColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'E.D.I.T.H. Vision System requires camera access to display the live feed with HUD overlay. Please grant permission in settings.',
                style: EdithTypography.bodyMedium.copyWith(
                  color: EdithColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _requestCameraPermission,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EdithColors.accent,
                  foregroundColor: EdithColors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _capturePhoto() {
    // Simulate photo capture
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Photo captured',
          style: EdithTypography.bodyMedium.copyWith(
            color: EdithColors.background,
          ),
        ),
        backgroundColor: EdithColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleFocus() {
    final current = ref.read(visionStatusProvider).focusMode;
    final next = current == FocusMode.auto ? FocusMode.locked : FocusMode.auto;
    ref.read(visionStatusProvider.notifier).setFocusMode(next);
  }

  void _toggleNightVision() {
    // Toggle night vision mode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Night vision toggled',
          style: EdithTypography.bodyMedium.copyWith(
            color: EdithColors.background,
          ),
        ),
        backgroundColor: EdithColors.statusLive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _CameraFeedPainter extends CustomPainter {
  final bool isActive;
  final int frameRate;

  _CameraFeedPainter({required this.isActive, required this.frameRate});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) {
      // Draw "NO SIGNAL" pattern
      final paint = Paint()
        ..color = Colors.grey[900]!
        ..style = PaintingStyle.fill;
      canvas.drawRect(Offset.zero & size, paint);

      // Static noise pattern
      final noisePaint = Paint()
        ..color = Colors.grey[800]!
        ..style = PaintingStyle.fill;

      for (int y = 0; y < size.height; y += 4) {
        for (int x = 0; x < size.width; x += 4) {
          if ((x + y) % 8 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(x.toDouble(), y.toDouble(), 2, 2),
              noisePaint,
            );
          }
        }
      }

      // NO SIGNAL text
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'NO SIGNAL',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _CameraFeedPainter &&
        (oldDelegate.isActive != isActive ||
            oldDelegate.frameRate != frameRate);
  }
}

class _ScanLinesPainter extends CustomPainter {
  final Color color;

  _ScanLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 4.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
