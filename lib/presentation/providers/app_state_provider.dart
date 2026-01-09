import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// App state provider
/// Manages global app state like theme mode, locale, etc.
class AppStateProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  int _selectedBottomNavIndex = 0;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  int get selectedBottomNavIndex => _selectedBottomNavIndex;

  /// Toggle theme mode
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  /// Set theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Set selected bottom navigation index
  /// Valid indices: 0=Keşfet, 1=Ara, 2=Bildirimler, 3=Profil
  void setBottomNavIndex(int index) {
    // Ensure index is within valid range (0-3)
    if (index < 0 || index > 3) {
      index = 0;
    }
    _selectedBottomNavIndex = index;
    notifyListeners();
  }
}
