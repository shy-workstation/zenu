import 'package:flutter_test/flutter_test.dart';
import 'package:zenu/domain/care_activity.dart';
import 'package:zenu/domain/pet.dart';
import 'package:zenu/domain/schedule_math.dart';

void main() {
  const water = Activities.water; // 30 min interval
  const minute = 60 * 1000;

  group('ScheduleMath', () {
    test('dueAt is anchor + interval', () {
      expect(ScheduleMath.dueAtMs(water, 0, null), 30 * minute);
    });

    test('a later snooze pushes the due time out', () {
      expect(ScheduleMath.dueAtMs(water, 0, 45 * minute), 45 * minute);
      expect(ScheduleMath.dueAtMs(water, 0, 10 * minute), 30 * minute);
    });

    test('needFraction goes 0 -> 1 across the interval and clamps', () {
      expect(ScheduleMath.needFraction(water, 0, null, 0), 0.0);
      expect(ScheduleMath.needFraction(water, 0, null, 15 * minute),
          closeTo(0.5, 0.001));
      expect(ScheduleMath.needFraction(water, 0, null, 30 * minute), 1.0);
      expect(ScheduleMath.needFraction(water, 0, null, 90 * minute), 1.0);
    });

    test('overdue detection is wall-clock, no timer involved', () {
      expect(ScheduleMath.isOverdue(water, 0, null, 29 * minute), isFalse);
      expect(ScheduleMath.isOverdue(water, 0, null, 30 * minute), isTrue);
    });

    test('notification plan: due + re-nags, all in the future', () {
      final times = ScheduleMath.notificationTimesMs(water, 0, null, 0);
      expect(times, [30 * minute, 40 * minute, 50 * minute]);
    });

    test('overdue activity rolls nags forward instead of bursting the past',
        () {
      // Now = 65 min: due (30) and both nags (40, 50) are in the past.
      final times =
          ScheduleMath.notificationTimesMs(water, 0, null, 65 * minute);
      expect(times.every((t) => t > 65 * minute), isTrue);
      expect(times.length, 3);
      expect(times.toSet().length, times.length);
    });
  });

  group('PetMoods.derive', () {
    final activities = List.of(Activities.defaults);

    test('resting when paused', () {
      expect(
        PetMoods.derive(
          running: false,
          activities: activities,
          anchorMs: {},
          snoozeUntilMs: {},
          nowMs: 0,
        ),
        PetMood.resting,
      );
    });

    test('content when nothing is overdue', () {
      expect(
        PetMoods.derive(
          running: true,
          activities: activities,
          anchorMs: {for (final a in activities) a.id: 0},
          snoozeUntilMs: {},
          nowMs: 5 * minute,
        ),
        PetMood.content,
      );
    });

    test('the furthest-overdue need (relative to its interval) wins', () {
      // Water (30m) overdue by 30m = ratio 1.0; eyeRest (20m) overdue by
      // 40m = ratio 2.0 -> tired eyes wins.
      expect(
        PetMoods.derive(
          running: true,
          activities: activities,
          anchorMs: {'water': 0, 'eyeRest': 0},
          snoozeUntilMs: {},
          nowMs: 60 * minute,
        ),
        PetMood.tiredEyes,
      );
    });

    test('disabled activities never drive the mood', () {
      final disabled = [
        for (final a in activities)
          a.id == 'eyeRest' ? a.copyWith(enabled: false) : a,
      ];
      expect(
        PetMoods.derive(
          running: true,
          activities: disabled,
          anchorMs: {'eyeRest': 0},
          snoozeUntilMs: {},
          nowMs: 60 * minute,
        ),
        PetMood.content,
      );
    });
  });
}
