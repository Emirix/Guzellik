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
  void setBottomNavIndex(int index) {
    _selectedBottomNavIndex = index;
    notifyListeners();
  }
}
