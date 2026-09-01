import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/care_activity.dart';
import '../zenu_theme.dart';

/// One circular need meter: fills as the need grows, full ring = due.
class NeedRing extends StatelessWidget {
  final CareActivity activity;
  final double fraction;
  final bool overdue;
  final String label;
  final VoidCallback? onTap;

  const NeedRing({
    super.key,
    required this.activity,
    required this.fraction,
    required this.overdue,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = ZenuColors.forKind(activity.kind);
    final theme = Theme.of(context);
    return Semantics(
      button: onTap != null,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CustomPaint(
                  painter: _RingPainter(
                    fraction: fraction,
                    color: color,
                    trackColor: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.45),
                  ),
                  child: Icon(
                    ZenuColors.iconForKind(activity.kind),
                    size: 20,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: overdue ? FontWeight.w800 : FontWeight.w600,
                  color: overdue ? color : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.fraction,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;
    canvas.drawCircle(center, radius, track);
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}
