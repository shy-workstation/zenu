import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/pet.dart';
import '../../domain/pet_profile.dart';
import 'pet_cosmetics.dart';
import 'pet_motion.dart';

/// Draws the companion in a 200x182 design space (plus [headroom] above
/// for hats, halos, balloons, and the jump): a soft blob in the
/// user's colour and pattern, a mood-driven face, and whatever it wears.
/// All motion is a pure function of [t] (idle phase) and [react] (tap /
/// mood-change bounce), so the painter stays stateless.
class PetPainter extends CustomPainter {
  final PetProfile profile;
  final PetMood mood;

  /// 0..1 idle phase over a 6 s loop: breath, blink, sway, hop.
  final double t;

  /// 0..1 progress of a one-shot bounce; 1 = idle.
  final double react;

  /// The bounce was a tap: happy eyes and a couple of hearts.
  final bool happy;

  PetPainter({
    required this.profile,
    required this.mood,
    required this.t,
    this.react = 1,
    this.happy = false,
  });

  static const ink = Color(0xFF2B3B4E);
  static const _base = Offset(100, 170);

  /// Extra design-space pixels above the 182-tall body box.
  static const double headroom = 26;
  static const double designHeight = 182 + headroom;

  PetColor get color => profile.color;
  PetSpecies get species => profile.species ?? PetSpecies.miro;

  static Path bodyPath() => Path()
    ..moveTo(100, 18)
    ..cubicTo(146, 18, 176, 52, 176, 98)
    ..cubicTo(176, 142, 142, 170, 100, 170)
    ..cubicTo(58, 170, 24, 142, 24, 98)
    ..cubicTo(24, 52, 54, 18, 100, 18)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.width / 200);
    canvas.translate(0, headroom);
    final motion = PetMotion.of(mood, t, react);

    // Ground shadow: stays put, shrinks a little while the pet is in the air.
    final lift = (-motion.dy / 24).clamp(0.0, 1.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 172),
        width: 124 - 30 * lift,
        height: 18 - 6 * lift,
      ),
      Paint()..color = ink.withValues(alpha: 0.08 - 0.03 * lift),
    );

    canvas.save();
    canvas.translate(_base.dx, _base.dy + motion.dy);
    canvas.rotate(motion.rotate);
    canvas.scale(motion.sx, motion.sy);
    canvas.translate(-_base.dx, -_base.dy);

    _paintBody(canvas, motion);
    _paintPattern(canvas);
    _paintMarking(canvas);
    _paintFace(canvas, motion);
    paintCosmetics(canvas, profile.worn, t);
    canvas.restore();

    _paintMoodExtras(canvas);
    if (happy && react < 1) _paintHearts(canvas);
  }

  // ------------------------------------------------------------------ body

  void _paintBody(Canvas canvas, PetMotion motion) {
    final body = bodyPath();
    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 0.95,
          colors: [color.top, color.mid, color.bottom],
          stops: const [0, 0.6, 1],
        ).createShader(const Rect.fromLTWH(24, 18, 152, 152)),
    );

    // Arms: raised and pumping while stretching, flexing while mighty.
    if (mood == PetMood.stretchy || mood == PetMood.mighty) {
      final arms = Paint()
        ..color = color.bottom
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      final raise = mood == PetMood.stretchy
          ? 10 * math.sin(t * 2 * math.pi * 2)
          : 5 * math.sin(t * 2 * math.pi * 3);
      canvas.drawPath(
        Path()
          ..moveTo(36, 104)
          ..cubicTo(14, 96, 8, 74 + raise, 24, 52 + raise),
        arms,
      );
      canvas.drawPath(
        Path()
          ..moveTo(164, 104)
          ..cubicTo(186, 96, 192, 74 + raise, 176, 52 + raise),
        arms,
      );
    }
  }

  void _paintPattern(Canvas canvas) {
    if (profile.pattern == PetPattern.plain) return;
    canvas.save();
    canvas.clipPath(bodyPath());
    final paint = Paint()..color = color.bottom.withValues(alpha: 0.55);
    switch (profile.pattern) {
      case PetPattern.spots:
        for (final (c, r) in const [
          (Offset(54, 140), 9.0),
          (Offset(146, 132), 11.0),
          (Offset(100, 156), 8.0),
          (Offset(40, 96), 6.0),
          (Offset(162, 76), 7.0),
          (Offset(72, 40), 6.0),
        ]) {
          canvas.drawCircle(c, r, paint);
        }
      case PetPattern.freckles:
        final dot = Paint()..color = ink.withValues(alpha: 0.35);
        for (final c in const [
          Offset(44, 104), Offset(52, 118), Offset(60, 108),
          Offset(156, 104), Offset(148, 118), Offset(140, 108),
        ]) {
          canvas.drawCircle(c, 2.2, dot);
        }
      case PetPattern.stripes:
        final stripe = Paint()
          ..color = color.bottom.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9;
        for (final y in const [128.0, 146.0, 164.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(10, y)
              ..quadraticBezierTo(100, y + 14, 190, y),
            stripe,
          );
        }
      case PetPattern.heart:
        drawHeart(canvas, const Offset(100, 146), 13,
            Paint()..color = color.blush.withValues(alpha: 0.75));
      case PetPattern.plain:
        break;
    }
    canvas.restore();
  }

  void _paintMarking(Canvas canvas) {
    switch (species) {
      case PetSpecies.miro:
        // Sprout leaves: always green, it is a plant after all.
        canvas.drawPath(
          Path()
            ..moveTo(100, 20)
            ..cubicTo(98, 10, 92, 4, 84, 2)
            ..cubicTo(90, 12, 94, 16, 100, 20)
            ..close(),
          Paint()..color = const Color(0xFF34C79A),
        );
        canvas.drawPath(
          Path()
            ..moveTo(100, 20)
            ..cubicTo(102, 8, 108, 2, 118, 0)
            ..cubicTo(112, 12, 106, 16, 100, 20)
            ..close(),
          Paint()..color = const Color(0xFF2AAE85),
        );
      case PetSpecies.pip:
        final tuft = Paint()..color = color.accent;
        canvas.drawPath(
          Path()
            ..moveTo(78, 24)
            ..quadraticBezierTo(84, 8, 96, 14)
            ..quadraticBezierTo(90, 20, 88, 26)
            ..close(),
          tuft,
        );
        canvas.drawPath(
          Path()
            ..moveTo(122, 24)
            ..quadraticBezierTo(116, 8, 104, 14)
            ..quadraticBezierTo(110, 20, 112, 26)
            ..close(),
          tuft,
        );
      case PetSpecies.luma:
        drawStar(canvas, const Offset(104, 16), 14,
            Paint()..color = color.accent.withValues(alpha: 0.85));
    }
  }

  // ------------------------------------------------------------------ face

  void _paintFace(Canvas canvas, PetMotion motion) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = ink;

    final blinkPhase = (t * 2) % 1;
    final blinking = blinkPhase > 0.94 && blinkPhase < 0.99;
    final happyNow = happy && react < 1;

    // Eyebrows.
    if (mood == PetMood.thirsty) {
      stroke.strokeWidth = 3.5;
      canvas.drawPath(
        Path()
          ..moveTo(54, 74)
          ..quadraticBezierTo(64, 69, 74, 76),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(126, 76)
          ..quadraticBezierTo(136, 69, 146, 74),
        stroke,
      );
      stroke.strokeWidth = 4;
    } else if (mood == PetMood.mighty) {
      stroke.strokeWidth = 3.5;
      canvas.drawLine(const Offset(54, 78), const Offset(74, 72), stroke);
      canvas.drawLine(const Offset(126, 72), const Offset(146, 78), stroke);
      stroke.strokeWidth = 4;
    }

    // Eyes.
    if (happyNow) {
      stroke.strokeWidth = 4.5;
      for (final cx in [66.0, 134.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(cx - 10, 93)
            ..quadraticBezierTo(cx, 80, cx + 10, 93),
          stroke,
        );
      }
      stroke.strokeWidth = 4;
    } else if (blinking ||
        mood == PetMood.resting ||
        mood == PetMood.stretchy) {
      stroke.strokeWidth = 4.5;
      for (final cx in [66.0, 134.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(cx - 10, 90)
            ..quadraticBezierTo(cx, 84, cx + 10, 90),
          stroke,
        );
      }
      stroke.strokeWidth = 4;
    } else {
      // Open eyes wander a little; tired eyes are heavy-lidded.
      final look = motion.look;
      final lid = mood == PetMood.tiredEyes
          ? 0.55 + 0.1 * math.sin(t * 2 * math.pi * 1.5)
          : 0.0;
      for (final cx in [66.0, 134.0]) {
        final eye =
            Rect.fromCenter(center: Offset(cx, 91), width: 16, height: 21);
        canvas.drawOval(eye.shift(look), fill);
        canvas.drawCircle(
            Offset(cx + 3, 87) + look, 3, Paint()..color = Colors.white);
        if (lid > 0) {
          final shifted = eye.shift(look);
          final lidY = shifted.top + shifted.height * lid;
          canvas.save();
          canvas.clipPath(Path()..addOval(shifted.inflate(1)));
          canvas.drawRect(
            Rect.fromLTRB(shifted.left - 2, shifted.top - 2,
                shifted.right + 2, lidY),
            Paint()..color = color.mid,
          );
          canvas.restore();
          stroke.strokeWidth = 3;
          canvas.drawLine(Offset(shifted.left - 1, lidY),
              Offset(shifted.right + 1, lidY), stroke);
          stroke.strokeWidth = 4;
        }
      }
    }

    // Blush.
    final blush = Paint()
      ..color = color.blush.withValues(alpha: happyNow ? 0.7 : 0.45);
    canvas.drawCircle(const Offset(50, 110), 9, blush);
    canvas.drawCircle(const Offset(150, 110), 9, blush);

    // Mouth.
    if (happyNow) {
      canvas.drawPath(
        Path()
          ..moveTo(84, 114)
          ..quadraticBezierTo(100, 134, 116, 114)
          ..close(),
        Paint()..color = const Color(0xFF5C3A44),
      );
      return;
    }
    switch (mood) {
      case PetMood.thirsty:
        canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(100, 122), width: 16, height: 20),
          Paint()..color = const Color(0xFF5C3A44),
        );
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(100, 127), width: 10, height: 8),
          Paint()..color = const Color(0xFFF08A9B),
        );
      case PetMood.tiredEyes:
        // A slow yawn.
        final yawn = math.max(0.0, math.sin(t * 2 * math.pi));
        canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(100, 120),
              width: 8 + 6 * yawn,
              height: 3 + 14 * yawn),
          Paint()..color = const Color(0xFF5C3A44),
        );
      case PetMood.fidgety:
        canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(100, 120), width: 14, height: 16),
          Paint()..color = const Color(0xFF5C3A44),
        );
      default:
        stroke.strokeWidth = 4.5;
        canvas.drawPath(
          Path()
            ..moveTo(87, 116)
            ..quadraticBezierTo(100, 127, 113, 116),
          stroke,
        );
    }
  }

  // ----------------------------------------------------------- mood extras

  void _paintMoodExtras(Canvas canvas) {
    final wave = math.sin(t * 2 * math.pi * 2);
    switch (mood) {
      case PetMood.thirsty:
        final dy = 3 * wave;
        canvas.drawPath(
          Path()
            ..moveTo(160, 40 + dy)
            ..cubicTo(160, 40 + dy, 152, 50 + dy, 152, 55 + dy)
            ..cubicTo(152, 59.5 + dy, 155.5, 63 + dy, 160, 63 + dy)
            ..cubicTo(164.5, 63 + dy, 168, 59.5 + dy, 168, 55 + dy)
            ..cubicTo(168, 50 + dy, 160, 40 + dy, 160, 40 + dy)
            ..close(),
          Paint()..color = const Color(0xFF06B6D4),
        );
      case PetMood.tiredEyes:
        drawStar(
          canvas,
          const Offset(42, 58),
          12,
          Paint()
            ..color = const Color(0xFF3B82F6)
                .withValues(alpha: 0.45 + 0.3 * wave),
        );
        drawStar(
          canvas,
          const Offset(162, 68),
          9,
          Paint()
            ..color = const Color(0xFF3B82F6)
                .withValues(alpha: 0.45 - 0.3 * wave),
        );
      case PetMood.fidgety:
        final pulse = 0.4 + 0.4 * math.sin(t * 2 * math.pi * 6).abs();
        final arc = Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(const Rect.fromLTWH(168, 82, 14, 26), -math.pi / 3,
            2 * math.pi / 3, false, arc);
        canvas.drawArc(const Rect.fromLTWH(176, 74, 18, 42), -math.pi / 3,
            2 * math.pi / 3, false, arc);
        canvas.drawArc(const Rect.fromLTWH(18, 82, 14, 26), 2 * math.pi / 3,
            2 * math.pi / 3, false, arc);
      case PetMood.mighty:
        final bob = 3 * math.sin(t * 2 * math.pi * 3);
        final bar = Paint()
          ..color = const Color(0xFFF97316)
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            Offset(148, 136 + bob), Offset(178, 126 + bob), bar);
        canvas.drawCircle(Offset(148, 136 + bob), 6.5, bar);
        canvas.drawCircle(Offset(178, 126 + bob), 6.5, bar);
      case PetMood.resting:
        // Three z's drifting up and fading, staggered along the loop.
        for (var i = 0; i < 3; i++) {
          final phase = ((t * 1.5) + i / 3) % 1;
          final style = TextStyle(
            color: ink.withValues(alpha: 0.55 * (1 - phase)),
            fontSize: 12 + 8 * phase,
            fontWeight: FontWeight.w800,
          );
          final painter = TextPainter(
            text: TextSpan(text: 'z', style: style),
            textDirection: TextDirection.ltr,
          )..layout();
          painter.paint(
              canvas, Offset(150 + 14 * phase, 46 - 34 * phase));
        }
      default:
        break;
    }
  }

  void _paintHearts(Canvas canvas) {
    final p = react;
    for (final (x, delay) in const [(46.0, 0.0), (152.0, 0.18)]) {
      final q = ((p - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (q <= 0) continue;
      drawHeart(
        canvas,
        Offset(x, 70 - 40 * q),
        7 + 3 * math.sin(q * math.pi),
        Paint()..color = color.blush.withValues(alpha: 1 - q),
      );
    }
  }

  @override
  bool shouldRepaint(PetPainter old) =>
      old.t != t ||
      old.react != react ||
      old.happy != happy ||
      old.mood != mood ||
      old.profile != profile;
}
