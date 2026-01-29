import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light; // Default to light mode

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  // Load saved theme preference
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Save and set theme mode
  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    notifyListeners();
  }

  // Toggle between light and dark
  Future<void> toggle() async {
    if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.light;
    } else {
      _mode = ThemeMode.dark;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _mode == ThemeMode.dark);
    notifyListeners();
  }
}
