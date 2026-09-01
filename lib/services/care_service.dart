import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_store.dart';
import '../domain/care_activity.dart';
import '../domain/completion_event.dart';
import '../domain/game_state.dart';
import '../domain/pet.dart';
import '../domain/schedule_math.dart';
import '../domain/zenu_state.dart';
import 'clock.dart';
import 'notification_scheduler.dart';
import 'notification_texts.dart';

/// The single authority for due state, the pet's mood, and persistence.
/// Every mutation persists, then resyncs the OS notification queue —
/// UI, pet, and notifications can never disagree.
class CareService extends ChangeNotifier {
  final AppStore _store;
  final NotificationScheduler? _scheduler;
  final Clock clock;

  ZenuState state;
  NotificationTexts texts = NotificationTexts.fallback();

  final bool migratedFromV1;
  final bool recoveredFromBackup;

  /// null = not yet checked. false drives the "notifications are off"
  /// recovery banner — a denied permission must never be silent.
  bool? notificationsAllowed;

  CareService._(
    this._store,
    this._scheduler,
    this.clock,
    LoadResult loaded,
  )   : state = loaded.state,
        migratedFromV1 = loaded.migratedFromV1,
        recoveredFromBackup = loaded.recoveredFromBackup {
    NotificationScheduler.actionHandler = _onNotificationAction;
  }

  static Future<CareService> create({
    required AppStore store,
    NotificationScheduler? scheduler,
    Clock clock = const Clock(),
  }) async {
    final service = CareService._(store, scheduler, clock, store.load());
    await service._drainPendingActions();
    // A running session survives restarts and reboots: anchors are wall
    // clock, so nothing needs resetting — just re-arm the OS queue.
    await service._persistAndResync(notify: false);
    return service;
  }

  // ---------------------------------------------------------------- session

  bool get running => state.running;

  Future<void> startSession() async {
    final now = clock.nowMs();
    state.running = true;
    state.sessionStartMs = now;
    for (final activity in state.activities) {
      state.lastDoneMs[activity.id] = now;
    }
    state.snoozeUntilMs.clear();
    await _persistAndResync();
  }

  Future<void> pauseSession() async {
    state.running = false;
    await _persistAndResync();
  }

  // ------------------------------------------------------------------- care

  Future<void> logCare(String activityId, {int? qty, int? atMs}) async {
    final activity = _activity(activityId);
    if (activity == null) return;
    final at = atMs ?? clock.nowMs();
    // Sparks only once the need has meaningfully grown (a quarter of the
    // interval) — logging always works, but rapid-fire taps can't farm
    // the wardrobe economy.
    final anchor = state.lastDoneMs[activityId];
    final earnsSparks = anchor == null ||
        (at - anchor) >= activity.interval.inMilliseconds ~/ 4;
    state.events.add(CompletionEvent(
      activityId: activityId,
      atMs: at,
      qty: qty ?? activity.goalQty,
    ));
    state.lastDoneMs[activityId] = at;
    state.snoozeUntilMs.remove(activityId);
    if (earnsSparks) {
      state.game =
          state.game.copyWith(sparks: state.game.sparks + sparksPerCare);
    }
    await _persistAndResync();
  }

  Future<void> snooze(String activityId,
      {Duration duration = const Duration(minutes: 10)}) async {
    state.snoozeUntilMs[activityId] = clock.nowMs() + duration.inMilliseconds;
    await _persistAndResync();
  }

  Future<void> setActivityEnabled(String activityId, bool enabled) async {
    _updateActivity(activityId, (a) => a.copyWith(enabled: enabled));
    if (enabled && state.running) {
      state.lastDoneMs.putIfAbsent(activityId, () => clock.nowMs());
    }
    await _persistAndResync();
  }

  Future<void> setActivityInterval(String activityId, Duration interval) async {
    if (interval.inMinutes < 1) return;
    _updateActivity(activityId, (a) => a.copyWith(interval: interval));
    await _persistAndResync();
  }

  Future<void> setActivityGoal(String activityId, int goalQty) async {
    _updateActivity(activityId, (a) => a.copyWith(goalQty: goalQty));
    await _persistAndResync();
  }

  // ------------------------------------------------------------------- pet

  PetMood mood() => PetMoods.derive(
        running: state.running,
        activities: state.activities,
        anchorMs: state.lastDoneMs,
        snoozeUntilMs: state.snoozeUntilMs,
        nowMs: clock.nowMs(),
      );

  double needFraction(CareActivity activity) {
    final anchor = state.lastDoneMs[activity.id];
    if (anchor == null || !state.running) return 0.0;
    return ScheduleMath.needFraction(
        activity, anchor, state.snoozeUntilMs[activity.id], clock.nowMs());
  }

  bool isOverdue(CareActivity activity) {
    final anchor = state.lastDoneMs[activity.id];
    if (anchor == null || !state.running) return false;
    return ScheduleMath.isOverdue(
        activity, anchor, state.snoozeUntilMs[activity.id], clock.nowMs());
  }

  Duration? timeUntilDue(CareActivity activity) {
    final anchor = state.lastDoneMs[activity.id];
    if (anchor == null || !state.running) return null;
    final due = ScheduleMath.dueAtMs(
        activity, anchor, state.snoozeUntilMs[activity.id]);
    final diff = due - clock.nowMs();
    return diff <= 0 ? Duration.zero : Duration(milliseconds: diff);
  }

  /// The activity the pet is asking about: the most-overdue one, or the
  /// next one coming due.
  CareActivity? focusActivity() {
    final now = clock.nowMs();
    CareActivity? best;
    double bestRatio = 0;
    for (final a in enabledActivities) {
      final anchor = state.lastDoneMs[a.id];
      if (anchor == null) continue;
      final ratio =
          ScheduleMath.overdueRatio(a, anchor, state.snoozeUntilMs[a.id], now);
      if (ratio > bestRatio) {
        bestRatio = ratio;
        best = a;
      }
    }
    if (best != null) return best;

    int? soonest;
    for (final a in enabledActivities) {
      final anchor = state.lastDoneMs[a.id];
      if (anchor == null) continue;
      final due = ScheduleMath.dueAtMs(a, anchor, state.snoozeUntilMs[a.id]);
      if (soonest == null || due < soonest) {
        soonest = due;
        best = a;
      }
    }
    return best;
  }

  List<CareActivity> get enabledActivities =>
      state.activities.where((a) => a.enabled).toList();

  // ------------------------------------------------------------------- game

  Future<void> choosePet(PetSpecies species) async {
    state.game = state.game.copyWith(species: species);
    await _persistAndResync();
  }

  bool canAfford(Cosmetic cosmetic) => state.game.sparks >= cosmetic.cost;

  Future<bool> buyCosmetic(String cosmeticId) async {
    final cosmetic = Cosmetics.byId(cosmeticId);
    if (cosmetic == null) return false;
    if (state.game.ownedCosmetics.contains(cosmeticId)) return true;
    if (!canAfford(cosmetic)) return false;
    state.game = state.game.copyWith(
      sparks: state.game.sparks - cosmetic.cost,
      ownedCosmetics: {...state.game.ownedCosmetics, cosmeticId},
    );
    await _persistAndResync();
    return true;
  }

  Future<void> wearCosmetic(String cosmeticId) async {
    final cosmetic = Cosmetics.byId(cosmeticId);
    if (cosmetic == null || !state.game.ownedCosmetics.contains(cosmeticId)) {
      return;
    }
    final worn = Map<CosmeticSlot, String>.from(state.game.worn);
    if (worn[cosmetic.slot] == cosmeticId) {
      worn.remove(cosmetic.slot);
    } else {
      worn[cosmetic.slot] = cosmeticId;
    }
    state.game = state.game.copyWith(worn: worn);
    await _persistAndResync();
  }

  // ------------------------------------------------------------- statistics

  int todayCount(String activityId) {
    final now = clock.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    return state.events
        .where((e) => e.activityId == activityId && e.atMs >= startOfDay)
        .length;
  }

  int todayQty(String activityId) {
    final now = clock.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    return state.events
        .where((e) => e.activityId == activityId && e.atMs >= startOfDay)
        .fold(0, (sum, e) => sum + e.qty);
  }

  /// Care moments per local day for the last [days] days, newest last.
  /// Day distance is computed on UTC-constructed calendar dates so a DST
  /// transition (23/25-hour day) can never shift events into the wrong
  /// bucket via elapsed-time truncation.
  List<int> dailyCounts({int days = 14}) {
    final now = clock.now();
    final counts = List<int>.filled(days, 0);
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    for (final e in state.events) {
      final local = DateTime.fromMillisecondsSinceEpoch(e.atMs);
      final dayUtc = DateTime.utc(local.year, local.month, local.day);
      final dayDiff = todayUtc.difference(dayUtc).inDays;
      if (dayDiff >= 0 && dayDiff < days) {
        counts[days - 1 - dayDiff]++;
      }
    }
    return counts;
  }

  // ------------------------------------------------------- settings & data

  Future<void> setCloseToTray(bool value) async {
    state.closeToTray = value;
    await _persistAndResync();
  }

  Future<void> setAlwaysOnTop(bool value) async {
    state.alwaysOnTop = value;
    await _persistAndResync();
  }

  Future<void> setLaunchAtStartup(bool value) async {
    state.launchAtStartup = value;
    await _persistAndResync();
  }

  String? exportJson() => _store.exportJson();

  Future<void> clearAllData() async {
    await _scheduler?.resync(ZenuState(), texts);
    await _store.clearAll();
    state = ZenuState();
    notifyListeners();
  }

  // ------------------------------------------------------------- lifecycle

  /// Called on launch and on every app resume: apply notification actions
  /// taken while we weren't looking, then re-derive the OS queue.
  Future<void> reconcile() async {
    await _drainPendingActions();
    await _persistAndResync();
  }

  Future<void> refreshPermissionStatus({bool request = false}) async {
    final scheduler = _scheduler;
    if (scheduler == null) return;
    if (request) await scheduler.requestPermission();
    notificationsAllowed = await scheduler.notificationsEnabled();
    notifyListeners();
  }

  void setTexts(NotificationTexts newTexts) {
    // The OS queue is armed at startup with fallback English; once the
    // real locale arrives, re-arm so scheduled toasts speak the user's
    // language. Guarded, because MaterialApp's builder calls this on
    // every rebuild.
    final changed = texts.channelName != newTexts.channelName ||
        texts.titleByKind['water'] != newTexts.titleByKind['water'];
    texts = newTexts;
    if (changed && state.running) {
      _persistAndResync(notify: false);
    }
  }

  /// In-process delivery check for platforms without OS scheduling
  /// (Linux/macOS). Called by the ticker; keyed by due instant so each due
  /// occurrence notifies exactly once, but a completion resets the key and
  /// the next cycle notifies again.
  final Set<String> _delivered = {};

  Future<void> tickDeliveryFallback() async {
    final scheduler = _scheduler;
    if (scheduler == null || NotificationScheduler.supportsOsScheduling) {
      return;
    }
    if (!state.running) return;
    final now = clock.nowMs();
    for (final activity in enabledActivities) {
      final anchor = state.lastDoneMs[activity.id];
      if (anchor == null) continue;
      final due = ScheduleMath.dueAtMs(
          activity, anchor, state.snoozeUntilMs[activity.id]);
      if (now < due) continue;
      final key = '${activity.id}@$due';
      if (_delivered.contains(key)) continue;
      _delivered.add(key);
      await scheduler.showNow(activity, texts);
    }
  }

  // -------------------------------------------------------------- internals

  void _onNotificationAction(String activityId, String action) {
    if (action == actionDoneId) {
      logCare(activityId);
    } else if (action == actionSnoozeId) {
      snooze(activityId);
    } else {
      // Plain tap: state is re-derived when the app comes forward.
      reconcile();
    }
  }

  Future<void> _drainPendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // The queue is written by the notification background isolate; the
      // main isolate's prefs cache is a startup snapshot, so reload or the
      // actions stay invisible until the process dies.
      await prefs.reload();
      final queue = prefs.getStringList(pendingActionsKey);
      if (queue == null || queue.isEmpty) return;
      for (final raw in queue) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final activityId = decoded['activityId'] as String;
          final action = decoded['action'] as String? ?? 'tap';
          final atMs = (decoded['atMs'] as num?)?.toInt() ?? clock.nowMs();
          if (action == actionDoneId) {
            final activity = _activity(activityId);
            if (activity == null) continue;
            final anchor = state.lastDoneMs[activityId] ?? 0;
            // A queued Done at or before the current anchor is already
            // reflected (or a crash-replay) — applying it again would
            // duplicate the event and the spark award.
            if (atMs <= anchor) continue;
            state.events.add(CompletionEvent(
              activityId: activityId,
              atMs: atMs,
              qty: activity.goalQty,
            ));
            state.lastDoneMs[activityId] = atMs;
            state.snoozeUntilMs.remove(activityId);
            state.game =
                state.game.copyWith(sparks: state.game.sparks + sparksPerCare);
          } else if (action == actionSnoozeId) {
            state.snoozeUntilMs[activityId] =
                atMs + const Duration(minutes: 10).inMilliseconds;
          }
        } catch (_) {}
      }
      // Persist the applied actions BEFORE removing them from the queue,
      // so a crash or failed save replays instead of silently discarding
      // the user's taps (replay is deduped by the anchor check above).
      final saved = await _store.save(state);
      if (saved) {
        await prefs.reload();
        final current = prefs.getStringList(pendingActionsKey) ?? [];
        if (current.length <= queue.length) {
          await prefs.remove(pendingActionsKey);
        } else {
          // The background isolate appended more while we worked — keep
          // only the unprocessed tail.
          await prefs.setStringList(
              pendingActionsKey, current.sublist(queue.length));
        }
      }
    } catch (e) {
      debugPrint('draining pending actions failed: $e');
    }
  }

  CareActivity? _activity(String id) {
    for (final a in state.activities) {
      if (a.id == id) return a;
    }
    return null;
  }

  void _updateActivity(String id, CareActivity Function(CareActivity) update) {
    state.activities = [
      for (final a in state.activities) a.id == id ? update(a) : a,
    ];
  }

  /// Serialized: saves and resyncs are chained so a later call always runs
  /// after — and therefore supersedes — an earlier one. Without this, two
  /// overlapping resyncs can interleave their cancel/schedule batches and
  /// leave stale notifications armed.
  Future<void> _resyncChain = Future.value();

  Future<void> _persistAndResync({bool notify = true}) {
    // State is already mutated synchronously by the caller; tell the UI
    // immediately, persist in order.
    if (notify) notifyListeners();
    final task = _resyncChain.then((_) async {
      await _store.save(state);
      await _scheduler?.resync(state, texts);
    });
    _resyncChain = task.catchError((e) {
      debugPrint('persist/resync failed: $e');
    });
    return task;
  }
}
