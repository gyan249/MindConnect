import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  String currentLanguage = 'en'; // 'en' or 'hi'

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    currentLanguage = prefs.getString('preferredLanguage') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (lang == currentLanguage) return;

    final prefs = await SharedPreferences.getInstance();
    currentLanguage = lang;
    await prefs.setString('preferredLanguage', lang);
    notifyListeners();
  }
}

// Global instance – like themeController
final LanguageController languageController = LanguageController();
