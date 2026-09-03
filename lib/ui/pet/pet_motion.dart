import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/pet.dart';

/// The whole-body transform for a mood at idle phase [t], plus the
/// one-shot bounce [react]. Kept separate so the numbers are in one place.
class PetMotion {
  final double dy;
  final double rotate;
  final double sx;
  final double sy;
  final Offset look;

  const PetMotion(this.dy, this.rotate, this.sx, this.sy, this.look);

  static PetMotion of(PetMood mood, double t, double react) {
    final w = t * 2 * math.pi;
    double dy = 0, rot = 0, sx = 1, sy = 1;
    var look = Offset.zero;
    switch (mood) {
      case PetMood.content:
        sy = sx = 1 + 0.015 * math.sin(w * 2);
        rot = 0.02 * math.sin(w);
        look = Offset(3 * math.sin(w), 1.5 * math.sin(w * 2));
      case PetMood.thirsty:
        sy = 0.97 + 0.01 * math.sin(w * 2);
        sx = 1.02;
        dy = 2;
        rot = 0.03 * math.sin(w * 1.5);
        look = Offset(0, 2);
      case PetMood.tiredEyes:
        sy = sx = 1 + 0.015 * math.sin(w);
        rot = 0.05 * math.sin(w * 1.5);
        dy = 1 + 2 * math.sin(w * 1.5);
      case PetMood.fidgety:
        rot = 0.09 * math.sin(w * 8);
        dy = -6 * math.sin(w * 6).abs();
        sy = sx = 1 + 0.02 * math.sin(w * 4);
        look = Offset(4 * math.sin(w * 4), 0);
      case PetMood.stretchy:
        sy = 1.03 + 0.05 * math.sin(w * 2);
        sx = 1 - 0.02 * math.sin(w * 2);
        dy = -3 * math.sin(w * 2);
      case PetMood.mighty:
        dy = -12 * math.sin(w * 3).abs();
        sx = 1 + 0.03 * math.sin(w * 3).abs();
        look = Offset(2 * math.sin(w * 3), -1);
      case PetMood.resting:
        sy = sx = 1 + 0.03 * math.sin(w);
        dy = 2;
    }
    if (react < 1) {
      final s = math.sin(react * math.pi);
      dy -= 22 * s;
      sy *= 1 + 0.1 * s;
      sx *= 1 - 0.06 * s;
    }
    return PetMotion(dy, rot, sx, sy, look);
  }
}
