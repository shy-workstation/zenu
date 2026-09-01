import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/pet.dart';

/// The companion, drawn in code: a soft blob with species-specific colors
/// and markings, a mood-driven face, and worn cosmetics. Wrapped in its
/// own RepaintBoundary so breathing/blinking never repaints the screen
/// around it.
class PetView extends StatefulWidget {
  final PetSpecies species;
  final PetMood mood;
  final Map<CosmeticSlot, String> worn;
  final double size;
  final bool animated;

  const PetView({
    super.key,
    required this.species,
    required this.mood,
    this.worn = const {},
    this.size = 240,
    this.animated = true,
  });

  @override
  State<PetView> createState() => _PetViewState();
}

class _PetViewState extends State<PetView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6));
    if (widget.animated) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size * 0.92,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _PetPainter(
              species: widget.species,
              mood: widget.mood,
              worn: widget.worn,
              t: _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _PetPainter extends CustomPainter {
  final PetSpecies species;
  final PetMood mood;
  final Map<CosmeticSlot, String> worn;

  /// 0..1 animation phase (6s loop) driving breath and blink.
  final double t;

  _PetPainter({
    required this.species,
    required this.mood,
    required this.worn,
    required this.t,
  });

  static const _ink = Color(0xFF2B3B4E);

  (Color, Color, Color) get _bodyColors => switch (species) {
        PetSpecies.miro => (
            const Color(0xFFD9F6EC),
            const Color(0xFF9FE3CC),
            const Color(0xFF6ECDB0),
          ),
        PetSpecies.pip => (
            const Color(0xFFDCEBFF),
            const Color(0xFFA7C8F7),
            const Color(0xFF7BA8EC),
          ),
        PetSpecies.luma => (
            const Color(0xFFF0E7FF),
            const Color(0xFFCDB4F4),
            const Color(0xFFA583E4),
          ),
      };

  Color get _blush => switch (species) {
        PetSpecies.miro => const Color(0xFFFF9FB2),
        PetSpecies.pip => const Color(0xFFFFB3A0),
        PetSpecies.luma => const Color(0xFFE0A7F0),
      };

  @override
  void paint(Canvas canvas, Size size) {
    // Design space is 200x182, like the mockups.
    final scale = size.width / 200;
    canvas.scale(scale, scale);

    final breath = 1 + 0.015 * math.sin(t * 2 * math.pi * 2);
    // Blink briefly twice per loop.
    final blinkPhase = (t * 2) % 1;
    final blinking = blinkPhase > 0.94 && blinkPhase < 0.99;

    // Ground shadow (outside the breathing transform).
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(100, 172), width: 124, height: 18),
      Paint()..color = _ink.withValues(alpha: 0.08),
    );

    canvas.save();
    // Breathe around the blob's base so the feet stay grounded.
    canvas.translate(100, 170);
    canvas.scale(breath, breath);
    if (mood == PetMood.fidgety) canvas.rotate(-0.10);
    canvas.translate(-100, -170);

    _paintBody(canvas);
    _paintSpeciesMarking(canvas);
    _paintFace(canvas, blinking);
    _paintCosmetics(canvas);
    canvas.restore();

    _paintMoodExtras(canvas);
  }

  void _paintBody(Canvas canvas) {
    final (top, mid, bottom) = _bodyColors;
    final body = Path()
      ..moveTo(100, 18)
      ..cubicTo(146, 18, 176, 52, 176, 98)
      ..cubicTo(176, 142, 142, 170, 100, 170)
      ..cubicTo(58, 170, 24, 142, 24, 98)
      ..cubicTo(24, 52, 54, 18, 100, 18)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 0.95,
          colors: [top, mid, bottom],
          stops: const [0, 0.6, 1],
        ).createShader(const Rect.fromLTWH(24, 18, 152, 152)),
    );

    if (mood == PetMood.stretchy) {
      final arms = Paint()
        ..color = mid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(
        Path()
          ..moveTo(34, 96)
          ..cubicTo(24, 84, 26, 68, 40, 60),
        arms,
      );
      canvas.drawPath(
        Path()
          ..moveTo(166, 96)
          ..cubicTo(176, 84, 174, 68, 160, 60),
        arms,
      );
    }
  }

  void _paintSpeciesMarking(Canvas canvas) {
    switch (species) {
      case PetSpecies.miro:
        // Two sprout leaves.
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
        // Two little ear tufts.
        final tuft = Paint()..color = const Color(0xFF5D8FDD);
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
        // A little star on the head.
        _drawStar(canvas, const Offset(104, 16), 14,
            Paint()..color = const Color(0xFF8B5CF6).withValues(alpha: 0.85));
    }
  }

  void _paintFace(Canvas canvas, bool blinking) {
    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = _ink;

    final closedEyes = blinking ||
        mood == PetMood.tiredEyes ||
        mood == PetMood.resting ||
        mood == PetMood.stretchy;

    // Eyebrows.
    if (mood == PetMood.thirsty) {
      canvas.drawPath(
        Path()
          ..moveTo(54, 74)
          ..quadraticBezierTo(64, 69, 74, 76),
        stroke..strokeWidth = 3.5,
      );
      canvas.drawPath(
        Path()
          ..moveTo(126, 76)
          ..quadraticBezierTo(136, 69, 146, 74),
        stroke,
      );
    } else if (mood == PetMood.mighty) {
      canvas.drawLine(const Offset(54, 78), const Offset(74, 72),
          stroke..strokeWidth = 3.5);
      canvas.drawLine(const Offset(126, 72), const Offset(146, 78), stroke);
    }
    stroke.strokeWidth = 4;

    // Eyes.
    if (closedEyes) {
      final down = mood == PetMood.tiredEyes;
      for (final cx in [66.0, 134.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(cx - 10, 90)
            ..quadraticBezierTo(cx, down ? 97 : 84, cx + 10, 90),
          stroke..strokeWidth = 4.5,
        );
      }
      stroke.strokeWidth = 4;
    } else {
      for (final cx in [66.0, 134.0]) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 91), width: 16, height: 21),
          fill,
        );
        canvas.drawCircle(
            Offset(cx + 3, 87), 3, Paint()..color = Colors.white);
      }
    }

    // Blush.
    final blush = Paint()..color = _blush.withValues(alpha: 0.45);
    canvas.drawCircle(const Offset(50, 110), 9, blush);
    canvas.drawCircle(const Offset(150, 110), 9, blush);

    // Mouth.
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
        canvas.drawLine(const Offset(96, 118), const Offset(104, 118), stroke);
      case PetMood.fidgety:
        canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(100, 120), width: 14, height: 16),
          Paint()..color = const Color(0xFF5C3A44),
        );
      default:
        canvas.drawPath(
          Path()
            ..moveTo(87, 116)
            ..quadraticBezierTo(100, 127, 113, 116),
          stroke..strokeWidth = 4.5,
        );
    }
  }

  void _paintCosmetics(Canvas canvas) {
    if (worn[CosmeticSlot.neck] == Cosmetics.cozyScarf.id) {
      canvas.drawPath(
        Path()
          ..moveTo(38, 138)
          ..cubicTo(60, 152, 140, 152, 162, 138)
          ..lineTo(158, 156)
          ..cubicTo(130, 166, 70, 166, 42, 156)
          ..close(),
        Paint()..color = const Color(0xFFF97360),
      );
      canvas.drawPath(
        Path()
          ..moveTo(148, 146)
          ..lineTo(164, 168)
          ..lineTo(150, 170)
          ..lineTo(142, 152)
          ..close(),
        Paint()..color = const Color(0xFFE85B4C),
      );
    }
    if (worn[CosmeticSlot.face] == Cosmetics.roundGlasses.id) {
      final frame = Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawCircle(const Offset(66, 91), 16, frame);
      canvas.drawCircle(const Offset(134, 91), 16, frame);
      canvas.drawLine(const Offset(82, 89), const Offset(118, 89), frame);
    }
    switch (worn[CosmeticSlot.head]) {
      case 'leafCrown':
        final band = Paint()
          ..color = const Color(0xFF8B5CF6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(
          Path()
            ..moveTo(62, 34)
            ..quadraticBezierTo(100, 22, 138, 34),
          band,
        );
        canvas.drawPath(
          Path()
            ..moveTo(100, 28)
            ..cubicTo(96, 16, 100, 8, 110, 4)
            ..cubicTo(110, 14, 106, 22, 100, 28)
            ..close(),
          Paint()..color = const Color(0xFF34C79A),
        );
      case 'nightCap':
        canvas.drawPath(
          Path()
            ..moveTo(60, 40)
            ..quadraticBezierTo(100, 14, 140, 40)
            ..quadraticBezierTo(150, 12, 168, 22)
            ..quadraticBezierTo(160, 26, 158, 40)
            ..quadraticBezierTo(120, 26, 60, 40)
            ..close(),
          Paint()..color = const Color(0xFF7BA8EC),
        );
        canvas.drawCircle(
            const Offset(170, 22), 7, Paint()..color = const Color(0xFFDCEBFF));
    }
    switch (worn[CosmeticSlot.charm]) {
      case 'tinyMug':
        final mug = Paint()
          ..color = const Color(0xFF06B6D4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(160, 120, 22, 26), const Radius.circular(4)),
          mug,
        );
        canvas.drawArc(const Rect.fromLTWH(180, 126, 12, 14), -math.pi / 2,
            math.pi, false, mug);
      case 'starCharm':
        _drawStar(canvas, const Offset(172, 130), 11,
            Paint()..color = const Color(0xFF8B5CF6));
    }
  }

  void _paintMoodExtras(Canvas canvas) {
    switch (mood) {
      case PetMood.thirsty:
        canvas.drawPath(
          Path()
            ..moveTo(160, 40)
            ..cubicTo(160, 40, 152, 50, 152, 55)
            ..cubicTo(152, 59.5, 155.5, 63, 160, 63)
            ..cubicTo(164.5, 63, 168, 59.5, 168, 55)
            ..cubicTo(168, 50, 160, 40, 160, 40)
            ..close(),
          Paint()..color = const Color(0xFF06B6D4),
        );
      case PetMood.tiredEyes:
        _drawStar(canvas, const Offset(42, 58), 12,
            Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.7));
        _drawStar(canvas, const Offset(162, 68), 9,
            Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.5));
      case PetMood.fidgety:
        final arc = Paint()
          ..color = const Color(0xFF10B981)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(const Rect.fromLTWH(168, 82, 14, 26), -math.pi / 3,
            2 * math.pi / 3, false, arc);
        canvas.drawArc(const Rect.fromLTWH(176, 74, 18, 42), -math.pi / 3,
            2 * math.pi / 3, false, arc..color = arc.color.withValues(alpha: 0.55));
        canvas.drawArc(const Rect.fromLTWH(18, 82, 14, 26), 2 * math.pi / 3,
            2 * math.pi / 3, false, arc..color = const Color(0xFF10B981));
      case PetMood.mighty:
        final bar = Paint()
          ..color = const Color(0xFFF97316)
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(148, 136), const Offset(178, 126), bar);
        canvas.drawCircle(const Offset(148, 136), 6.5, bar);
        canvas.drawCircle(const Offset(178, 126), 6.5, bar);
      case PetMood.resting:
        final style = TextStyle(
          color: _ink.withValues(alpha: 0.5),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        );
        for (final (offset, size) in [
          (const Offset(152, 44), 18.0),
          (const Offset(166, 28), 13.0),
        ]) {
          final painter = TextPainter(
            text: TextSpan(text: 'z', style: style.copyWith(fontSize: size)),
            textDirection: TextDirection.ltr,
          )..layout();
          painter.paint(canvas, offset);
        }
      default:
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final r = i.isEven ? radius : radius * 0.42;
      final angle = i * math.pi / 4 - math.pi / 2;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PetPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.mood != mood ||
      oldDelegate.species != species ||
      oldDelegate.worn != worn;
}
