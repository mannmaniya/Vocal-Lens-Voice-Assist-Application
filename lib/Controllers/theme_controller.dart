import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends ChangeNotifier {
  final _storage = GetStorage();
  final _themeKey = 'isDarkMode';

  bool get isDarkMode => _storage.read(_themeKey) ?? false;

  void toggleTheme() {
    _storage.write(_themeKey, !isDarkMode);
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _storage.write(_themeKey, isDark);
    notifyListeners();
  }
}
