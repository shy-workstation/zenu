import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'data/app_store.dart';
import 'l10n/app_localizations.dart';
import 'services/care_service.dart';
import 'services/notification_scheduler.dart';
import 'services/notification_texts.dart';
import 'services/theme_controller.dart';
import 'services/ticker_service.dart';
import 'services/tray_service.dart';
import 'ui/shell.dart';
import 'ui/zenu_theme.dart';

bool get _isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_isDesktop) {
    await windowManager.ensureInitialized();
    // A companion, not a dashboard: small by default, comfortable minimum.
    const windowOptions = WindowOptions(
      size: Size(430, 700),
      minimumSize: Size(360, 560),
      center: true,
      title: 'Zenu',
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final scheduler = await NotificationScheduler.create();
    final store = AppStore(prefs);
    final care = await CareService.create(store: store, scheduler: scheduler);
    final themeController = ThemeController(prefs);
    final ticker = TickerService(care);

    await care.refreshPermissionStatus();

    if (_isDesktop && care.state.alwaysOnTop) {
      try {
        await windowManager.setAlwaysOnTop(true);
      } catch (_) {}
    }
    if (Platform.isWindows || Platform.isMacOS) {
      try {
        launchAtStartup.setup(
          appName: 'Zenu',
          appPath: Platform.resolvedExecutable,
        );
      } catch (_) {}
    }

    runApp(ZenuApp(
      care: care,
      themeController: themeController,
      ticker: ticker,
    ));
  } catch (e, stack) {
    debugPrint('Failed to start Zenu: $e\n$stack');
    runApp(const _StartupErrorApp());
  }
}

class ZenuApp extends StatefulWidget {
  final CareService care;
  final ThemeController themeController;
  final TickerService ticker;

  const ZenuApp({
    super.key,
    required this.care,
    required this.themeController,
    required this.ticker,
  });

  @override
  State<ZenuApp> createState() => _ZenuAppState();
}

class _ZenuAppState extends State<ZenuApp> {
  TrayService? _tray;

  @override
  void dispose() {
    _tray?.dispose();
    widget.ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.care),
        ChangeNotifierProvider.value(value: widget.themeController),
        Provider.value(value: widget.ticker),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          title: 'Zenu',
          theme: ZenuTheme.light(),
          darkTheme: ZenuTheme.dark(),
          themeMode: themeController.mode,
          supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final l10n = AppLocalizations.of(context);
            if (l10n != null) {
              widget.care.setTexts(NotificationTexts.of(l10n));
              _initTrayOnce(l10n);
            }
            return child!;
          },
          home: const ZenuShell(),
        ),
      ),
    );
  }

  void _initTrayOnce(AppLocalizations l10n) {
    if (_tray != null || !TrayService.supported) return;
    _tray = TrayService(
      widget.care,
      showLabel: l10n.v2TrayShow,
      pauseLabel: l10n.v2TrayPause,
      resumeLabel: l10n.v2TrayResume,
      quitLabel: l10n.v2TrayQuit,
    );
    _tray!.init();
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenu',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Unable to start Zenu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Please restart the application.'),
            ],
          ),
        ),
      ),
    );
  }
}
