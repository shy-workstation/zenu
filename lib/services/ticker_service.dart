import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';

import 'care_service.dart';

/// One-second UI heartbeat. This ticker repaints countdowns and drives the
/// Linux/macOS delivery fallback — it is NEVER the delivery mechanism on
/// platforms with OS scheduling, so pausing it can't lose reminders.
///
/// Desktop: keeps ticking while unfocused/minimized (the fix for v1's
/// fatal pause-on-inactive). Mobile: pauses in background — the OS-side
/// schedule covers delivery — and reconciles on resume.
class TickerService with WidgetsBindingObserver {
  final CareService care;
  final ValueNotifier<int> nowMs = ValueNotifier(0);
  Timer? _timer;

  static bool get _isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  TickerService(this.care) {
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  void _start() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      nowMs.value = DateTime.now().millisecondsSinceEpoch;
      care.tickDeliveryFallback();
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _start();
        // Re-derive everything from wall clock after any time away.
        care.reconcile();
        care.refreshPermissionStatus();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Desktop 'inactive' just means unfocused — keep ticking.
        if (!_isDesktop) _stop();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (!_isDesktop) _stop();
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    nowMs.dispose();
  }
}
