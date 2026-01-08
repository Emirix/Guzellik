import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/venue.dart';
import '../../data/models/venue_filter.dart';
import '../../data/models/user_location.dart';
import '../../data/repositories/venue_repository.dart';
import '../../data/services/location_service.dart';
import '../../data/services/location_preferences.dart';

enum DiscoveryViewMode { home, map, list }

class DiscoveryProvider extends ChangeNotifier {
  final VenueRepository _venueRepository = VenueRepository();
  final LocationService _locationService = LocationService();
  final LocationPreferences _locationPreferences = LocationPreferences();

  DiscoveryViewMode _viewMode = DiscoveryViewMode.home;
  List<Venue> _venues = [];
  List<Venue> _filteredVenues = [];
  List<Venue> _featuredVenues = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingHome = false;

  Position? _currentPosition;
  String _currentLocationName = 'Konum belirleniyor...';
  VenueFilter _filter = VenueFilter();

  // Manual location state
  String? _manualCity;
  String? _manualDistrict;
  bool _isUsingManualLocation = false;

  // Map view state
  bool _isMapCarouselVisible = true;

  DiscoveryViewMode get viewMode => _viewMode;
  List<Venue> get venues => _filteredVenues;
  List<Venue> get featuredVenues => _featuredVenues;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingHome => _isLoadingHome;
  String get currentLocationName => _currentLocationName;
  Position? get currentPosition => _currentPosition;
  VenueFilter get filter => _filter;
  bool get isUsingManualLocation => _isUsingManualLocation;
  String? get manualCity => _manualCity;
  String? get manualDistrict => _manualDistrict;
  bool get isMapCarouselVisible => _isMapCarouselVisible;

  void toggleMapCarousel() {
    _isMapCarouselVisible = !_isMapCarouselVisible;
    notifyListeners();
  }

  DiscoveryProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    // First, check if we have a saved location from onboarding
    await _loadSavedLocation();

    // Load home data and venues in parallel (without showing loading indicator)
    await Future.wait([loadHomeData(), _loadVenues(showLoading: false)]);
  }

  /// Load saved location from LocationPreferences
  Future<void> _loadSavedLocation() async {
    try {
      final savedLocation = await _locationPreferences.getLocation();
      if (savedLocation != null) {
        _applyUserLocation(savedLocation);
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  /// Apply UserLocation to provider state
  void _applyUserLocation(UserLocation location) {
    _currentLocationName = location.formattedLocation;
    _manualCity = location.provinceName;
    _manualDistrict = location.districtName;
    _isUsingManualLocation = !location.isGPSBased;

    if (location.hasCoordinates) {
      _currentPosition = Position(
        latitude: location.latitude!,
        longitude: location.longitude!,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    notifyListeners();
  }

  Future<void> loadHomeData() async {
    _isLoadingHome = true;
    notifyListeners();

    try {
      // Fetch featured venues from repository
      _featuredVenues = await _venueRepository.getFeaturedVenues();
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  void setViewMode(DiscoveryViewMode mode) {
    _viewMode = mode;
    // Don't set isLoading when just changing view mode
    // This prevents showing loading indicator when switching between map/list
    notifyListeners();
  }

  Future<void> updateLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Add timeout to prevent infinite loading
      final position = await _locationService.getCurrentPosition().timeout(
        const Duration(seconds: 10),
      );

      if (position != null) {
        _currentPosition = position;
        final address = await _locationService
            .getAddressFromCoordinates(
              latitude: position.latitude,
              longitude: position.longitude,
            )
            .timeout(const Duration(seconds: 5));

        if (address != null) {
          _currentLocationName = _shortenAddress(address);
        }
        // Clear manual location when GPS is used
        _isUsingManualLocation = false;
        _manualCity = null;
        _manualDistrict = null;
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      // If location fails, we might still have the default or previous location
    } finally {
      // Always ensure loading is set to false
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateManualLocation(String city, String district) async {
    _manualCity = city;
    _manualDistrict = district;
    _isUsingManualLocation = true;
    _currentLocationName = '$district, $city';

    // Save to preferences for persistence
    try {
      final userLocation = UserLocation(
        provinceName: city,
        districtName: district,
        isGPSBased: false,
      );
      await _locationPreferences.saveLocation(userLocation);
    } catch (e) {
      debugPrint('Error saving manual location: $e');
    }

    notifyListeners();
    refresh();
  }

  String _shortenAddress(String address) {
    final parts = address
        .split(', ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return address;

    // Tekrar eden isimleri (Örn: İstanbul, İstanbul) engellemek için Set kullanalım
    final seen = <String>{};
    final uniqueParts = <String>[];
    for (var part in parts) {
      if (seen.add(part.toLowerCase())) {
        uniqueParts.add(part);
      }
    }

    if (uniqueParts.length >= 2) {
      // Genellikle "İlçe, İl" formatını döndürür
      return '${uniqueParts[uniqueParts.length - 2]}, ${uniqueParts.last}';
    }
    return uniqueParts.last;
  }

  void toggleViewMode() {
    // Toggle between map and list only (never go back to home)
    if (_viewMode == DiscoveryViewMode.map) {
      _viewMode = DiscoveryViewMode.list;
    } else {
      _viewMode = DiscoveryViewMode.map;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    refresh();
  }

  void updateFilter(VenueFilter newFilter) {
    _filter = newFilter;
    refresh();
  }

  void resetFilters() {
    _filter = VenueFilter();
    refresh();
  }

  Future<void> _loadVenues({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _venues = await _venueRepository.searchVenues(
        query: _searchQuery,
        filter: _filter,
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
      );
      _filteredVenues = List.from(_venues);
    } catch (e) {
      debugPrint('Error loading venues: $e');
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadVenues();
  }
}
