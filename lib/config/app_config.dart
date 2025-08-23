/// Application configuration and constants
class AppConfig {
  // App Information
  static const String appName = 'Zenu';
  static const String version = '1.0.2';
  static const String buildNumber = '3';

  // Performance Settings
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration cacheExpiry = Duration(minutes: 10);
  static const int maxCacheEntries = 100;
  static const int maxErrorLogs = 100;

  // UI Settings
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double iconSize = 24.0;
  static const double minSliderValue = 1.0;
  static const double maxSliderValue = 1000.0;

  // Notification Settings
  static const Duration minReminderInterval = Duration(minutes: 1);
  static const Duration maxReminderInterval = Duration(days: 7);
  static const Duration defaultReminderInterval = Duration(hours: 1);

  // Data Limits
  static const int maxReminders = 50;
  static const int maxReminderTitleLength = 100;
  static const int maxReminderDescriptionLength = 500;

  // Debug Settings
  static const bool enablePerformanceLogging = true;
  static const bool enableErrorReporting = true;
  static const bool enableCaching = true;

  // Theme Settings
  static const bool defaultDarkMode = false;
  static const double defaultFontSize = 16.0;

  // Storage Keys
  static const String themeKey = 'theme_settings';
  static const String remindersKey = 'reminders';
  static const String statisticsKey = 'statistics';
  static const String errorLogsKey = 'app_error_logs';
  static const String cacheKey = 'app_cache';

  // Feature Flags
  static const bool enableAdvancedStatistics = true;
  static const bool enableExportImport = false; // Future feature
  static const bool enableCloudSync = false; // Future feature
  static const bool enableMultiLanguage = false; // Future feature

  // URLs (for future features)
  static const String supportUrl = 'https://example.com/support';
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
}

/// Color constants for consistent theming
class AppColors {
  // Primary Colors
  static const primaryBlue = 0xFF2196F3;
  static const primaryGreen = 0xFF4CAF50;
  static const primaryRed = 0xFFF44336;
  static const primaryOrange = 0xFFFF9800;
  static const primaryPurple = 0xFF9C27B0;

  // Semantic Colors
  static const success = 0xFF4CAF50;
  static const warning = 0xFFFF9800;
  static const error = 0xFFF44336;
  static const info = 0xFF2196F3;

  // Neutral Colors
  static const white = 0xFFFFFFFF;
  static const black = 0xFF000000;
  static const grey = 0xFF9E9E9E;
  static const lightGrey = 0xFFF5F5F5;
  static const darkGrey = 0xFF424242;
}

/// Animation constants
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Curve constants
  static const curveFastOutSlowIn = 'fastOutSlowIn';
  static const curveEaseInOut = 'easeInOut';
  static const curveLinear = 'linear';
}

/// Text style constants
class AppTextStyles {
  static const double headlineSize = 24.0;
  static const double titleSize = 20.0;
  static const double bodySize = 16.0;
  static const double captionSize = 12.0;

  static const String fontFamily = 'System'; // Uses system font
}

/// Spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Environment configuration
enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Environment currentEnvironment = Environment.development;

  static bool get isDevelopment =>
      currentEnvironment == Environment.development;
  static bool get isStaging => currentEnvironment == Environment.staging;
  static bool get isProduction => currentEnvironment == Environment.production;

  // Environment-specific settings
  static bool get enableDebugLogs => !isProduction;
  static bool get enableErrorReporting => isProduction || isStaging;
  static Duration get cacheTimeout =>
      isDevelopment ? const Duration(minutes: 1) : const Duration(minutes: 10);
}
