import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:window_manager/window_manager.dart';

import '../domain/care_activity.dart';
import '../domain/schedule_math.dart';
import '../domain/zenu_state.dart';
import 'notification_texts.dart';

/// Queued action from the Android background isolate (a "Done"/"Snooze"
/// button pressed while the app process wasn't running the UI). Drained by
/// CareService on the next launch/resume.
const pendingActionsKey = 'zenu.v2.pendingActions';

const actionDoneId = 'zenu_done';
const actionSnoozeId = 'zenu_snooze';

/// Decoded notification interaction: which activity, which action.
/// Platform contracts differ and are all normalized here:
/// - Android tap: payload=`care:x`, actionId=null            -> tap
/// - Android button: payload=`care:x`, actionId=`zenu_done`  -> done
/// - Windows tap: payload=actionId=`care:x` (the plugin sets
///   actionId to the activation arguments, so it is NEVER null)  -> tap
/// - Windows button: payload=actionId=`care:x|zenu_done`
///   (the button's own arguments string; the toast's launch
///   payload is NOT delivered for button clicks)                 -> done
({String activityId, String action})? parseCareResponse(
    NotificationResponse response) {
  final payload = response.payload;
  if (payload == null || !payload.startsWith('care:')) return null;
  final body = payload.substring(5);
  final separator = body.indexOf('|');
  if (separator > 0) {
    return (
      activityId: body.substring(0, separator),
      action: body.substring(separator + 1),
    );
  }
  final actionId = response.actionId;
  if (actionId != null && actionId != payload) {
    return (activityId: body, action: actionId);
  }
  return (activityId: body, action: 'tap');
}

@pragma('vm:entry-point')
void zenuNotificationBackgroundHandler(NotificationResponse response) async {
  final parsed = parseCareResponse(response);
  if (parsed == null) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    // This runs in the plugin's background isolate; reload so we never
    // clobber entries the main isolate wrote after our cache snapshot.
    await prefs.reload();
    final queue = prefs.getStringList(pendingActionsKey) ?? [];
    queue.add(jsonEncode({
      'activityId': parsed.activityId,
      'action': parsed.action,
      'atMs': DateTime.now().millisecondsSinceEpoch,
    }));
    await prefs.setStringList(pendingActionsKey, queue);
  } catch (e) {
    debugPrint('background notification action failed: $e');
  }
}

/// Hands reminders to the OS scheduler on every platform that has one —
/// Android, iOS, AND Windows — so delivery survives focus loss, minimize,
/// close (mobile), and reboot (mobile). The app process is never the
/// delivery mechanism where the OS can do it.
class NotificationScheduler {
  /// Platforms where the OS fires scheduled notifications for us.
  /// Linux/macOS fall back to in-process delivery from the ticker.
  static bool get supportsOsScheduling =>
      Platform.isAndroid || Platform.isIOS || Platform.isWindows;

  final FlutterLocalNotificationsPlugin _plugin;

  /// Set by CareService; receives foreground notification interactions.
  /// Responses arriving before it is bound (e.g. a Windows toast
  /// activation during a cold launch) are buffered and flushed on bind.
  static void Function(String activityId, String action)? _actionHandler;
  static final List<({String activityId, String action})> _earlyResponses = [];

  static set actionHandler(
      void Function(String activityId, String action)? handler) {
    _actionHandler = handler;
    if (handler != null) {
      final buffered = List.of(_earlyResponses);
      _earlyResponses.clear();
      for (final r in buffered) {
        handler(r.activityId, r.action);
      }
    }
  }

  NotificationScheduler._(this._plugin);

  static Future<NotificationScheduler> create() async {
    tz_data.initializeTimeZones();
    final plugin = FlutterLocalNotificationsPlugin();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_stat_zenu'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      // Identity must stay in lockstep with msix_config (pubspec.yaml),
      // including the toast_activator CLSID, or Store users' toasts break.
      windows: WindowsInitializationSettings(
        appName: 'Zenu',
        appUserModelId: 'YousofShehada.Zenu',
        guid: 'BE46DC6D-FD4E-4ABB-A08C-68EABDEC1169',
      ),
    );

    await plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse:
          zenuNotificationBackgroundHandler,
    );

    return NotificationScheduler._(plugin);
  }

  static void _onResponse(NotificationResponse response) {
    final parsed = parseCareResponse(response);
    if (parsed == null) return;
    final handler = _actionHandler;
    if (handler != null) {
      handler(parsed.activityId, parsed.action);
    } else {
      _earlyResponses.add(parsed);
    }
    if (parsed.action == 'tap') _bringToForeground();
  }

  static Future<void> _bringToForeground() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) return;
    try {
      if (await windowManager.isMinimized()) await windowManager.restore();
      await windowManager.show();
      await windowManager.focus();
    } catch (_) {}
  }

  /// Ask for permission (Android 13+) and report whether notifications are
  /// currently allowed — surfaced in the UI instead of failing silently.
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }
    return true;
  }

  Future<bool> notificationsEnabled() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  /// Stable, collision-free ids: a fixed slot per activity, a small range
  /// of occurrence ids inside it.
  static const _idsPerActivity = 10;
  int _occurrenceId(String activityId, int n) =>
      1000 + Activities.notificationSlot(activityId) * _idsPerActivity + n;

  /// Per-activity details: Windows delivers a clicked button's own
  /// `arguments` string as the entire response (payload AND actionId), so
  /// the activity must be encoded into each button, not only the toast
  /// payload — see [parseCareResponse].
  NotificationDetails _details(NotificationTexts texts, String activityId) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'care_reminders',
        texts.channelName,
        channelDescription: texts.channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/ic_stat_zenu',
        actions: [
          AndroidNotificationAction(
            actionDoneId,
            texts.actionDone,
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            actionSnoozeId,
            texts.actionSnooze,
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: const LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(
        actions: [
          WindowsAction(
            content: texts.actionDone,
            arguments: 'care:$activityId|$actionDoneId',
          ),
          WindowsAction(
            content: texts.actionSnooze,
            arguments: 'care:$activityId|$actionSnoozeId',
          ),
        ],
      ),
    );
  }

  /// Re-derive the entire pending-notification set from persisted state.
  /// Cancels only Zenu's own occurrence ids (never cancelAll), then queues
  /// the due moment plus re-nags for every enabled activity.
  Future<void> resync(ZenuState state, NotificationTexts texts) async {
    for (final activity in state.activities) {
      for (var n = 0; n < _idsPerActivity; n++) {
        try {
          await _plugin.cancel(id: _occurrenceId(activity.id, n));
        } catch (_) {}
      }
    }

    if (!state.running || !supportsOsScheduling) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    for (final activity in state.activities) {
      if (!activity.enabled) continue;
      final details = _details(texts, activity.id);
      final anchor = state.lastDoneMs[activity.id];
      if (anchor == null) continue;
      final times = ScheduleMath.notificationTimesMs(
        activity,
        anchor,
        state.snoozeUntilMs[activity.id],
        nowMs,
      );
      for (var n = 0; n < times.length; n++) {
        final fireTime =
            DateTime.fromMillisecondsSinceEpoch(times[n], isUtc: false);
        try {
          await _plugin.zonedSchedule(
            id: _occurrenceId(activity.id, n),
            title: texts.titleFor(activity.kind),
            body: texts.bodyFor(activity.kind),
            scheduledDate: tz.TZDateTime.from(fireTime.toUtc(), tz.UTC),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: 'care:${activity.id}',
          );
        } catch (e) {
          debugPrint('scheduling ${activity.id}#$n failed: $e');
        }
      }
    }
  }

  /// Immediate delivery for platforms without OS scheduling (Linux/macOS),
  /// driven by the in-process ticker while the app runs.
  Future<void> showNow(CareActivity activity, NotificationTexts texts) async {
    try {
      await _plugin.show(
        id: _occurrenceId(activity.id, 9),
        title: texts.titleFor(activity.kind),
        body: texts.bodyFor(activity.kind),
        notificationDetails: _details(texts, activity.id),
        payload: 'care:${activity.id}',
      );
    } catch (e) {
      debugPrint('showNow ${activity.id} failed: $e');
    }
  }
}
