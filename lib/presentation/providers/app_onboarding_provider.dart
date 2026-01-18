import 'package:flutter/material.dart';
import '../../data/services/onboarding_preferences.dart';

/// Provider for managing app onboarding flow state
/// Handles page navigation and completion tracking
class AppOnboardingProvider extends ChangeNotifier {
  final OnboardingPreferences _preferences;

  AppOnboardingProvider(this._preferences);

  // State
  int _currentPage = 0;
  static const int totalPages = 6;

  // Getters
  int get currentPage => _currentPage;
  bool get isLastPage => _currentPage == totalPages - 1;
  bool get isFirstPage => _currentPage == 0;

  /// Navigate to next page
  void nextPage() {
    if (_currentPage < totalPages - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  /// Navigate to previous page
  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  /// Jump to specific page
  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  /// Skip to last page
  void skipToEnd() {
    _currentPage = totalPages - 1;
    notifyListeners();
  }

  /// Complete onboarding and save to preferences
  Future<void> completeOnboarding() async {
    await _preferences.markOnboardingComplete();
  }

  /// Reset to first page (for testing)
  void reset() {
    _currentPage = 0;
    notifyListeners();
  }
}
