import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static ThemeService? _instance;
  SharedPreferences? _prefs;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

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
    _isDarkMode = _prefs?.getBool(_themeKey) ?? false;
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool(_themeKey, _isDarkMode);
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
      surface: Colors.white,
      onSurface: Color(0xFF1E293B),
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
      surface: Color(0xFF1E293B),
      onSurface: Color(0xFFF1F5F9),
      surfaceContainerHighest: Color(0xFF334155),
    ),
  );

  // Custom colors for light/dark mode
  Color get backgroundColor =>
      _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get cardColor => _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get textPrimary =>
      _isDarkMode ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
  Color get textSecondary =>
      _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get borderColor =>
      _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get shadowColor =>
      _isDarkMode ? Colors.black54 : Colors.black.withValues(alpha: 0.03);
}
