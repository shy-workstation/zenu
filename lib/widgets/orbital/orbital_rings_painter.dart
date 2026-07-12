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

/// Result of laying out [count] bubbles as evenly-spaced concentric rings.
///
/// [positions] are offsets relative to the field centre (one per bubble).
/// [ringRadii] are the base circle radii of the rings that were used, and
/// [stretchX]/[stretchY] are the ellipse factors applied to fill the available
/// space (≥ 1 — they only ever push bubbles further apart, so spacing computed
/// on the base circle stays collision-free).
class OrbitalLayout {
  final List<Offset> positions;
  final List<double> ringRadii;
  final double stretchX;
  final double stretchY;

  const OrbitalLayout({
    required this.positions,
    required this.ringRadii,
    required this.stretchX,
    required this.stretchY,
  });
}

/// Distributes [count] bubbles across concentric rings so they never overlap.
///
/// Each ring is spaced at least one bubble-width outward from the previous one,
/// and every ring holds at most as many bubbles as its circumference can fit.
/// The whole arrangement is then stretched to an ellipse that fills the
/// available width and height — so on a tall phone the bubbles use the vertical
/// space instead of crowding a narrow horizontal band.
OrbitalLayout computeOrbitalLayout({
  required int count,
  required double fieldWidth,
  required double fieldHeight,
  required double bubbleSize,
  double rotation = 0,
}) {
  // Keep the bubble circle and its label inside the field.
  final marginX = bubbleSize / 2 + 8;
  final marginY = bubbleSize / 2 + 30; // label sits below the circle
  final maxRx = max(1.0, fieldWidth / 2 - marginX);
  final maxRy = max(1.0, fieldHeight / 2 - marginY);
  final baseMax = min(maxRx, maxRy);
  final stretchX = maxRx / baseMax; // ≥ 1
  final stretchY = maxRy / baseMax; // ≥ 1

  if (count <= 0) {
    return OrbitalLayout(
      positions: const [],
      ringRadii: const [],
      stretchX: stretchX,
      stretchY: stretchY,
    );
  }

  // Innermost ring must clear the centre start/pause button.
  final minR = min(baseMax, 62 + bubbleSize / 2);
  // Minimum centre-to-centre distance between two bubbles.
  final slot = bubbleSize + 20;

  // Candidate ring radii, stepped one slot apart, out to the edge.
  final radii = <double>[];
  for (double r = minR; r <= baseMax + 0.5 && radii.length < 5; r += slot) {
    radii.add(r);
  }
  if (radii.isEmpty) radii.add(minR);

  // How many bubbles each ring's circumference can hold.
  final caps = radii.map((r) => max(3, (2 * pi * r / slot).floor())).toList();

  // Use the fewest rings whose combined capacity covers the count.
  int rings = 1;
  int capSum = caps[0];
  while (capSum < count && rings < radii.length) {
    capSum += caps[rings];
    rings++;
  }

  // Split the bubbles across those rings, weighted by capacity, then hand any
  // rounding leftovers to whichever ring has the most spare room.
  final totalCap = caps.take(rings).fold<int>(0, (a, b) => a + b);
  final counts = List<int>.filled(rings, 0);
  int placed = 0;
  for (int i = 0; i < rings; i++) {
    counts[i] = ((count * caps[i]) / totalCap).floor().clamp(0, caps[i]);
    placed += counts[i];
  }
  int leftover = count - placed;
  while (leftover > 0) {
    var best = 0;
    var bestSlack = -1;
    for (int i = 0; i < rings; i++) {
      final slack = caps[i] - counts[i];
      if (slack > bestSlack) {
        bestSlack = slack;
        best = i;
      }
    }
    if (bestSlack <= 0) break; // every ring full (shouldn't happen for ≤15)
    counts[best]++;
    leftover--;
  }

  final positions = <Offset>[];
  final usedRadii = <double>[];
  for (int m = 0; m < rings; m++) {
    final k = counts[m];
    if (k == 0) continue;
    final r = radii[m];
    usedRadii.add(r);
    // Rigid per-ring rotation keeps within-ring spacing intact (and rings at
    // different radii never collide), so drifting stays overlap-free. Inner
    // rings turn a little faster than outer ones, like real orbits.
    final ringSpeed = (1.0 - m * 0.28).clamp(0.3, 1.0);
    // Stagger each ring so bubbles don't line up radially with the ring inside.
    final phase = m * 0.55 - pi / 2 + rotation * ringSpeed;
    for (int j = 0; j < k; j++) {
      final a = phase + j * (2 * pi / k);
      positions.add(Offset(r * cos(a) * stretchX, r * sin(a) * stretchY));
    }
  }

  return OrbitalLayout(
    positions: positions,
    ringRadii: usedRadii,
    stretchX: stretchX,
    stretchY: stretchY,
  );
}

/// Draws one dashed ellipse per active ring, matching [computeOrbitalLayout]'s
/// [OrbitalLayout.ringRadii] and stretch factors so the decorative rings line up
/// with where the bubbles actually sit.
class OrbitalRingsPainter extends CustomPainter {
  final List<double> ringRadii;
  final double stretchX;
  final double stretchY;
  final double opacity;

  OrbitalRingsPainter({
    required this.ringRadii,
    this.stretchX = 1.0,
    this.stretchY = 1.0,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < ringRadii.length; i++) {
      final color = kDefaultRings[i % kDefaultRings.length].color;
      _drawDashedEllipse(
        canvas,
        center,
        ringRadii[i] * stretchX,
        ringRadii[i] * stretchY,
        color,
      );
    }
  }

  void _drawDashedEllipse(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    Color color,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Build the axis-aligned elliptical path.
    final path = Path();
    const steps = 120;
    for (int i = 0; i <= steps; i++) {
      final angle = (i / steps) * 2 * pi;
      final x = rx * cos(angle);
      final y = ry * sin(angle);
      if (i == 0) {
        path.moveTo(center.dx + x, center.dy + y);
      } else {
        path.lineTo(center.dx + x, center.dy + y);
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
  bool shouldRepaint(OrbitalRingsPainter oldDelegate) {
    if (opacity != oldDelegate.opacity ||
        stretchX != oldDelegate.stretchX ||
        stretchY != oldDelegate.stretchY ||
        ringRadii.length != oldDelegate.ringRadii.length) {
      return true;
    }
    for (int i = 0; i < ringRadii.length; i++) {
      if (ringRadii[i] != oldDelegate.ringRadii[i]) return true;
    }
    return false;
  }
}
