import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/reminder.dart';
import 'orbital_rings_painter.dart';
import 'center_button.dart';
import 'orbital_bubble.dart';

class OrbitalField extends StatefulWidget {
  final List<Reminder> activeReminders;
  final bool isRunning;
  final DateTime currentTime;
  final VoidCallback onToggleRunning;
  final void Function(Reminder) onTapBubble;
  final void Function(Reminder) onLongPressBubble;
  final VoidCallback onAddReminder;
  final VoidCallback? onClearTimers;

  static const double _bubbleSize = 64;

  const OrbitalField({
    super.key,
    required this.activeReminders,
    required this.isRunning,
    required this.currentTime,
    required this.onToggleRunning,
    required this.onTapBubble,
    required this.onLongPressBubble,
    required this.onAddReminder,
    this.onClearTimers,
  });

  @override
  State<OrbitalField> createState() => _OrbitalFieldState();
}

class _OrbitalFieldState extends State<OrbitalField>
    with SingleTickerProviderStateMixin {
  late AnimationController _wispCtrl;

  @override
  void initState() {
    super.initState();
    _wispCtrl = AnimationController(
      duration: const Duration(milliseconds: 12000),
      vsync: this,
    );
    if (widget.isRunning) _wispCtrl.repeat();
  }

  @override
  void didUpdateWidget(covariant OrbitalField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _wispCtrl.repeat();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _wispCtrl
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _wispCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth;
        final fieldHeight = constraints.maxHeight;
        final orbitalSize = min(fieldWidth, fieldHeight);
        final radius = orbitalSize * 0.45;
        final center = Offset(fieldWidth / 2, fieldHeight / 2);

        final count = min(widget.activeReminders.length, 15);
        final visibleRings = (count / 3).ceil();

        // Collect bubble colors for wisps
        final bubblePositions = <Offset>[];
        final bubbleColors = <Color>[];
        for (int i = 0; i < count; i++) {
          bubblePositions.add(center + slotPosition(i, radius));
          bubbleColors.add(widget.activeReminders[i].color);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: fieldWidth,
          height: fieldHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Orbit rings
              Positioned.fill(
                child: CustomPaint(
                  painter: OrbitalRingsPainter(
                    radius: radius,
                    opacity: 1.0,
                    visibleRings: visibleRings,
                  ),
                ),
              ),
              // Energy wisps layer
              if (widget.isRunning && bubblePositions.isNotEmpty)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _wispCtrl,
                    builder: (context, _) => CustomPaint(
                      painter: _EnergyWispsPainter(
                        progress: _wispCtrl.value,
                        center: center,
                        bubblePositions: bubblePositions,
                        bubbleColors: bubbleColors,
                      ),
                    ),
                  ),
                ),
              // Center button with add badge
              Positioned(
                left: center.dx - 54,
                top: center.dy - 54,
                child: CenterButton(
                  isRunning: widget.isRunning,
                  activeCount:
                      widget.activeReminders.where((r) => r.isEnabled).length,
                  onToggle: widget.onToggleRunning,
                  onAdd: count < 15 ? widget.onAddReminder : null,
                  onClear: widget.isRunning ? widget.onClearTimers : null,
                ),
              ),
              // Reminder bubbles at fixed slots
              for (int i = 0; i < count; i++)
                Positioned(
                  left: center.dx +
                      slotPosition(i, radius).dx -
                      (OrbitalField._bubbleSize + 24) / 2,
                  top: center.dy +
                      slotPosition(i, radius).dy -
                      (OrbitalField._bubbleSize + 30) / 2,
                  child: OrbitalBubble(
                    reminder: widget.activeReminders[i],
                    currentTime: widget.currentTime,
                    isRunning: widget.isRunning,
                    size: OrbitalField._bubbleSize,
                    onTap: () =>
                        widget.onTapBubble(widget.activeReminders[i]),
                    onLongPress: () =>
                        widget.onLongPressBubble(widget.activeReminders[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Paints small glowing dots traveling from each bubble toward the center
/// along curved bezier paths. Each wisp starts from a different point on
/// the bubble's edge and arcs inward — slow at first, then pulled in fast
/// like a magnetic field.
class _EnergyWispsPainter extends CustomPainter {
  final double progress; // 0→1 repeating
  final Offset center;
  final List<Offset> bubblePositions;
  final List<Color> bubbleColors;

  static const int _wispsPerBubble = 3;
  // Deterministic "random" angles per wisp slot so paths don't jitter
  static const List<double> _edgeAngles = [0.4, 2.7, 4.9, 1.2, 3.8, 5.5];
  static const List<double> _curveSigns = [1, -1, 1, -1, 1, -1];
  static const List<double> _curveStrengths = [0.38, 0.25, 0.45, 0.32, 0.40, 0.28];

  _EnergyWispsPainter({
    required this.progress,
    required this.center,
    required this.bubblePositions,
    required this.bubbleColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < bubblePositions.length; i++) {
      final bubbleCenter = bubblePositions[i];
      final color = bubbleColors[i];

      for (int w = 0; w < _wispsPerBubble; w++) {
        final slot = (i * _wispsPerBubble + w) % _edgeAngles.length;

        // Start point: offset from bubble center along a fixed angle (edge)
        final edgeAngle = _edgeAngles[slot];
        const edgeRadius = 20.0; // roughly half the bubble visual size
        final from = Offset(
          bubbleCenter.dx + cos(edgeAngle) * edgeRadius,
          bubbleCenter.dy + sin(edgeAngle) * edgeRadius,
        );

        // Control point: offset perpendicular to the direct line
        final mid = Offset.lerp(from, center, 0.45)!;
        final dx = center.dx - from.dx;
        final dy = center.dy - from.dy;
        final dist = sqrt(dx * dx + dy * dy);
        final perpX = -dy / dist;
        final perpY = dx / dist;
        final curveOffset =
            dist * _curveStrengths[slot] * _curveSigns[slot];
        final ctrl = Offset(
          mid.dx + perpX * curveOffset,
          mid.dy + perpY * curveOffset,
        );

        // Stagger each wisp evenly across the cycle
        final linear = (progress + w / _wispsPerBubble) % 1.0;
        // Cubic ease-in: crawl at the edge, accelerate into center
        final t = linear * linear * linear;

        // Quadratic bezier: B(t) = (1-t)²·from + 2(1-t)t·ctrl + t²·center
        final u = 1.0 - t;
        final pos = Offset(
          u * u * from.dx + 2 * u * t * ctrl.dx + t * t * center.dx,
          u * u * from.dy + 2 * u * t * ctrl.dy + t * t * center.dy,
        );

        // Brighter + bigger glow closer to center
        final alpha = 0.04 + 0.50 * t;
        final blur = 1.5 + 3.5 * t;
        final r = t < 0.85 ? 2.0 + 2.0 * t : 2.0 + 2.0 * (1.0 - t) * 6.67;

        final paint = Paint()
          ..color = color.withValues(alpha: alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
        canvas.drawCircle(pos, r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_EnergyWispsPainter oldDelegate) => true;
}
