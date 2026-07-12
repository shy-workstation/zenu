import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';
import 'services/data_service.dart';
import 'services/theme_service.dart';
import 'screens/orbital_home_screen.dart';
import 'utils/state_management.dart';
import 'utils/platform_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager only on desktop platforms
  if (PlatformHelper.supportsWindowManagement) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 960),
      minimumSize: Size(900, 760),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  try {
    final notificationService = await NotificationService.getInstance();
    final dataService = await DataService.getInstance();
    final themeService = await ThemeService.getInstance();
    final reminderService = ReminderService(notificationService, dataService);

    await reminderService.loadData();

    runApp(
      HealthReminderApp(
        reminderService: reminderService,
        themeService: themeService,
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Failed to start app: $e');
    }

    runApp(
      MaterialApp(
        title: 'Zenu',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Unable to start Zenu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  kDebugMode
                      ? 'Please restart the application.\n$e'
                      : 'Please restart the application.',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HealthReminderApp extends StatelessWidget {
  final ReminderService reminderService;
  final ThemeService themeService;

  const HealthReminderApp({
    super.key,
    required this.reminderService,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<ThemeService>(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return Provider<ReminderService>(
            value: reminderService,
            child: MaterialApp(
              title: 'Zenu',
              theme: themeService.lightTheme,
              darkTheme: themeService.darkTheme,
              themeMode: themeService.themeMode,
              supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, widget) {
                final localizations = AppLocalizations.of(context);
                if (localizations != null) {
                  reminderService.setLocalizations(localizations);
                }
                return widget!;
              },
              home: OrbitalHomeScreen(
                reminderService: reminderService,
                themeService: themeService,
              ),
            ),
          );
        },
      ),
    );
  }
}
