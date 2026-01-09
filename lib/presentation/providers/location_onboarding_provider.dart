import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException, PermissionDeniedException;
import '../../data/models/user_location.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/services/location_service.dart';
import '../../data/services/location_preferences.dart';

/// Onboarding state enum for location onboarding flow
enum OnboardingState {
  initial, // Just started
  checkingLocation, // Checking if location is already set
  requestingGPS, // Requesting GPS permission
  fetchingGPS, // Fetching GPS coordinates
  showingManual, // Showing manual selection
  completed, // Location is set, ready to proceed
  error, // Error occurred
}

/// Provider for managing location onboarding flow
class LocationOnboardingProvider extends ChangeNotifier {
  final LocationService _locationService;
  final LocationRepository _locationRepository;
  final LocationPreferences _locationPreferences;

  OnboardingState _state = OnboardingState.initial;
  String? _errorMessage;
  UserLocation? _selectedLocation;
  bool _hasCheckedInitially = false;

  LocationOnboardingProvider({
    LocationService? locationService,
    LocationRepository? locationRepository,
    LocationPreferences? locationPreferences,
  }) : _locationService = locationService ?? LocationService(),
       _locationRepository = locationRepository ?? LocationRepository(),
       _locationPreferences = locationPreferences ?? LocationPreferences();

  // Getters
  OnboardingState get state => _state;
  String? get errorMessage => _errorMessage;
  UserLocation? get selectedLocation => _selectedLocation;
  bool get isCompleted => _state == OnboardingState.completed;
  bool get needsOnboarding => !isCompleted && _hasCheckedInitially;
  LocationRepository get locationRepository => _locationRepository;

  /// Check if location is already set, if not start onboarding
  Future<void> checkLocationStatus() async {
    if (_hasCheckedInitially && _state == OnboardingState.completed) {
      return; // Already completed, don't check again
    }

    _state = OnboardingState.checkingLocation;
    _errorMessage = null;
    notifyListeners();

    try {
      final location = await _locationPreferences.getLocation();

      if (location != null) {
        _selectedLocation = location;
        _state = OnboardingState.completed;
        _hasCheckedInitially = true;
        notifyListeners();
        return;
      }

      // No location saved, try GPS
      _hasCheckedInitially = true;
      await requestGPSLocation();
    } catch (e) {
      debugPrint('Error checking location status: $e');
      _errorMessage = e.toString();
      _state = OnboardingState.showingManual;
      _hasCheckedInitially = true;
      notifyListeners();
    }
  }

  /// Request GPS location permission and get coordinates
  Future<void> requestGPSLocation() async {
    _state = OnboardingState.requestingGPS;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check current permission status
      LocationPermission permission = await _locationService.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _showManualSelection(
            message:
                'Konum izni reddedildi. Manuel olarak konum seçebilirsiniz.',
          );
          return;
        }
      } else if (permission == LocationPermission.deniedForever) {
        _showManualSelection(
          message:
              'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verebilir veya manuel seçim yapabilirsiniz.',
        );
        return;
      }

      // Permission granted, fetch GPS coordinates
      _state = OnboardingState.fetchingGPS;
      notifyListeners();

      final position = await _locationService.getCurrentPosition();

      if (position == null) {
        _showManualSelection(
          message: 'Konum alınamadı. Manuel olarak konum seçebilirsiniz.',
        );
        return;
      }

      // Get province and district from coordinates
      final locationData = await _locationService
          .extractProvinceAndDistrictFromCoordinates(
            latitude: position.latitude,
            longitude: position.longitude,
          );

      if (locationData == null) {
        _showManualSelection(
          message:
              'Konum bilgisi alınamadı. Manuel olarak konum seçebilirsiniz.',
        );
        return;
      }

      // Try to find matching province and district in database
      final province = await _locationRepository.findProvinceByName(
        locationData['province']!,
      );

      String? districtId;
      if (province != null) {
        final district = await _locationRepository.findDistrictByName(
          province.id,
          locationData['district']!,
        );
        districtId = district?.id;
      }

      // Create and save the user location
      final userLocation = UserLocation(
        provinceName: locationData['province']!,
        districtName: locationData['district']!,
        provinceId: province?.id,
        districtId: districtId,
        latitude: position.latitude,
        longitude: position.longitude,
        isGPSBased: true,
      );

      await _locationPreferences.saveLocation(userLocation);
      _selectedLocation = userLocation;
      _state = OnboardingState.completed;
      notifyListeners();
    } on LocationServiceDisabledException catch (_) {
      _showManualSelection(
        message:
            'Konum servisleri kapalı. Lütfen açın veya manuel seçim yapın.',
      );
    } on PermissionDeniedException catch (e) {
      _showManualSelection(message: e.message);
    } catch (e) {
      debugPrint('Error requesting GPS location: $e');
      _showManualSelection(
        message:
            'Konum alınırken bir hata oluştu. Manuel seçim yapabilirsiniz.',
      );
    }
  }

  /// Show manual location selection
  void _showManualSelection({String? message}) {
    _errorMessage = message;
    _state = OnboardingState.showingManual;
    notifyListeners();
  }

  /// Force show manual selection (called from UI)
  void showManualSelection() {
    _showManualSelection();
  }

  /// Complete manual selection and finish onboarding
  Future<void> completeManualSelection({
    required String provinceName,
    required String districtName,
    int? provinceId,
    String? districtId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final location = UserLocation(
        provinceName: provinceName,
        districtName: districtName,
        provinceId: provinceId,
        districtId: districtId,
        latitude: latitude,
        longitude: longitude,
        isGPSBased: false,
      );

      await _locationPreferences.saveLocation(location);
      _selectedLocation = location;
      _state = OnboardingState.completed;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving manual location: $e');
      _errorMessage = 'Konum kaydedilemedi. Lütfen tekrar deneyin.';
      notifyListeners();
    }
  }

  /// Reset onboarding to start over
  Future<void> reset() async {
    await _locationPreferences.clearLocation();
    _state = OnboardingState.initial;
    _selectedLocation = null;
    _errorMessage = null;
    _hasCheckedInitially = false;
    notifyListeners();
  }

  /// Retry GPS location fetch
  Future<void> retry() async {
    await requestGPSLocation();
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Open app settings for permissions
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Get current saved location (useful for other providers)
  Future<UserLocation?> getSavedLocation() async {
    return await _locationPreferences.getLocation();
  }

  /// Check if location onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    return await _locationPreferences.isOnboardingCompleted();
  }
}
