import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/pet.dart';
import '../../domain/pet_profile.dart';
import 'pet_painter.dart';

/// The companion, alive on screen: it breathes, blinks, looks around,
/// moves the way it feels, and bounces when tapped or when its mood
/// changes. Wrapped in its own RepaintBoundary so none of that repaints
/// the screen around it.
class PetView extends StatefulWidget {
  final PetProfile profile;
  final PetMood mood;
  final double size;
  final bool animated;

  /// Called after the tap bounce starts. The bounce itself needs no
  /// caller cooperation.
  final VoidCallback? onTap;

  const PetView({
    super.key,
    required this.profile,
    required this.mood,
    this.size = 240,
    this.animated = true,
    this.onTap,
  });

  @override
  State<PetView> createState() => _PetViewState();
}

class _PetViewState extends State<PetView> with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late final AnimationController _react = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );
  late final CurvedAnimation _curved =
      CurvedAnimation(parent: _react, curve: Curves.easeOut);
  bool _happy = false;

  @override
  void initState() {
    super.initState();
    if (widget.animated) _idle.repeat();
  }

  @override
  void didUpdateWidget(PetView old) {
    super.didUpdateWidget(old);
    if (widget.animated != old.animated) {
      if (widget.animated) {
        _idle.repeat();
      } else {
        _idle.stop();
      }
    }
    if (widget.animated && widget.mood != old.mood) {
      _bounce(happy: false);
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _idle.dispose();
    _react.dispose();
    super.dispose();
  }

  void _bounce({required bool happy}) {
    _happy = happy;
    _react.forward(from: 0);
  }

  void _onTap() {
    if (!widget.animated) return;
    HapticFeedback.lightImpact();
    _bounce(happy: true);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: RepaintBoundary(
        child: SizedBox(
          width: widget.size,
          height: widget.size * PetPainter.designHeight / 200,
          child: AnimatedBuilder(
            animation: Listenable.merge([_idle, _react]),
            builder: (context, _) => CustomPaint(
              painter: PetPainter(
                profile: widget.profile,
                mood: widget.mood,
                t: _idle.value,
                react: _curved.value,
                happy: _happy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
