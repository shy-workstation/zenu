import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _key = 'zenu.v2.themeMode';

  final SharedPreferences _prefs;
  ThemeMode _mode;

  ThemeController(this._prefs)
      : _mode = switch (_prefs.getString(_key)) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        };

  ThemeMode get mode => _mode;

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await _prefs.setString(_key, mode.name);
  }
}
