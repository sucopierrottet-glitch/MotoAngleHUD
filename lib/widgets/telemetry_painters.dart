import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// CustomPainter for the Motorcycle Lean Angle Dial (-65° Left to +65° Right)
/// with peak-hold markers and a dynamic banked motorcycle rear silhouette.
class LeanAngleGaugePainter extends CustomPainter {
  final double leanAngleDeg;
  final double peakLeftDeg;
  final double peakRightDeg;
  final bool highContrastHud;

  const LeanAngleGaugePainter({
    required this.leanAngleDeg,
    required this.peakLeftDeg,
    required this.peakRightDeg,
    this.highContrastHud = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.62);
    final radius = math.min(size.width * 0.44, size.height * 0.56);

    // 1. Background Arc (-65° to +65° relative to top vertical -90°)
    const maxDeg = 65.0;
    const topRad = -math.pi / 2;
    const sweepTotalRad = (maxDeg * 2) * math.pi / 180.0;
    const startRad = topRad - (maxDeg * math.pi / 180.0);

    final bgArcPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      sweepTotalRad,
      false,
      bgArcPaint,
    );

    // 2. Active Lean Sweep from Top Vertical (0°) to current Lean Angle
    final clampedLean = leanAngleDeg.clamp(-maxDeg, maxDeg);
    final activeSweepRad = clampedLean * math.pi / 180.0;
    final zoneColor = AppColors.getLeanZoneColor(clampedLean.abs());

    if (clampedLean.abs() > 0.2) {
      final activePaint = Paint()
        ..color = zoneColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        topRad,
        activeSweepRad,
        false,
        activePaint,
      );
    }

    // 3. Degree Tick Marks (-60, -45, -30, -15, 0, +15, +30, +45, +60)
    final tickPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2.0;
    final majorTickPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3.0;

    for (int deg = -60; deg <= 60; deg += 15) {
      final angleRad = topRad + (deg * math.pi / 180.0);
      final isMajor = deg % 30 == 0;
      final innerR = radius - (isMajor ? 22 : 15);
      final outerR = radius - 8;

      final p1 = Offset(
        center.dx + innerR * math.cos(angleRad),
        center.dy + innerR * math.sin(angleRad),
      );
      final p2 = Offset(
        center.dx + outerR * math.cos(angleRad),
        center.dy + outerR * math.sin(angleRad),
      );
      canvas.drawLine(p1, p2, isMajor ? majorTickPaint : tickPaint);
    }

    // 4. Peak Hold Indicators (Left & Right)
    if (peakLeftDeg > 1.0) {
      _drawPeakMarker(
        canvas,
        center,
        radius + 6,
        topRad - (peakLeftDeg.clamp(0.0, maxDeg) * math.pi / 180.0),
        AppColors.racingRed,
      );
    }
    if (peakRightDeg > 1.0) {
      _drawPeakMarker(
        canvas,
        center,
        radius + 6,
        topRad + (peakRightDeg.clamp(0.0, maxDeg) * math.pi / 180.0),
        AppColors.neonGreen,
      );
    }

    // 5. Artificial Horizon Reference Line
    final horizonPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(center.dx - radius * 0.72, center.dy),
      Offset(center.dx + radius * 0.72, center.dy),
      horizonPaint,
    );

    // 6. Banked Motorcycle Profile Vector inside the Gauge
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(clampedLean * math.pi / 180.0);

    // Needle / Bank Axis Line
    final needlePaint = Paint()
      ..color = zoneColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, -radius + 14),
      const Offset(0, 28),
      needlePaint,
    );

    // Tire cross-section & fairing silhouette
    final tirePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final tireRimPaint = Paint()
      ..color = zoneColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final tireRect = Rect.fromCenter(
      center: const Offset(0, 8),
      width: 24,
      height: 52,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tireRect, const Radius.circular(12)),
      tirePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tireRect, const Radius.circular(12)),
      tireRimPaint,
    );

    // Handlebars
    final barPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-34, -22), const Offset(34, -22), barPaint);

    // Windshield / Fairing dome
    final fairingPath = Path()
      ..moveTo(-20, -10)
      ..quadraticBezierTo(0, -44, 20, -10)
      ..close();
    canvas.drawPath(
      fairingPath,
      Paint()
        ..color = zoneColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      fairingPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    canvas.restore();
  }

  void _drawPeakMarker(
    Canvas canvas,
    Offset center,
    double r,
    double angleRad,
    Color color,
  ) {
    final pos = Offset(
      center.dx + r * math.cos(angleRad),
      center.dy + r * math.sin(angleRad),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 5.5, paint);
    canvas.drawCircle(
      pos,
      8.5,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant LeanAngleGaugePainter oldDelegate) {
    return oldDelegate.leanAngleDeg != leanAngleDeg ||
        oldDelegate.peakLeftDeg != peakLeftDeg ||
        oldDelegate.peakRightDeg != peakRightDeg ||
        oldDelegate.highContrastHud != highContrastHud;
  }
}

/// CustomPainter for the 2D G-Force Friction Circle (Bullseye Target & Live Ball)
class GForceBullseyePainter extends CustomPainter {
  final double lateralG;
  final double longitudinalG;
  final double peakG;

  const GForceBullseyePainter({
    required this.lateralG,
    required this.longitudinalG,
    required this.peakG,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.44;
    const maxScaleG = 1.5; // Outer ring = 1.5G

    // 1. Background Circle
    canvas.drawCircle(
      center,
      maxRadius,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.fill,
    );

    // 2. Concentric Rings: 0.5G, 1.0G, 1.5G
    final ringPaint = Paint()
      ..color = const Color(0xFF243046)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final gRing in [0.5, 1.0, 1.5]) {
      final r = maxRadius * (gRing / maxScaleG);
      canvas.drawCircle(center, r, ringPaint);
    }

    // 3. Crosshairs
    final axisPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      axisPaint,
    );

    // 4. Peak G Ring Indicator
    if (peakG > 0.05) {
      final peakR = (maxRadius * (peakG.clamp(0.0, maxScaleG) / maxScaleG));
      canvas.drawCircle(
        center,
        peakR,
        Paint()
          ..color = AppColors.racingRed.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // 5. Current 2D G-Force Vector & Glowing Ball
    final normX = (lateralG / maxScaleG).clamp(-1.0, 1.0);
    // Longitudinal G > 0 (acceleration) pushes ball UP (-dy), braking (< 0) pushes DOWN (+dy)
    final normY = (-longitudinalG / maxScaleG).clamp(-1.0, 1.0);

    final ballPos = Offset(
      center.dx + normX * maxRadius,
      center.dy + normY * maxRadius,
    );

    // Vector line from center to ball
    canvas.drawLine(
      center,
      ballPos,
      Paint()
        ..color = AppColors.neonGreen.withValues(alpha: 0.6)
        ..strokeWidth = 2.5,
    );

    // Outer glow
    canvas.drawCircle(
      ballPos,
      13,
      Paint()
        ..color = AppColors.neonGreen.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    // Solid neon ball
    canvas.drawCircle(
      ballPos,
      7.5,
      Paint()
        ..color = AppColors.neonGreen
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      ballPos,
      7.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant GForceBullseyePainter oldDelegate) {
    return oldDelegate.lateralG != lateralG ||
        oldDelegate.longitudinalG != longitudinalG ||
        oldDelegate.peakG != peakG;
  }
}
