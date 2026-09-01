import 'package:flutter/material.dart';

/// v2 design tokens: soft & rounded, evolving Zenu's existing palette
/// (indigo brand, Tailwind-family need colors) so the redesign still
/// reads as Zenu.
class ZenuColors {
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFF8B5CF6);

  static const water = Color(0xFF06B6D4);
  static const eyeRest = Color(0xFF3B82F6);
  static const move = Color(0xFF10B981);
  static const stretch = Color(0xFF8B5CF6);
  static const strength = Color(0xFFF97316);

  static const sparks = Color(0xFFF5B93E);

  static Color forKind(String kind) => switch (kind) {
        'water' => water,
        'eyeRest' => eyeRest,
        'move' => move,
        'stretch' => stretch,
        'strength' => strength,
        _ => primary,
      };

  static IconData iconForKind(String kind) => switch (kind) {
        'water' => Icons.water_drop_outlined,
        'eyeRest' => Icons.remove_red_eye_outlined,
        'move' => Icons.directions_walk,
        'stretch' => Icons.self_improvement,
        'strength' => Icons.fitness_center,
        _ => Icons.favorite_outline,
      };
}

class ZenuTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: ZenuColors.primary,
      brightness: brightness,
      surface: isDark ? const Color(0xFF16211E) : const Color(0xFFF4F8F6),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF101915) : const Color(0xFFF2F6F4),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF1C2925) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
