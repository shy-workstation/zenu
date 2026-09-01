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

enum CosmeticSlot { head, face, neck, charm }

class Cosmetic {
  final String id;
  final CosmeticSlot slot;
  final int cost;

  const Cosmetic({required this.id, required this.slot, required this.cost});
}

class Cosmetics {
  static const cozyScarf =
      Cosmetic(id: 'cozyScarf', slot: CosmeticSlot.neck, cost: 40);
  static const roundGlasses =
      Cosmetic(id: 'roundGlasses', slot: CosmeticSlot.face, cost: 60);
  static const leafCrown =
      Cosmetic(id: 'leafCrown', slot: CosmeticSlot.head, cost: 90);
  static const nightCap =
      Cosmetic(id: 'nightCap', slot: CosmeticSlot.head, cost: 120);
  static const tinyMug =
      Cosmetic(id: 'tinyMug', slot: CosmeticSlot.charm, cost: 90);
  static const starCharm =
      Cosmetic(id: 'starCharm', slot: CosmeticSlot.charm, cost: 150);

  static const List<Cosmetic> catalog = [
    cozyScarf,
    roundGlasses,
    leafCrown,
    nightCap,
    tinyMug,
    starCharm,
  ];

  static Cosmetic? byId(String id) {
    for (final c in catalog) {
      if (c.id == id) return c;
    }
    return null;
  }
}
