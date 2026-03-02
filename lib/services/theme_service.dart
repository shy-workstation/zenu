import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier with WidgetsBindingObserver {
  static const String _themeKey = 'theme_mode';
  static const String _themeLegacyKey = 'theme_mode_legacy';
  static ThemeService? _instance;
  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  ThemeService._();

  static Future<ThemeService> getInstance() async {
    if (_instance == null) {
      _instance = ThemeService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    WidgetsBinding.instance.addObserver(this);

    // Migrate from old bool storage to new string storage
    // The old code stored a bool under the same 'theme_mode' key,
    // so getString() will throw if it finds a bool. Use try-catch.
    String? savedMode;
    try {
      savedMode = _prefs?.getString(_themeKey);
    } catch (_) {
      // Old bool value exists under this key — treat as legacy
    }

    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    } else {
      // Check legacy bool key for migration
      bool? legacyDark;
      try {
        legacyDark = _prefs?.getBool(_themeKey);
      } catch (_) {}
      legacyDark ??= _prefs?.getBool(_themeLegacyKey);

      if (legacyDark != null) {
        _themeMode = legacyDark ? ThemeMode.dark : ThemeMode.light;
      }
      // Save in new string format and clean up old keys
      await _prefs?.setString(_themeKey, _themeMode.name);
      await _prefs?.remove(_themeLegacyKey);
    }
  }

  @override
  void didChangePlatformBrightness() {
    // When OS dark/light mode changes, update widgets using custom colors
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Cycles through: system -> light -> dark -> system
  Future<void> cycleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
    }
    await _prefs?.setString(_themeKey, _themeMode.name);
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1E293B),
      elevation: 0,
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF8B5CF6),
      tertiary: Color(0xFF059669), // Green for success states
      surface: Colors.white,
      onSurface: Color(0xFF1E293B),
      onSurfaceVariant: Color(0xFF64748B), // WCAG AA compliant secondary text
      surfaceContainerHighest: Color(0xFFE2E8F0),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Color(0xFFF1F5F9),
      elevation: 0,
      shadowColor: Colors.black54,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1E293B),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF8B5CF6),
      tertiary: Color(0xFF34D399), // Green for success states
      surface: Color(0xFF1E293B),
      onSurface: Color(0xFFF1F5F9),
      onSurfaceVariant: Color(0xFF94A3B8), // WCAG AA compliant secondary text
      surfaceContainerHighest: Color(0xFF334155),
    ),
  );

  // Custom colors for light/dark mode
  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get cardColor => isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get textPrimary =>
      isDarkMode ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
  Color get textSecondary =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get borderColor =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get shadowColor =>
      isDarkMode ? Colors.black54 : Colors.black.withValues(alpha: 0.03);
}
