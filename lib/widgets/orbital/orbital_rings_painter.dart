import 'dart:math';
import 'package:flutter/material.dart';

class OrbitRingDef {
  final double tilt;
  final double eccentricity;
  final double phase;
  final Color color;

  const OrbitRingDef({
    required this.tilt,
    required this.eccentricity,
    this.phase = 0,
    required this.color,
  });
}

const List<OrbitRingDef> kDefaultRings = [
  OrbitRingDef(tilt: 0, eccentricity: 0.72, color: Color(0xFF6366F1)),
  OrbitRingDef(tilt: 72, eccentricity: 0.72, color: Color(0xFF8B5CF6)),
  OrbitRingDef(tilt: 144, eccentricity: 0.72, color: Color(0xFF06B6D4)),
  OrbitRingDef(tilt: 36, eccentricity: 0.72, color: Color(0xFF10B981)),
  OrbitRingDef(tilt: 108, eccentricity: 0.72, color: Color(0xFFF59E0B)),
];

/// 15 fixed slots: 3 per ring, 120° apart, offset by ring * 48°.
const List<List<double>> kSlotAngles = [
  [0, 120, 240],       // Ring 0
  [48, 168, 288],      // Ring 1
  [96, 216, 336],      // Ring 2
  [24, 144, 264],      // Ring 3
  [72, 192, 312],      // Ring 4
];

/// Returns the position for a fixed slot (0..14) at the given radius.
Offset slotPosition(int slotIndex, double radius) {
  final ring = slotIndex ~/ 3;
  final angleInRing = slotIndex % 3;
  final def = kDefaultRings[ring];
  final angle = kSlotAngles[ring][angleInRing];
  return orbitPosition(angle.toDouble(), radius, def.tilt, def.eccentricity);
}

/// Compute position on a tilted ellipse.
Offset orbitPosition(
  double angleDeg,
  double radius,
  double tiltDeg,
  double eccentricity,
) {
  final a = (angleDeg + tiltDeg) * pi / 180;
  final x = radius * cos(a);
  final y = radius * sin(a) * eccentricity;
  final tr = -tiltDeg * pi / 180;
  return Offset(
    x * cos(tr) - y * sin(tr),
    x * sin(tr) + y * cos(tr),
  );
}

class OrbitalRingsPainter extends CustomPainter {
  final double radius;
  final double opacity;
  final int visibleRings;
  /// Extra rotation in degrees, applied with alternating sign per ring.
  final double rotationDeg;

  OrbitalRingsPainter({
    required this.radius,
    this.opacity = 1.0,
    this.visibleRings = 5,
    this.rotationDeg = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < visibleRings && i < kDefaultRings.length; i++) {
      // Alternate direction: even rings clockwise, odd counter-clockwise
      final sign = i.isEven ? 1.0 : -1.0;
      _drawDashedEllipse(canvas, center, kDefaultRings[i], sign * rotationDeg);
    }
  }

  void _drawDashedEllipse(
    Canvas canvas,
    Offset center,
    OrbitRingDef ring,
    double extraTilt,
  ) {
    final paint = Paint()
      ..color = ring.color.withValues(alpha: 0.15 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final effectiveTilt = ring.tilt + extraTilt;

    // Build elliptical path then rotate by tilt
    final path = Path();
    final ry = radius * ring.eccentricity;
    const steps = 120;
    for (int i = 0; i <= steps; i++) {
      final angle = (i / steps) * 2 * pi;
      final x = radius * cos(angle);
      final y = ry * sin(angle);
      // Rotate by tilt
      final tr = -effectiveTilt * pi / 180;
      final rx2 = x * cos(tr) - y * sin(tr);
      final ry2 = x * sin(tr) + y * cos(tr);
      if (i == 0) {
        path.moveTo(center.dx + rx2, center.dy + ry2);
      } else {
        path.lineTo(center.dx + rx2, center.dy + ry2);
      }
    }
    path.close();

    // Draw dashed
    _drawDashedPath(canvas, path, paint, dashLength: 6, gapLength: 4);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dashLength = 6,
    double gapLength = 4,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(OrbitalRingsPainter oldDelegate) =>
      radius != oldDelegate.radius ||
      opacity != oldDelegate.opacity ||
      visibleRings != oldDelegate.visibleRings ||
      rotationDeg != oldDelegate.rotationDeg;
}
