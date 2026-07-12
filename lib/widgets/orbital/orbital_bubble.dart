import 'dart:math';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/reminder.dart';
import '../../utils/platform_helper.dart';

/// Strips a leading emoji cluster (including variation selectors and ZWJ
/// joiners) plus surrounding whitespace from a reminder title.
String stripLeadingEmoji(String title) => title.replaceAll(
    RegExp(r'^[\p{So}\p{Sk}\p{Cf}\p{M}\s]+', unicode: true), '');

class OrbitalBubble extends StatefulWidget {
  final Reminder reminder;
  final DateTime currentTime;
  final bool isRunning;
  final double size;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const OrbitalBubble({
    super.key,
    required this.reminder,
    required this.currentTime,
    required this.isRunning,
    required this.onTap,
    required this.onLongPress,
    this.size = 56,
  });

  @override
  State<OrbitalBubble> createState() => _OrbitalBubbleState();
}

class _OrbitalBubbleState extends State<OrbitalBubble>
    with TickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final Random _rng = Random();
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
    _pulseCtrl = AnimationController(vsync: this);
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseCtrl.addStatusListener(_onPulseStatus);
    if (widget.isRunning) {
      _startRandomPulse();
    }
  }

  void _onPulseStatus(AnimationStatus status) {
    if (!widget.isRunning || !mounted) return;
    if (status == AnimationStatus.completed) {
      _pulseCtrl.reverse();
    } else if (status == AnimationStatus.dismissed) {
      // Random pause 50..250ms, then next pulse
      final pause = 50 + _rng.nextInt(201);
      Future.delayed(Duration(milliseconds: pause), () {
        if (mounted && widget.isRunning) _startRandomPulse();
      });
    }
  }

  void _startRandomPulse() {
    final ms = 100 + _rng.nextInt(1401); // 100..1500
    _pulseCtrl.duration = Duration(milliseconds: ms);
    _pulseCtrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant OrbitalBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _startRandomPulse();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _pulseCtrl
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.removeStatusListener(_onPulseStatus);
    _pressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  double _progressFraction() {
    final r = widget.reminder;
    if (!widget.isRunning || r.nextReminder == null) return 0;
    final total = r.interval.inSeconds;
    if (total <= 0) return 0;
    final elapsed =
        total - r.nextReminder!.difference(widget.currentTime).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  String _timerLabel() {
    final r = widget.reminder;
    if (!widget.isRunning || r.nextReminder == null) return '';
    final diff = r.nextReminder!.difference(widget.currentTime);
    if (diff.isNegative) return '0:00';
    final m = diff.inMinutes;
    final s = diff.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  bool get _isTriggered {
    final r = widget.reminder;
    return widget.isRunning &&
        r.isEnabled &&
        r.nextReminder != null &&
        widget.currentTime.isAfter(r.nextReminder!);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reminder;
    final progress = _progressFraction();
    final timer = _timerLabel();
    final triggered = _isTriggered;
    final s = widget.size;

    return Semantics(
      button: true,
      label: AppLocalizations.of(context)
              ?.editReminderNamed(stripLeadingEmoji(r.title)) ??
          stripLeadingEmoji(r.title),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTapDown: (_) => _pressCtrl.forward(),
          onTapUp: (_) {
            _pressCtrl.reverse();
            widget.onTap();
          },
          onTapCancel: () => _pressCtrl.reverse(),
          onLongPress: () {
            _pressCtrl.reverse();
            widget.onLongPress();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([_pressAnim, _pulseAnim]),
            builder: (context, child) => Transform.scale(
              scale: _pressAnim.value * _pulseAnim.value,
              child: Opacity(
                opacity: 0.85 + 0.15 * _pulseAnim.value,
                child: child,
              ),
            ),
            child: SizedBox(
              width: s + 24,
              height: s + 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bubble circle with progress ring
                  SizedBox(
                    width: s,
                    height: s,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress ring
                        if (widget.isRunning && r.isEnabled)
                          CustomPaint(
                            size: Size(s, s),
                            painter: _ProgressRingPainter(
                              progress: progress,
                              color: r.color,
                              triggered: triggered,
                            ),
                          ),
                        // Circle bg
                        Container(
                          width: s - 6,
                          height: s - 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: triggered
                                ? r.color
                                : r.color.withValues(alpha: 0.15),
                            border: Border.all(
                              color: r.color.withValues(
                                alpha: triggered ? 1.0 : 0.4,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              r.icon,
                              size: s * 0.38,
                              color: triggered ? Colors.white : r.color,
                            ),
                          ),
                        ),
                        // Desktop hover edit overlay
                        if (_hovering && PlatformHelper.isDesktop)
                          Container(
                            width: s - 6,
                            height: s - 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Timer or title label
                  Text(
                    timer.isNotEmpty ? timer : stripLeadingEmoji(r.title),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: triggered
                          ? r.color
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool triggered;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    this.triggered = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final arcPaint = Paint()
      ..color = triggered ? color : color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progress * 2 * pi,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      triggered != oldDelegate.triggered;
}
