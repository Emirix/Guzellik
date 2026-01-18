import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing onboarding state persistence
/// Uses SharedPreferences to track whether user has seen onboarding
class OnboardingPreferences {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  /// Check if user has already seen the onboarding
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  /// Reset onboarding state (for debugging/testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasSeenOnboarding);
  }
}
