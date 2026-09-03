import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/pet.dart';

/// Draws the worn accessories in the pet's 200x182 design space. [t] is
/// the idle phase so charms can bob and flap with the body.
void paintCosmetics(Canvas canvas, Map<CosmeticSlot, String> worn, double t) {
  _paintNeck(canvas, worn[CosmeticSlot.neck]);
  _paintFace(canvas, worn[CosmeticSlot.face]);
  _paintHead(canvas, worn[CosmeticSlot.head]);
  _paintCharm(canvas, worn[CosmeticSlot.charm], t);
}

const _ink = Color(0xFF2B3B4E);

void _paintNeck(Canvas canvas, String? id) {
  switch (id) {
    case 'cozyScarf':
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
    case 'bowTie':
      final bow = Paint()..color = const Color(0xFFEF4444);
      canvas.drawPath(
        Path()
          ..moveTo(100, 146)
          ..lineTo(82, 136)
          ..lineTo(82, 156)
          ..close(),
        bow,
      );
      canvas.drawPath(
        Path()
          ..moveTo(100, 146)
          ..lineTo(118, 136)
          ..lineTo(118, 156)
          ..close(),
        bow,
      );
      canvas.drawCircle(
          const Offset(100, 146), 4.5, Paint()..color = const Color(0xFFB91C1C));
    case 'bandana':
      canvas.drawPath(
        Path()
          ..moveTo(40, 136)
          ..cubicTo(60, 150, 140, 150, 160, 136)
          ..lineTo(156, 146)
          ..cubicTo(140, 158, 60, 158, 44, 146)
          ..close(),
        Paint()..color = const Color(0xFF3B82F6),
      );
      canvas.drawPath(
        Path()
          ..moveTo(92, 152)
          ..lineTo(100, 172)
          ..lineTo(112, 152)
          ..close(),
        Paint()..color = const Color(0xFF2563EB),
      );
    case 'bellCollar':
      canvas.drawPath(
        Path()
          ..moveTo(42, 140)
          ..cubicTo(64, 152, 136, 152, 158, 140),
        Paint()
          ..color = const Color(0xFF16A34A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7,
      );
      canvas.drawCircle(
          const Offset(100, 152), 7, Paint()..color = const Color(0xFFFACC15));
      canvas.drawCircle(
          const Offset(100, 155), 2, Paint()..color = const Color(0xFFA16207));
  }
}

void _paintFace(Canvas canvas, String? id) {
  switch (id) {
    case 'roundGlasses':
      final frame = Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawCircle(const Offset(66, 91), 16, frame);
      canvas.drawCircle(const Offset(134, 91), 16, frame);
      canvas.drawLine(const Offset(82, 89), const Offset(118, 89), frame);
    case 'sunglasses':
      final lens = Paint()..color = const Color(0xFF1F2937);
      for (final cx in [66.0, 134.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(cx, 90), width: 36, height: 24),
              const Radius.circular(9)),
          lens,
        );
        canvas.drawCircle(Offset(cx - 8, 84), 3,
            Paint()..color = Colors.white.withValues(alpha: 0.35));
      }
      canvas.drawLine(
        const Offset(84, 88),
        const Offset(116, 88),
        Paint()
          ..color = const Color(0xFF1F2937)
          ..strokeWidth = 3,
      );
    case 'monocle':
      final frame = Paint()
        ..color = const Color(0xFFCA8A04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(const Offset(134, 91), 17, frame);
      canvas.drawLine(const Offset(146, 103), const Offset(160, 136),
          frame..strokeWidth = 2);
    case 'eyePatch':
      canvas.drawOval(
        Rect.fromCenter(
            center: const Offset(134, 91), width: 30, height: 26),
        Paint()..color = _ink,
      );
      canvas.drawLine(
        const Offset(120, 82),
        const Offset(60, 66),
        Paint()
          ..color = _ink
          ..strokeWidth = 3,
      );
  }
}

void _paintHead(Canvas canvas, String? id) {
  switch (id) {
    case 'leafCrown':
      canvas.drawPath(
        Path()
          ..moveTo(62, 34)
          ..quadraticBezierTo(100, 22, 138, 34),
        Paint()
          ..color = const Color(0xFF8B5CF6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
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
    case 'beanie':
      canvas.drawPath(
        Path()
          ..moveTo(56, 44)
          ..quadraticBezierTo(100, 0, 144, 44)
          ..close(),
        Paint()..color = const Color(0xFFF97316),
      );
      canvas.drawPath(
        Path()
          ..moveTo(54, 44)
          ..quadraticBezierTo(100, 30, 146, 44),
        Paint()
          ..color = const Color(0xFFEA580C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8,
      );
      canvas.drawCircle(
          const Offset(100, 12), 7, Paint()..color = const Color(0xFFFED7AA));
    case 'topHat':
      final hat = Paint()..color = _ink;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(70, 0, 60, 36), const Radius.circular(4)),
        hat,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(56, 30, 88, 8), const Radius.circular(4)),
        hat,
      );
      canvas.drawRect(const Rect.fromLTWH(70, 24, 60, 6),
          Paint()..color = const Color(0xFFEF4444));
    case 'hairBow':
      final bow = Paint()..color = const Color(0xFFEC4899);
      canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(126, 24), width: 22, height: 14),
          bow);
      canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(150, 24), width: 22, height: 14),
          bow);
      canvas.drawCircle(
          const Offset(138, 24), 5, Paint()..color = const Color(0xFFBE185D));
    case 'halo':
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(100, 8), width: 60, height: 14),
        Paint()
          ..color = const Color(0xFFFACC15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
    case 'flowerClip':
      final petal = Paint()..color = const Color(0xFFF472B6);
      for (var i = 0; i < 5; i++) {
        final a = i * 2 * math.pi / 5;
        canvas.drawCircle(
            Offset(66 + 8 * math.cos(a), 30 + 8 * math.sin(a)), 5.5, petal);
      }
      canvas.drawCircle(
          const Offset(66, 30), 4.5, Paint()..color = const Color(0xFFFDE047));
  }
}

void _paintCharm(Canvas canvas, String? id, double t) {
  final bob = 3 * math.sin(t * 2 * math.pi * 2);
  switch (id) {
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
      // Steam.
      final steam = Paint()
        ..color = _ink.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (final x in [166.0, 174.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(x, 114 + bob)
            ..quadraticBezierTo(x + 3, 108 + bob, x, 102 + bob),
          steam,
        );
      }
    case 'starCharm':
      drawStar(canvas, Offset(172, 130 + bob), 11,
          Paint()..color = const Color(0xFF8B5CF6));
    case 'heartCharm':
      drawHeart(canvas, Offset(172, 132 + bob), 10,
          Paint()..color = const Color(0xFFEF4444));
    case 'balloon':
      final dy = 4 * math.sin(t * 2 * math.pi);
      final dx = 3 * math.sin(t * 2 * math.pi * 0.5);
      canvas.drawPath(
        Path()
          ..moveTo(166, 126)
          ..quadraticBezierTo(176 + dx, 90, 180 + dx, 62 + dy),
        Paint()
          ..color = _ink.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(180 + dx, 42 + dy), width: 30, height: 38),
        Paint()..color = const Color(0xFFEF4444),
      );
      canvas.drawCircle(Offset(173 + dx, 32 + dy), 4,
          Paint()..color = Colors.white.withValues(alpha: 0.45));
    case 'butterfly':
      final flap = 0.6 + 0.4 * math.sin(t * 2 * math.pi * 10).abs();
      final cx = 30 + 4 * math.sin(t * 2 * math.pi);
      final cy = 60 + 5 * math.sin(t * 2 * math.pi * 1.5);
      final wing = Paint()..color = const Color(0xFFA855F7);
      for (final side in [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + side * 7 * flap, cy - 3),
              width: 13 * flap,
              height: 11),
          wing,
        );
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx + side * 5 * flap, cy + 6),
              width: 9 * flap,
              height: 8),
          wing,
        );
      }
      canvas.drawLine(
        Offset(cx, cy - 8),
        Offset(cx, cy + 10),
        Paint()
          ..color = _ink
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
  }
}

void drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
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

void drawHeart(Canvas canvas, Offset c, double r, Paint paint) {
  canvas.drawPath(
    Path()
      ..moveTo(c.dx, c.dy + r)
      ..cubicTo(c.dx - 1.6 * r, c.dy - 0.2 * r, c.dx - 0.6 * r, c.dy - 1.3 * r,
          c.dx, c.dy - 0.5 * r)
      ..cubicTo(c.dx + 0.6 * r, c.dy - 1.3 * r, c.dx + 1.6 * r, c.dy - 0.2 * r,
          c.dx, c.dy + r)
      ..close(),
    paint,
  );
}
