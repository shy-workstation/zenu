import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../domain/care_activity.dart';
import '../domain/completion_event.dart';
import '../domain/game_state.dart';
import '../domain/zenu_state.dart';

/// One-way migration from the v1 `reminders` SharedPreferences blob.
/// The legacy blob is read, never modified — if anything goes wrong the
/// user still has their old data and v2 starts from defaults.
class LegacyMigration {
  /// v1 ReminderType -> v2 activity id.
  static const Map<String, String> typeToActivity = {
    'water': 'water',
    'eyeRest': 'eyeRest',
    'standUp': 'move',
    'stretch': 'stretch',
    'deepBreathing': 'stretch',
    'meditation': 'stretch',
    'pushUps': 'strength',
    'pullUps': 'strength',
    'squats': 'strength',
    'jumpingJacks': 'strength',
    'burpees': 'strength',
    'planks': 'strength',
  };

  static ZenuState? migrate(String legacyRaw) {
    try {
      final decoded = jsonDecode(legacyRaw);
      if (decoded is! List) return null;

      final state = ZenuState();
      // Everything disabled unless the old setup had it enabled; intervals
      // follow the most frequent enabled legacy reminder per activity.
      final enabled = <String, bool>{};
      final intervalSec = <String, int>{};
      var totalCompleted = 0;

      for (final raw in decoded) {
        if (raw is! Map) continue;
        final item = Map<String, dynamic>.from(raw);

        String? typeName;
        final type = item['type'];
        if (type is String) typeName = type;
        if (type is int) {
          const order = [
            'water', 'eyeRest', 'standUp', 'pushUps', 'pullUps', 'squats',
            'jumpingJacks', 'burpees', 'stretch', 'planks', 'deepBreathing',
            'meditation',
          ];
          if (type >= 0 && type < order.length) typeName = order[type];
        }
        final activityId = typeToActivity[typeName] ?? 'stretch';

        final wasEnabled = item['isEnabled'] as bool? ?? true;
        enabled[activityId] = (enabled[activityId] ?? false) || wasEnabled;

        final sec = (item['interval'] as num?)?.toInt();
        if (sec != null && wasEnabled) {
          final clamped = sec.clamp(300, 8 * 3600);
          final current = intervalSec[activityId];
          if (current == null || clamped < current) {
            intervalSec[activityId] = clamped;
          }
        }

        totalCompleted += (item['totalCompleted'] as num?)?.toInt() ?? 0;

        final log = item['completionLog'];
        if (log is List) {
          for (final entry in log) {
            if (entry is! Map) continue;
            final date = entry['date'];
            if (date is! String || date.length < 10) continue;
            final parsed = DateTime.tryParse('${date.substring(0, 10)}T12:00:00Z');
            if (parsed == null) continue;
            state.events.add(CompletionEvent(
              activityId: activityId,
              atMs: parsed.millisecondsSinceEpoch,
              qty: (entry['qty'] as num?)?.toInt() ?? 1,
            ));
          }
        }
      }

      // An activity the v1 user never configured stays off — migration
      // must not add reminder streams they didn't ask for.
      state.activities = [
        for (final builtin in Activities.defaults)
          builtin.copyWith(
            enabled: enabled[builtin.id] ?? false,
            interval: intervalSec[builtin.id] != null
                ? Duration(seconds: intervalSec[builtin.id]!)
                : builtin.interval,
          ),
      ];
      state.events.sort((a, b) => a.atMs.compareTo(b.atMs));

      // Past care counts: seed the sparks wallet from v1 history.
      state.game = GameState(
        sparks: (totalCompleted * sparksPerCare).clamp(0, 300),
      );
      return state;
    } catch (e) {
      debugPrint('LegacyMigration: failed, starting fresh: $e');
      return null;
    }
  }
}
