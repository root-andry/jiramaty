import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    if (_prefs != null) {
      final value = _prefs!.getString(_themeKey);
      if (value != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == value,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    if (_prefs != null) {
      await _prefs!.setString(_themeKey, mode.toString());
    }
    notifyListeners();
  }
}
