import 'care_activity.dart';

/// Pure scheduling math. Everything derives from persisted wall-clock
/// timestamps — never from a live timer — so the pet's state is correct
/// on a cold launch, after sleep/resume, and after a reboot.
class ScheduleMath {
  /// Re-nag spacing for an ignored reminder, and how many nags are queued
  /// per cycle. 5 activities x (1 + 2) = 15 pending notifications, safely
  /// under iOS's 64-pending cap.
  static const Duration renagSpacing = Duration(minutes: 10);
  static const int renagCount = 2;

  /// When the next completion is expected. [anchorMs] is the last
  /// completion, or the session start for a never-completed activity.
  /// A snooze pushes the due time out if it lands later.
  static int dueAtMs(CareActivity activity, int anchorMs, int? snoozeUntilMs) {
    final due = anchorMs + activity.interval.inMilliseconds;
    if (snoozeUntilMs != null && snoozeUntilMs > due) return snoozeUntilMs;
    return due;
  }

  /// 0.0 = just satisfied, 1.0 = due now (or overdue).
  static double needFraction(
    CareActivity activity,
    int anchorMs,
    int? snoozeUntilMs,
    int nowMs,
  ) {
    final due = dueAtMs(activity, anchorMs, snoozeUntilMs);
    final windowMs = due - anchorMs;
    if (windowMs <= 0) return 1.0;
    final f = (nowMs - anchorMs) / windowMs;
    if (f < 0) return 0.0;
    if (f > 1) return 1.0;
    return f;
  }

  static bool isOverdue(
    CareActivity activity,
    int anchorMs,
    int? snoozeUntilMs,
    int nowMs,
  ) =>
      nowMs >= dueAtMs(activity, anchorMs, snoozeUntilMs);

  /// How far past due, as a multiple of the interval. Used to pick which
  /// need the pet voices when several are overdue.
  static double overdueRatio(
    CareActivity activity,
    int anchorMs,
    int? snoozeUntilMs,
    int nowMs,
  ) {
    final due = dueAtMs(activity, anchorMs, snoozeUntilMs);
    if (nowMs < due) return 0.0;
    return (nowMs - due) / activity.interval.inMilliseconds;
  }

  /// The future notification times to hand the OS: the due moment plus
  /// [renagCount] follow-ups. Times already in the past are dropped —
  /// an overdue need is voiced by the pet and the next re-nag, not by a
  /// backdated burst.
  static List<int> notificationTimesMs(
    CareActivity activity,
    int anchorMs,
    int? snoozeUntilMs,
    int nowMs,
  ) {
    final due = dueAtMs(activity, anchorMs, snoozeUntilMs);
    final spacing = renagSpacing.inMilliseconds;
    // For an already-overdue activity, roll the whole nag train forward to
    // the next grid point — never a backdated burst, never a collapsed one.
    var first = due;
    if (first <= nowMs) {
      final behind = nowMs - due;
      first = due + (behind ~/ spacing + 1) * spacing;
    }
    return [for (var i = 0; i <= renagCount; i++) first + i * spacing];
  }
}
