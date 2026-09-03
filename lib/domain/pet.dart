import 'dart:ui' show Color;

import 'care_activity.dart';
import 'schedule_math.dart';

enum PetSpecies { miro, pip, luma }

/// What the pet is feeling. Needs map 1:1 to activities; the pet asks,
/// it never suffers — there is no sick/sad/dead state by design.
enum PetMood { content, thirsty, tiredEyes, fidgety, stretchy, mighty, resting }

class PetMoods {
  static const Map<String, PetMood> byActivityKind = {
    'water': PetMood.thirsty,
    'eyeRest': PetMood.tiredEyes,
    'move': PetMood.fidgety,
    'stretch': PetMood.stretchy,
    'strength': PetMood.mighty,
  };

  /// Derive the pet's mood from persisted timestamps. When several needs
  /// are overdue, the one furthest past due (relative to its own interval)
  /// wins. A paused session means the pet is resting.
  static PetMood derive({
    required bool running,
    required List<CareActivity> activities,
    required Map<String, int> anchorMs,
    required Map<String, int?> snoozeUntilMs,
    required int nowMs,
  }) {
    if (!running) return PetMood.resting;
    PetMood mood = PetMood.content;
    double worst = 0.0;
    for (final a in activities) {
      if (!a.enabled) continue;
      final anchor = anchorMs[a.id];
      if (anchor == null) continue;
      final ratio =
          ScheduleMath.overdueRatio(a, anchor, snoozeUntilMs[a.id], nowMs);
      if (ratio > worst) {
        final m = byActivityKind[a.kind];
        if (m != null) {
          worst = ratio;
          mood = m;
        }
      }
    }
    return mood;
  }
}

/// A body colour the pet can wear. Every colour is available to every
/// species from day one — styling is free, there is nothing to unlock.
class PetColor {
  final String id;
  final Color top;
  final Color mid;
  final Color bottom;
  final Color blush;

  /// Colour for species markings (sprout, tufts, star) on this body.
  final Color accent;

  const PetColor({
    required this.id,
    required this.top,
    required this.mid,
    required this.bottom,
    required this.blush,
    required this.accent,
  });
}

class PetColors {
  static const mint = PetColor(
    id: 'mint',
    top: Color(0xFFD9F6EC),
    mid: Color(0xFF9FE3CC),
    bottom: Color(0xFF6ECDB0),
    blush: Color(0xFFFF9FB2),
    accent: Color(0xFF2AAE85),
  );
  static const sky = PetColor(
    id: 'sky',
    top: Color(0xFFDCEBFF),
    mid: Color(0xFFA7C8F7),
    bottom: Color(0xFF7BA8EC),
    blush: Color(0xFFFFB3A0),
    accent: Color(0xFF5D8FDD),
  );
  static const lilac = PetColor(
    id: 'lilac',
    top: Color(0xFFF0E7FF),
    mid: Color(0xFFCDB4F4),
    bottom: Color(0xFFA583E4),
    blush: Color(0xFFE0A7F0),
    accent: Color(0xFF8B5CF6),
  );
  static const peach = PetColor(
    id: 'peach',
    top: Color(0xFFFFEEDF),
    mid: Color(0xFFFFC9A3),
    bottom: Color(0xFFF7A472),
    blush: Color(0xFFFF8FA3),
    accent: Color(0xFFEA7A3B),
  );
  static const rose = PetColor(
    id: 'rose',
    top: Color(0xFFFFE6EF),
    mid: Color(0xFFFFB5CC),
    bottom: Color(0xFFF489AB),
    blush: Color(0xFFFF6F91),
    accent: Color(0xFFE05A87),
  );
  static const lemon = PetColor(
    id: 'lemon',
    top: Color(0xFFFFF8D6),
    mid: Color(0xFFFFE787),
    bottom: Color(0xFFF7CF48),
    blush: Color(0xFFFF9FB2),
    accent: Color(0xFFE0B21F),
  );
  static const aqua = PetColor(
    id: 'aqua',
    top: Color(0xFFDDF9FB),
    mid: Color(0xFF9DE7EE),
    bottom: Color(0xFF5FCBD8),
    blush: Color(0xFFFFB3A0),
    accent: Color(0xFF12A6B8),
  );
  static const slate = PetColor(
    id: 'slate',
    top: Color(0xFFEEF1F6),
    mid: Color(0xFFC5CDDA),
    bottom: Color(0xFF98A5BA),
    blush: Color(0xFFFFA1B5),
    accent: Color(0xFF6B7A94),
  );

  static const List<PetColor> palette = [
    mint,
    sky,
    lilac,
    peach,
    rose,
    lemon,
    aqua,
    slate,
  ];

  static PetColor defaultFor(PetSpecies species) => switch (species) {
        PetSpecies.miro => mint,
        PetSpecies.pip => sky,
        PetSpecies.luma => lilac,
      };

  static PetColor? byId(String? id) {
    for (final c in palette) {
      if (c.id == id) return c;
    }
    return null;
  }
}

/// Optional body marking drawn over the base colour.
enum PetPattern { plain, spots, freckles, stripes, heart }

enum CosmeticSlot { head, face, neck, charm }

class Cosmetic {
  final String id;
  final CosmeticSlot slot;

  const Cosmetic({required this.id, required this.slot});
}

/// Everything the pet can wear. All free, all available from day one.
class Cosmetics {
  static const cozyScarf = Cosmetic(id: 'cozyScarf', slot: CosmeticSlot.neck);
  static const bowTie = Cosmetic(id: 'bowTie', slot: CosmeticSlot.neck);
  static const bandana = Cosmetic(id: 'bandana', slot: CosmeticSlot.neck);
  static const bellCollar =
      Cosmetic(id: 'bellCollar', slot: CosmeticSlot.neck);

  static const roundGlasses =
      Cosmetic(id: 'roundGlasses', slot: CosmeticSlot.face);
  static const sunglasses =
      Cosmetic(id: 'sunglasses', slot: CosmeticSlot.face);
  static const monocle = Cosmetic(id: 'monocle', slot: CosmeticSlot.face);
  static const eyePatch = Cosmetic(id: 'eyePatch', slot: CosmeticSlot.face);

  static const leafCrown = Cosmetic(id: 'leafCrown', slot: CosmeticSlot.head);
  static const nightCap = Cosmetic(id: 'nightCap', slot: CosmeticSlot.head);
  static const beanie = Cosmetic(id: 'beanie', slot: CosmeticSlot.head);
  static const topHat = Cosmetic(id: 'topHat', slot: CosmeticSlot.head);
  static const hairBow = Cosmetic(id: 'hairBow', slot: CosmeticSlot.head);
  static const halo = Cosmetic(id: 'halo', slot: CosmeticSlot.head);
  static const flowerClip =
      Cosmetic(id: 'flowerClip', slot: CosmeticSlot.head);

  static const tinyMug = Cosmetic(id: 'tinyMug', slot: CosmeticSlot.charm);
  static const starCharm = Cosmetic(id: 'starCharm', slot: CosmeticSlot.charm);
  static const heartCharm =
      Cosmetic(id: 'heartCharm', slot: CosmeticSlot.charm);
  static const balloon = Cosmetic(id: 'balloon', slot: CosmeticSlot.charm);
  static const butterfly =
      Cosmetic(id: 'butterfly', slot: CosmeticSlot.charm);

  static const List<Cosmetic> catalog = [
    leafCrown,
    nightCap,
    beanie,
    topHat,
    hairBow,
    halo,
    flowerClip,
    roundGlasses,
    sunglasses,
    monocle,
    eyePatch,
    cozyScarf,
    bowTie,
    bandana,
    bellCollar,
    tinyMug,
    starCharm,
    heartCharm,
    balloon,
    butterfly,
  ];

  static List<Cosmetic> forSlot(CosmeticSlot slot) =>
      catalog.where((c) => c.slot == slot).toList();

  static Cosmetic? byId(String id) {
    for (final c in catalog) {
      if (c.id == id) return c;
    }
    return null;
  }
}
