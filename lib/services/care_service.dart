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
    state.events.add(CompletionEvent(
      activityId: activityId,
      atMs: at,
      qty: qty ?? activity.goalQty,
    ));
    state.lastDoneMs[activityId] = at;
    state.snoozeUntilMs.remove(activityId);
    state.game = state.game.copyWith(sparks: state.game.sparks + sparksPerCare);
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
  List<int> dailyCounts({int days = 14}) {
    final now = clock.now();
    final counts = List<int>.filled(days, 0);
    final startOfToday = DateTime(now.year, now.month, now.day);
    for (final e in state.events) {
      final local = DateTime.fromMillisecondsSinceEpoch(e.atMs);
      final dayDiff = startOfToday
          .difference(DateTime(local.year, local.month, local.day))
          .inDays;
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
    texts = newTexts;
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
      final queue = prefs.getStringList(pendingActionsKey);
      if (queue == null || queue.isEmpty) return;
      await prefs.remove(pendingActionsKey);
      for (final raw in queue) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final activityId = decoded['activityId'] as String;
          final action = decoded['action'] as String? ?? 'tap';
          final atMs = (decoded['atMs'] as num?)?.toInt();
          if (action == actionDoneId) {
            final activity = _activity(activityId);
            if (activity == null) continue;
            state.events.add(CompletionEvent(
              activityId: activityId,
              atMs: atMs ?? clock.nowMs(),
              qty: activity.goalQty,
            ));
            final anchor = state.lastDoneMs[activityId] ?? 0;
            if ((atMs ?? clock.nowMs()) > anchor) {
              state.lastDoneMs[activityId] = atMs ?? clock.nowMs();
            }
            state.snoozeUntilMs.remove(activityId);
            state.game =
                state.game.copyWith(sparks: state.game.sparks + sparksPerCare);
          } else if (action == actionSnoozeId && atMs != null) {
            state.snoozeUntilMs[activityId] =
                atMs + const Duration(minutes: 10).inMilliseconds;
          }
        } catch (_) {}
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

  Future<void> _persistAndResync({bool notify = true}) async {
    await _store.save(state);
    await _scheduler?.resync(state, texts);
    if (notify) notifyListeners();
  }
}
