import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/venue.dart';
import '../../data/models/venue_filter.dart';
import '../../data/models/user_location.dart';
import '../../data/models/venue_category.dart';
import '../../data/repositories/venue_repository.dart';
import '../../data/repositories/location_repository.dart';
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
  List<VenueCategory> _categories = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingHome = false;
  bool _isLoadingCategories = false;
  bool _isLoadingNearby = false;

  Position? _currentPosition;
  String _currentLocationName = 'Konum belirleniyor...';
  List<Venue> _nearbyVenues = [];
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
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingNearby => _isLoadingNearby;
  List<VenueCategory> get categories => _categories;
  String get currentLocationName => _currentLocationName;
  Position? get currentPosition => _currentPosition;
  List<Venue> get nearbyVenues => _nearbyVenues;
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
    debugPrint('DiscoveryProvider: Starting initialization...');

    // 1. Load saved location from onboarding
    await _loadSavedLocation();
    debugPrint(
      'DiscoveryProvider: Saved location loaded. Position: $_currentPosition',
    );

    // 2. Load categories and home data (featured venues)
    await fetchCategories();
    debugPrint('DiscoveryProvider: Categories loaded: ${_categories.length}');

    await loadHomeData();
    debugPrint(
      'DiscoveryProvider: Featured venues loaded: ${_featuredVenues.length}',
    );

    // 3. Now fetch nearby venues
    await fetchNearbyVenues();
    debugPrint(
      'DiscoveryProvider: Nearby venues loaded: ${_nearbyVenues.length}',
    );

    // 4. Finally load the full list for map/list views
    await _loadVenues(showLoading: false);
    debugPrint(
      'DiscoveryProvider: All venues loaded: ${_venues.length}, filtered: ${_filteredVenues.length}',
    );
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
      _updateAllDistances();
    }
    notifyListeners();
  }

  /// Recalculate distances for all venue lists based on current position
  void _updateAllDistances() {
    if (_currentPosition == null) return;

    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;

    // Helper to update a list of venues
    List<Venue> updateList(List<Venue> list) {
      return list.map((v) {
        final distance = Geolocator.distanceBetween(
          lat,
          lng,
          v.latitude,
          v.longitude,
        );
        return v.copyWith(distance: distance);
      }).toList();
    }

    _venues = updateList(_venues);
    _filteredVenues = updateList(_filteredVenues);
    _featuredVenues = updateList(_featuredVenues);
    _nearbyVenues = updateList(_nearbyVenues);
  }

  Future<void> loadHomeData() async {
    _isLoadingHome = true;
    notifyListeners();

    try {
      // Fetch featured venues from repository with distance calculation if location available
      _featuredVenues = await _venueRepository.getFeaturedVenues(
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
      );

      // Fallback: if search with coordinates returned nothing (e.g. strict filter or far from mock data),
      // try without coordinates to get at least something for the home screen
      if (_featuredVenues.isEmpty && _currentPosition != null) {
        debugPrint(
          'loadHomeData: Search with coords was empty, falling back to all featured',
        );
        _featuredVenues = await _venueRepository.getFeaturedVenues();
      }

      // If position is available but distance is null (e.g. view didn't return it), calculate locally
      if (_currentPosition != null &&
          _featuredVenues.isNotEmpty &&
          _featuredVenues.first.distance == null) {
        _updateAllDistances();
      }
    } catch (e) {
      debugPrint('Error loading home data: $e');
      // If it failed and we have no data, try the simple path as ultimate fallback
      if (_featuredVenues.isEmpty) {
        try {
          _featuredVenues = await _venueRepository.getFeaturedVenues();
        } catch (innerE) {
          debugPrint('Ultimate fallback for featured venues failed: $innerE');
        }
      }
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _venueRepository.getVenueCategories();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchNearbyVenues() async {
    _isLoadingNearby = true;
    notifyListeners();

    try {
      // 1. Try search (based on location if available)
      _nearbyVenues = await _venueRepository.searchVenues(
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
      );

      // 2. Fallback: if search returns nothing, fetch all venues
      if (_nearbyVenues.isEmpty) {
        debugPrint('Nearby search returned empty, falling back to all venues');
        _nearbyVenues = await _venueRepository.getVenues();
      }

      // 3. Ultimate fallback: if both are empty, use featured venues (might still be empty)
      if (_nearbyVenues.isEmpty) {
        debugPrint(
          'Both nearby and all_venues were empty, using featured venues',
        );
        _nearbyVenues = List.from(_featuredVenues);
      }

      // Final check: if still empty, get everything from repository directly
      if (_nearbyVenues.isEmpty) {
        _nearbyVenues = await _venueRepository.getVenues();
      }

      // Final count limit
      if (_nearbyVenues.length > 10) {
        _nearbyVenues = _nearbyVenues.take(10).toList();
      }
    } catch (e) {
      debugPrint('Error fetching nearby venues: $e');
      // Final fallback on error: try to use whatever we have
      if (_nearbyVenues.isEmpty) {
        if (_featuredVenues.isNotEmpty) {
          _nearbyVenues = List.from(_featuredVenues);
        } else {
          // One last attempt
          try {
            _nearbyVenues = await _venueRepository.getVenues();
          } catch (_) {}
        }
      }
    } finally {
      _isLoadingNearby = false;
      notifyListeners();
    }
  }

  void setViewMode(DiscoveryViewMode mode) {
    _viewMode = mode;
    notifyListeners();

    // If switching to map or list and venues are empty, trigger a load
    if ((mode == DiscoveryViewMode.map || mode == DiscoveryViewMode.list) &&
        _venues.isEmpty) {
      _loadVenues(showLoading: true);
    }
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
        _updateAllDistances();

        // Extract province and district from coordinates (ilçe, not mahalle)
        final locationData = await _locationService
            .extractProvinceAndDistrictFromCoordinates(
              latitude: position.latitude,
              longitude: position.longitude,
            )
            .timeout(const Duration(seconds: 5));

        if (locationData != null) {
          final provinceName = locationData['province']!;
          final districtName = locationData['district']!;

          _manualCity = provinceName;
          _manualDistrict = districtName;
          _currentLocationName = '$districtName, $provinceName';

          // Try to find district ID from database
          final repository = LocationRepository();
          final province = await repository.findProvinceByName(provinceName);
          String? districtId;

          if (province != null) {
            final district = await repository.findDistrictByName(
              province.id,
              districtName,
            );
            districtId = district?.id;
          }

          // Save location to preferences for persistence
          final userLocation = UserLocation(
            provinceName: provinceName,
            districtName: districtName,
            provinceId: province?.id,
            districtId: districtId,
            latitude: position.latitude,
            longitude: position.longitude,
            isGPSBased: true,
          );
          await _locationPreferences.saveLocation(userLocation);
        } else {
          // Fallback to old address method if extraction fails
          final address = await _locationService
              .getAddressFromCoordinates(
                latitude: position.latitude,
                longitude: position.longitude,
              )
              .timeout(const Duration(seconds: 5));

          if (address != null) {
            _currentLocationName = _shortenAddress(address);
          }
          _manualCity = null;
          _manualDistrict = null;
        }

        // Clear manual location flag when GPS is used
        _isUsingManualLocation = false;
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      // If location fails, we might still have the default or previous location
    } finally {
      // Always ensure loading is set to false
      _isLoading = false;
      notifyListeners();
      await fetchNearbyVenues(); // Refresh nearby venues after GPS update
      await loadHomeData(); // Refresh featured with new distance
      await refresh(); // Refresh main list/map with new location
    }
  }

  Future<void> updateManualLocation({
    required String city,
    required String district,
    int? provinceId,
    String? districtId,
    double? latitude,
    double? longitude,
  }) async {
    _manualCity = city;
    _manualDistrict = district;
    _isUsingManualLocation = true;
    _currentLocationName = '$district, $city';

    if (latitude != null && longitude != null) {
      _currentPosition = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      _updateAllDistances();
    }

    // Save to preferences for persistence
    try {
      final userLocation = UserLocation(
        provinceName: city,
        districtName: district,
        provinceId: provinceId,
        districtId: districtId,
        latitude: latitude,
        longitude: longitude,
        isGPSBased: false,
      );
      await _locationPreferences.saveLocation(userLocation);
    } catch (e) {
      debugPrint('Error saving manual location: $e');
    }

    notifyListeners();
    await refresh();
    await loadHomeData(); // Refresh featured
    await fetchNearbyVenues(); // Refresh nearby venues for the manual location
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
    debugPrint('_loadVenues: Starting... showLoading=$showLoading');

    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      debugPrint(
        '_loadVenues: Calling searchVenues with lat=${_currentPosition?.latitude}, lng=${_currentPosition?.longitude}',
      );

      _venues = await _venueRepository.searchVenues(
        query: _searchQuery,
        filter: _filter,
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
      );

      debugPrint('_loadVenues: searchVenues returned ${_venues.length} venues');

      // Fallback: if search returns nothing and it's a default state (no query, no specific filters)
      // fetch all venues to show something on home screen
      if (_venues.isEmpty &&
          _searchQuery.isEmpty &&
          (_filter.categories.isEmpty)) {
        debugPrint(
          '_loadVenues: Search returned empty, falling back to getVenues()',
        );
        _venues = await _venueRepository.getVenues();
        debugPrint(
          '_loadVenues: getVenues() returned ${_venues.length} venues',
        );
      }

      // Ultimate fallback: use nearby or featured venues
      if (_venues.isEmpty) {
        debugPrint(
          '_loadVenues: Still empty, using nearby/featured as fallback',
        );
        if (_nearbyVenues.isNotEmpty) {
          _venues = List.from(_nearbyVenues);
        } else if (_featuredVenues.isNotEmpty) {
          _venues = List.from(_featuredVenues);
        }
        debugPrint('_loadVenues: After fallback: ${_venues.length} venues');
      }

      _filteredVenues = List.from(_venues);
      _updateAllDistances();
    } catch (e, stackTrace) {
      debugPrint('Error loading venues: $e');
      debugPrint('Stack trace: $stackTrace');

      // On error, try to use existing data
      if (_venues.isEmpty && _nearbyVenues.isNotEmpty) {
        _venues = List.from(_nearbyVenues);
        _filteredVenues = List.from(_venues);
      }
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

  // ==================== Mekan Takip İşlemleri ====================

  /// Mekanı takip eder veya takibi bırakır
  Future<void> toggleFollowVenue(Venue venue) async {
    final isFollowing = venue.isFollowing;
    final newFollowerCount = isFollowing
        ? (venue.followerCount > 0 ? venue.followerCount - 1 : 0)
        : venue.followerCount + 1;

    final updatedVenue = venue.copyWith(
      isFollowing: !isFollowing,
      followerCount: newFollowerCount,
    );

    // Update all lists that might contain this venue
    void updateList(List<Venue> list) {
      final index = list.indexWhere((v) => v.id == venue.id);
      if (index != -1) {
        list[index] = updatedVenue;
      }
    }

    updateList(_venues);
    updateList(_filteredVenues);
    updateList(_featuredVenues);
    updateList(_nearbyVenues);
    notifyListeners();

    try {
      if (isFollowing) {
        await _venueRepository.unfollowVenue(venue.id);
      } else {
        await _venueRepository.followVenue(venue.id);
      }
    } catch (e) {
      debugPrint('Error toggling follow in Discovery: $e');
      // Revert states
      void revertList(List<Venue> list) {
        final index = list.indexWhere((v) => v.id == venue.id);
        if (index != -1) {
          list[index] = venue;
        }
      }

      revertList(_venues);
      revertList(_filteredVenues);
      revertList(_featuredVenues);
      revertList(_nearbyVenues);
      notifyListeners();
      rethrow;
    }
  }

  /// Mekanı favorilere ekler veya favorilerden çıkarır
  Future<void> toggleFavoriteVenue(Venue venue) async {
    final isFavorited = venue.isFavorited;
    final updatedVenue = venue.copyWith(isFavorited: !isFavorited);

    // Update all lists that might contain this venue
    void updateList(List<Venue> list) {
      final index = list.indexWhere((v) => v.id == venue.id);
      if (index != -1) {
        list[index] = updatedVenue;
      }
    }

    updateList(_venues);
    updateList(_filteredVenues);
    updateList(_featuredVenues);
    updateList(_nearbyVenues);
    notifyListeners();

    try {
      if (isFavorited) {
        await _venueRepository.removeFavorite(venue.id);
      } else {
        await _venueRepository.addFavorite(venue.id);
      }
    } catch (e) {
      debugPrint('Error toggling favorite in Discovery: $e');
      // Revert states
      void revertList(List<Venue> list) {
        final index = list.indexWhere((v) => v.id == venue.id);
        if (index != -1) {
          list[index] = venue;
        }
      }

      revertList(_venues);
      revertList(_filteredVenues);
      revertList(_featuredVenues);
      revertList(_nearbyVenues);
      notifyListeners();
      rethrow;
    }
  }
}
