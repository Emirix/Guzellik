import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_location.dart';

/// Service for persisting user location to SharedPreferences
class LocationPreferences {
  static const String _locationKey = 'user_location';
  static const String _onboardingCompletedKey = 'location_onboarding_completed';

  SharedPreferences? _prefs;

  /// Get SharedPreferences instance (lazy initialization)
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save user location to SharedPreferences
  Future<void> saveLocation(UserLocation location) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(location.toJson());
    await prefs.setString(_locationKey, jsonString);
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  /// Get saved user location from SharedPreferences
  /// Returns null if no location is saved
  Future<UserLocation?> getLocation() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_locationKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserLocation.fromJson(json);
    } catch (e) {
      // If parsing fails, clear the corrupted data
      await clearLocation();
      return null;
    }
  }

  /// Check if a location has been saved
  Future<bool> isLocationSet() async {
    final prefs = await _getPrefs();
    return prefs.containsKey(_locationKey) &&
        prefs.getString(_locationKey)?.isNotEmpty == true;
  }

  /// Check if location onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Clear saved location from SharedPreferences
  Future<void> clearLocation() async {
    final prefs = await _getPrefs();
    await prefs.remove(_locationKey);
    await prefs.remove(_onboardingCompletedKey);
  }

  /// Update only the coordinates of the saved location
  Future<void> updateCoordinates(double latitude, double longitude) async {
    final currentLocation = await getLocation();
    if (currentLocation != null) {
      final updatedLocation = currentLocation.copyWith(
        latitude: latitude,
        longitude: longitude,
      );
      await saveLocation(updatedLocation);
    }
  }
}
