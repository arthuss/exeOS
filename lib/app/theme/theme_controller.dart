import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }
}
