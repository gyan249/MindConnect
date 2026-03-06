import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Load saved theme from SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('themeMode') ?? 'system';
    _themeMode = _stringToThemeMode(value);
    notifyListeners();
  }

  /// Update theme **and** persist it.
  Future<void> setThemeMode(String modeName) async {
    _themeMode = _stringToThemeMode(modeName);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', modeName);

    notifyListeners();
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

// Global instance used in main.dart and settings_screen.dart
final ThemeController themeController = ThemeController();
