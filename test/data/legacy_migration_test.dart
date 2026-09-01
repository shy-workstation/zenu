import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zenu/data/legacy_migration.dart';

void main() {
  group('LegacyMigration', () {
    test('maps v1 reminder types onto the five activities', () {
      final legacy = jsonEncode([
        {
          'id': 'a',
          'type': 'water',
          'interval': 1800,
          'isEnabled': true,
          'totalCompleted': 3,
          'completionLog': [
            {'date': '2026-08-30', 'qty': 250},
          ],
        },
        {
          'id': 'b',
          'type': 'pushUps',
          'interval': 3600,
          'isEnabled': true,
          'totalCompleted': 2,
          'completionLog': [],
        },
        {
          'id': 'c',
          'type': 'meditation',
          'interval': 900,
          'isEnabled': false,
          'totalCompleted': 0,
        },
      ]);

      final state = LegacyMigration.migrate(legacy)!;
      final water = state.activities.firstWhere((a) => a.id == 'water');
      final strength = state.activities.firstWhere((a) => a.id == 'strength');
      final stretch = state.activities.firstWhere((a) => a.id == 'stretch');

      expect(water.enabled, isTrue);
      expect(water.interval, const Duration(minutes: 30));
      expect(strength.enabled, isTrue);
      expect(strength.interval, const Duration(hours: 1));
      // Disabled legacy reminder keeps the activity's default interval and
      // does not force-enable it.
      expect(stretch.interval, const Duration(hours: 1));

      expect(state.events.length, 1);
      expect(state.events.single.activityId, 'water');
      expect(state.events.single.qty, 250);

      // Historic care seeds sparks: 5 completions x 5, capped at 300.
      expect(state.game.sparks, 25);
      // Migration never auto-starts a session on the user's behalf.
      expect(state.running, isFalse);
    });

    test('supports the old index-based type encoding', () {
      final legacy = jsonEncode([
        {'id': 'x', 'type': 1, 'interval': 1200, 'isEnabled': true},
      ]);
      final state = LegacyMigration.migrate(legacy)!;
      final eyeRest = state.activities.firstWhere((a) => a.id == 'eyeRest');
      expect(eyeRest.enabled, isTrue);
      expect(eyeRest.interval, const Duration(minutes: 20));
    });

    test('two legacy reminders on one activity: most frequent interval wins',
        () {
      final legacy = jsonEncode([
        {'id': 'p', 'type': 'pushUps', 'interval': 3600, 'isEnabled': true},
        {'id': 'q', 'type': 'squats', 'interval': 1800, 'isEnabled': true},
      ]);
      final state = LegacyMigration.migrate(legacy)!;
      final strength = state.activities.firstWhere((a) => a.id == 'strength');
      expect(strength.interval, const Duration(minutes: 30));
    });

    test('garbage input returns null instead of a broken state', () {
      expect(LegacyMigration.migrate('not json at all'), isNull);
      expect(LegacyMigration.migrate('{"an": "object"}'), isNull);
    });

    test('sparks are capped at 300', () {
      final legacy = jsonEncode([
        {'id': 'a', 'type': 'water', 'interval': 1800, 'totalCompleted': 999},
      ]);
      expect(LegacyMigration.migrate(legacy)!.game.sparks, 300);
    });
  });
}
