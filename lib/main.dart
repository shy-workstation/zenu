import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';
import 'services/data_service.dart';
import 'services/theme_service.dart';
import 'services/in_app_notification_service.dart';
import 'screens/home_screen.dart';
import 'utils/state_management.dart';
import 'utils/error_handler.dart';
import 'utils/memory_cache.dart';
import 'utils/app_lifecycle_manager.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling first
  ErrorHandler.logInfo('🚀 Starting Zenu v${AppConfig.version}');

  try {
    // Initialize services with error handling
    final notificationService = await NotificationService.getInstance();
    final dataService = await DataService.getInstance();
    final themeService = await ThemeService.getInstance();
    final inAppNotificationService = InAppNotificationService();
    final reminderService = ReminderService(notificationService, dataService);

    // Set up in-app notification service for reminder service
    reminderService.setInAppNotificationService(inAppNotificationService);

    // Load saved data with error handling
    await reminderService.loadData();

    // Initialize cache system
    MemoryCache().initialize();

    // Initialize app lifecycle management
    await AppLifecycleManager.instance.initialize();

    ErrorHandler.logInfo('✅ All services initialized successfully');

    ErrorHandler.logInfo('🏠 About to launch HealthReminderApp');
    runApp(
      HealthReminderApp(
        reminderService: reminderService,
        themeService: themeService,
        inAppNotificationService: inAppNotificationService,
      ),
    );
  } catch (e, stackTrace) {
    // Handle critical startup errors
    await ErrorHandler.handleError(
      e,
      stackTrace,
      context: 'main() startup',
      severity: ErrorSeverity.critical,
    );

    // Still try to run the app with minimal functionality
    runApp(
      MaterialApp(
        title: AppConfig.appName,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to start app',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Error: ${e.toString()}'),
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
  final InAppNotificationService inAppNotificationService;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  HealthReminderApp({
    super.key,
    required this.reminderService,
    required this.themeService,
    required this.inAppNotificationService,
  }) {
    // Set the navigator key for in-app notifications
    inAppNotificationService.setNavigatorKey(navigatorKey);
  }

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
              navigatorKey: navigatorKey,
              theme: themeService.lightTheme,
              darkTheme: themeService.darkTheme,
              themeMode:
                  themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: HomeScreen(
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
