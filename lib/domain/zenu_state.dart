import 'care_activity.dart';
import 'completion_event.dart';
import 'game_state.dart';

/// The whole persisted app state, versioned. Running state, anchors, and
/// snoozes are all part of it — a restart or reboot changes nothing about
/// what the pet knows.
class ZenuState {
  static const int schemaVersion = 2;

  List<CareActivity> activities;
  bool running;
  int? sessionStartMs;

  /// Per-activity anchor: last completion, or session start when the
  /// activity has never been completed this session.
  Map<String, int> lastDoneMs;
  Map<String, int> snoozeUntilMs;

  /// Append-only care history. Never pruned.
  List<CompletionEvent> events;

  GameState game;

  bool closeToTray;
  bool alwaysOnTop;
  bool launchAtStartup;

  ZenuState({
    List<CareActivity>? activities,
    this.running = false,
    this.sessionStartMs,
    Map<String, int>? lastDoneMs,
    Map<String, int>? snoozeUntilMs,
    List<CompletionEvent>? events,
    this.game = const GameState(),
    this.closeToTray = true,
    this.alwaysOnTop = false,
    this.launchAtStartup = false,
  })  : activities = activities ?? List.of(Activities.defaults),
        lastDoneMs = lastDoneMs ?? {},
        snoozeUntilMs = snoozeUntilMs ?? {},
        events = events ?? [];

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'activities': activities.map((a) => a.toJson()).toList(),
        'running': running,
        'sessionStartMs': sessionStartMs,
        'lastDoneMs': lastDoneMs,
        'snoozeUntilMs': snoozeUntilMs,
        'events': events.map((e) => e.toJson()).toList(),
        'game': game.toJson(),
        'closeToTray': closeToTray,
        'alwaysOnTop': alwaysOnTop,
        'launchAtStartup': launchAtStartup,
      };

  factory ZenuState.fromJson(Map<String, dynamic> json) {
    final activities = <CareActivity>[];
    for (final raw in (json['activities'] as List? ?? const [])) {
      if (raw is Map) {
        activities.add(CareActivity.fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    // Guarantee the five built-ins exist even if a future version removed one.
    for (final builtin in Activities.defaults) {
      if (!activities.any((a) => a.id == builtin.id)) {
        activities.add(builtin);
      }
    }

    final events = <CompletionEvent>[];
    for (final raw in (json['events'] as List? ?? const [])) {
      if (raw is Map) {
        try {
          events.add(CompletionEvent.fromJson(Map<String, dynamic>.from(raw)));
        } catch (_) {
          // A malformed event is dropped; it must never take the rest of the
          // history down with it.
        }
      }
    }

    Map<String, int> intMap(dynamic raw) {
      final out = <String, int>{};
      if (raw is Map) {
        raw.forEach((key, value) {
          if (key is String && value is num) out[key] = value.toInt();
        });
      }
      return out;
    }

    return ZenuState(
      activities: activities,
      running: json['running'] as bool? ?? false,
      sessionStartMs: (json['sessionStartMs'] as num?)?.toInt(),
      lastDoneMs: intMap(json['lastDoneMs']),
      snoozeUntilMs: intMap(json['snoozeUntilMs']),
      events: events,
      game: json['game'] is Map
          ? GameState.fromJson(Map<String, dynamic>.from(json['game'] as Map))
          : const GameState(),
      closeToTray: json['closeToTray'] as bool? ?? true,
      alwaysOnTop: json['alwaysOnTop'] as bool? ?? false,
      launchAtStartup: json['launchAtStartup'] as bool? ?? false,
    );
  }
}
