import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
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
    with TickerProviderStateMixin {
  late AnimationController _wispCtrl;

  // Orbital drift. The angle is *accumulated* from elapsed frame time and only
  // advances while actively drifting, so it is monotonic: pausing simply stops
  // adding to it (bubbles hold their exact positions) and resuming continues
  // from the identical value — no jump, ever.
  late Ticker _driftTicker;
  Duration _lastElapsed = Duration.zero;
  double _rotation = 0; // accumulated drift angle in radians
  bool _touching = false;

  // Seconds for one full turn of the base ring.
  static const double _driftPeriodSeconds = 300;

  bool get _drifting => widget.isRunning && !_touching;

  void _onDriftTick(Duration elapsed) {
    final dt = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (!_drifting) return;
    // Skip abnormally large gaps (e.g. after the app was backgrounded and the
    // ticker was muted) so the drift never lurches forward on resume.
    if (dt.inMilliseconds > 100) return;
    setState(() {
      _rotation += (dt.inMicroseconds / (_driftPeriodSeconds * 1e6)) * 2 * pi;
    });
  }

  @override
  void initState() {
    super.initState();
    _wispCtrl = AnimationController(
      duration: const Duration(milliseconds: 12000),
      vsync: this,
    );
    _driftTicker = createTicker(_onDriftTick);
    if (widget.isRunning) {
      _wispCtrl.repeat();
      _driftTicker.start();
    }
  }

  @override
  void didUpdateWidget(covariant OrbitalField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _wispCtrl.repeat();
      _startDrift();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _wispCtrl
        ..stop()
        ..reset();
      _driftTicker.stop(); // freezes _rotation at its current value
    }
  }

  void _startDrift() {
    if (_driftTicker.isActive) return;
    _lastElapsed = Duration.zero;
    _driftTicker.start();
  }

  @override
  void dispose() {
    _wispCtrl.dispose();
    _driftTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth;
        final fieldHeight = constraints.maxHeight;
        final orbitalSize = min(fieldWidth, fieldHeight);

        // Scale bubble size to the available space.
        final bubbleSize = (orbitalSize * 0.13).clamp(40.0, 64.0);
        final center = Offset(fieldWidth / 2, fieldHeight / 2);

        final count = min(widget.activeReminders.length, 15);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: fieldWidth,
          height: fieldHeight,
          // Freeze the drift while a finger/cursor is down so moving bubbles are
          // easy to tap; resume when it lifts.
          child: Listener(
            behavior: HitTestBehavior.deferToChild,
            onPointerDown: (_) {
              if (widget.isRunning && !_touching) {
                setState(() => _touching = true);
              }
            },
            onPointerUp: (_) {
              if (_touching) setState(() => _touching = false);
            },
            onPointerCancel: (_) {
              if (_touching) setState(() => _touching = false);
            },
            child: Builder(
              builder: (context) {
                // The drift angle is frozen while paused/touched, so bubbles
                // keep their exact positions instead of snapping.
                final rotation = _rotation;

                // Recompute the concentric, collision-free layout for the
                // current drift angle. Cheap (trig for ≤15 points).
                final layout = computeOrbitalLayout(
                  count: count,
                  fieldWidth: fieldWidth,
                  fieldHeight: fieldHeight,
                  bubbleSize: bubbleSize,
                  rotation: rotation,
                );

                final bubblePositions = <Offset>[];
                final bubbleColors = <Color>[];
                for (int i = 0; i < count && i < layout.positions.length; i++) {
                  bubblePositions.add(center + layout.positions[i]);
                  bubbleColors.add(widget.activeReminders[i].color);
                }

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Orbit rings — decorative dashed ellipses matching the
                    // active rings.
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: OrbitalRingsPainter(
                            ringRadii: layout.ringRadii,
                            stretchX: layout.stretchX,
                            stretchY: layout.stretchY,
                            opacity: 1.0,
                          ),
                        ),
                      ),
                    ),
                    // Energy wisps layer — kept in its own repaint boundary.
                    if (widget.isRunning && bubblePositions.isNotEmpty)
                      Positioned.fill(
                        child: RepaintBoundary(
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
                      ),
                    // Center start/pause button with add + clear badges.
                    Positioned(
                      left: center.dx - 54,
                      top: center.dy - 54,
                      child: CenterButton(
                        isRunning: widget.isRunning,
                        activeCount: widget.activeReminders
                            .where((r) => r.isEnabled)
                            .length,
                        onToggle: widget.onToggleRunning,
                        onAdd: count < 15 ? widget.onAddReminder : null,
                        onClear: widget.isRunning ? widget.onClearTimers : null,
                      ),
                    ),
                    // Reminder bubbles. While running they follow the drift each
                    // frame (plain Positioned); while stopped they glide between
                    // layouts on add/remove (AnimatedPositioned).
                    for (int i = 0;
                        i < count && i < layout.positions.length;
                        i++)
                      if (widget.isRunning)
                        Positioned(
                          key: ValueKey('slot-${widget.activeReminders[i].id}'),
                          left: center.dx +
                              layout.positions[i].dx -
                              (bubbleSize + 24) / 2,
                          top: center.dy +
                              layout.positions[i].dy -
                              (bubbleSize + 30) / 2,
                          child: _bubble(i, bubbleSize),
                        )
                      else
                        AnimatedPositioned(
                          key: ValueKey('slot-${widget.activeReminders[i].id}'),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          left: center.dx +
                              layout.positions[i].dx -
                              (bubbleSize + 24) / 2,
                          top: center.dy +
                              layout.positions[i].dy -
                              (bubbleSize + 30) / 2,
                          child: _bubble(i, bubbleSize),
                        ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _bubble(int i, double bubbleSize) {
    final reminder = widget.activeReminders[i];
    return OrbitalBubble(
      key: ValueKey(reminder.id),
      reminder: reminder,
      currentTime: widget.currentTime,
      isRunning: widget.isRunning,
      size: bubbleSize,
      onTap: () => widget.onTapBubble(reminder),
      onLongPress: () => widget.onLongPressBubble(reminder),
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
  static const List<double> _curveStrengths = [
    0.38,
    0.25,
    0.45,
    0.32,
    0.40,
    0.28
  ];

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
        final curveOffset = dist * _curveStrengths[slot] * _curveSigns[slot];
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
