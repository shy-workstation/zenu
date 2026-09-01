import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'care_service.dart';

/// System-tray presence + close-to-tray. Closing the window must never
/// kill reminders — the app hides to the tray and delivery continues via
/// OS-scheduled toasts.
class TrayService with TrayListener, WindowListener {
  final CareService care;
  final String showLabel;
  final String pauseLabel;
  final String resumeLabel;
  final String quitLabel;

  bool _quitting = false;

  static bool get supported => Platform.isWindows || Platform.isLinux;

  TrayService(
    this.care, {
    required this.showLabel,
    required this.pauseLabel,
    required this.resumeLabel,
    required this.quitLabel,
  });

  Future<void> init() async {
    if (!supported) return;
    try {
      await trayManager.setIcon(
        Platform.isWindows
            ? 'assets/icon/tray_icon.ico'
            : 'assets/icon/app_icon_512.png',
      );
      await trayManager.setToolTip('Zenu');
      await _refreshMenu();
      trayManager.addListener(this);
      windowManager.addListener(this);
      await windowManager.setPreventClose(true);
    } catch (e) {
      debugPrint('tray init failed: $e');
    }
  }

  Future<void> _refreshMenu() async {
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(key: 'show', label: showLabel),
      MenuItem(key: 'toggle', label: care.running ? pauseLabel : resumeLabel),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: quitLabel),
    ]));
  }

  @override
  void onTrayIconMouseDown() => _show();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show':
        await _show();
        break;
      case 'toggle':
        if (care.running) {
          await care.pauseSession();
        } else {
          await care.startSession();
        }
        await _refreshMenu();
        break;
      case 'quit':
        _quitting = true;
        await windowManager.setPreventClose(false);
        await windowManager.destroy();
        break;
    }
  }

  Future<void> _show() async {
    if (await windowManager.isMinimized()) await windowManager.restore();
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onWindowClose() async {
    if (_quitting) return;
    if (care.state.closeToTray) {
      await windowManager.hide();
    } else {
      await windowManager.setPreventClose(false);
      await windowManager.destroy();
    }
  }

  void dispose() {
    if (!supported) return;
    trayManager.removeListener(this);
    windowManager.removeListener(this);
  }
}
