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
  bool _isLoadingMoreNearby = false;
  int _nearbyOffset = 0;
  bool _hasMoreNearby = true;
  static const int _nearbyPageSize = 10;

  bool _isLoadingMoreFeatured = false;
  int _featuredOffset = 0;
  bool _hasMoreFeatured = true;
  static const int _featuredPageSize = 10;

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

  // Location error state
  String? _locationError;

  DiscoveryViewMode get viewMode => _viewMode;
  List<Venue> get venues => _filteredVenues;
  List<Venue> get featuredVenues => _featuredVenues;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingHome => _isLoadingHome;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingNearby => _isLoadingNearby;
  bool get isLoadingMoreNearby => _isLoadingMoreNearby;
  bool get hasMoreNearby => _hasMoreNearby;
  bool get isLoadingMoreFeatured => _isLoadingMoreFeatured;
  bool get hasMoreFeatured => _hasMoreFeatured;
  List<VenueCategory> get categories => _categories;
  String get currentLocationName => _currentLocationName;
  Position? get currentPosition => _currentPosition;
  List<Venue> get nearbyVenues => _nearbyVenues;
  VenueFilter get filter => _filter;
  bool get isUsingManualLocation => _isUsingManualLocation;
  String? get manualCity => _manualCity;
  String? get manualDistrict => _manualDistrict;
  bool get isMapCarouselVisible => _isMapCarouselVisible;
  String? get locationError => _locationError;
  bool get hasLocationError => _locationError != null;

  /// Clear location error after it's been shown
  void clearLocationError() {
    _locationError = null;
    notifyListeners();
  }

  void toggleMapCarousel() {
    _isMapCarouselVisible = !_isMapCarouselVisible;
    notifyListeners();
  }

  DiscoveryProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    debugPrint('DiscoveryProvider: Starting initialization...');

    // 1. Load saved location FIRST (needed for distance calculations)
    await _loadSavedLocation();
    debugPrint(
      'DiscoveryProvider: Saved location loaded. Position: $_currentPosition',
    );

    // 2. PARALLEL LOADING: Load categories, featured, and nearby venues concurrently
    // This significantly reduces startup time
    await Future.wait([
      _fetchCategoriesInternal(),
      _loadHomeDataInternal(),
      _fetchNearbyVenuesInternal(),
    ], eagerError: false);

    debugPrint(
      'DiscoveryProvider: Parallel loading complete - '
      'Categories: ${_categories.length}, '
      'Featured: ${_featuredVenues.length}, '
      'Nearby: ${_nearbyVenues.length}',
    );

    // Single notifyListeners after all parallel loads complete
    notifyListeners();

    // 3. Load full venue list in background (for map/list views)
    // Don't await - let this happen in background
    _loadVenues(showLoading: false);
  }

  /// Internal category fetch without notifyListeners
  Future<void> _fetchCategoriesInternal() async {
    _isLoadingCategories = true;
    try {
      _categories = await _venueRepository.getVenueCategories();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoadingCategories = false;
    }
  }

  /// Internal home data load without notifyListeners
  Future<void> _loadHomeDataInternal() async {
    _isLoadingHome = true;
    _featuredOffset = 0;
    _hasMoreFeatured = true;
    try {
      _featuredVenues = await _venueRepository.getFeaturedVenues(
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
        limit: _featuredPageSize,
        offset: _featuredOffset,
      );

      if (_featuredVenues.isEmpty && _currentPosition != null) {
        _featuredVenues = await _venueRepository.getFeaturedVenues(
          limit: _featuredPageSize,
          offset: _featuredOffset,
        );
      }

      _hasMoreFeatured = _featuredVenues.length >= _featuredPageSize;
      _featuredOffset += _featuredVenues.length;

      if (_currentPosition != null &&
          _featuredVenues.isNotEmpty &&
          _featuredVenues.first.distance == null) {
        _updateAllDistances();
      }
    } catch (e) {
      debugPrint('Error loading home data: $e');
      if (_featuredVenues.isEmpty) {
        try {
          _featuredVenues = await _venueRepository.getFeaturedVenues();
        } catch (_) {}
      }
    } finally {
      _isLoadingHome = false;
    }
  }

  /// Internal nearby venues fetch without notifyListeners
  Future<void> _fetchNearbyVenuesInternal() async {
    _isLoadingNearby = true;
    try {
      _nearbyOffset = 0;
      _hasMoreNearby = true;
      _nearbyVenues = await _venueRepository.getVenuesNearby(
        _currentPosition?.latitude ?? 0,
        _currentPosition?.longitude ?? 0,
        50000, // 50km radius
        limit: _nearbyPageSize,
        offset: _nearbyOffset,
      );

      if (_nearbyVenues.isEmpty) {
        // Fallback to search if nearby is empty (might happen in areas with no shops)
        _nearbyVenues = await _venueRepository.searchVenues(
          lat: _currentPosition?.latitude,
          lng: _currentPosition?.longitude,
          limit: _nearbyPageSize,
        );
      }

      // Note: Removed getVenues() fallback to enforce subscription filtering

      _hasMoreNearby = _nearbyVenues.length >= _nearbyPageSize;
      _nearbyOffset += _nearbyVenues.length;
    } catch (e) {
      debugPrint('Error fetching nearby venues: $e');
    } finally {
      _isLoadingNearby = false;
    }
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
    _featuredOffset = 0;
    _hasMoreFeatured = true;
    notifyListeners();

    try {
      // Fetch featured venues from repository with distance calculation if location available
      _featuredVenues = await _venueRepository.getFeaturedVenues(
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
        limit: _featuredPageSize,
        offset: _featuredOffset,
      );

      // Fallback: if search with coordinates returned nothing (e.g. strict filter or far from mock data),
      // try without coordinates to get at least something for the home screen
      if (_featuredVenues.isEmpty && _currentPosition != null) {
        debugPrint(
          'loadHomeData: Search with coords was empty, falling back to all featured',
        );
        _featuredVenues = await _venueRepository.getFeaturedVenues(
          limit: _featuredPageSize,
          offset: _featuredOffset,
        );
      }

      _hasMoreFeatured = _featuredVenues.length >= _featuredPageSize;
      _featuredOffset = _featuredVenues.length;

      // If position is available but distance is null (e.g. view didn't return it), calculate locally
      if (_currentPosition != null &&
          _featuredVenues.isNotEmpty &&
          (_featuredVenues.first.distance == null ||
              _featuredVenues.first.distance == 0)) {
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

  Future<void> loadMoreFeaturedVenues() async {
    if (_isLoadingMoreFeatured || !_hasMoreFeatured) return;

    _isLoadingMoreFeatured = true;
    notifyListeners();

    try {
      final newVenues = await _venueRepository.getFeaturedVenues(
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
        limit: _featuredPageSize,
        offset: _featuredOffset,
      );

      if (newVenues.isEmpty) {
        _hasMoreFeatured = false;
      } else {
        // Update distances locally if we have current position
        List<Venue> processedVenues = newVenues;
        if (_currentPosition != null) {
          final lat = _currentPosition!.latitude;
          final lng = _currentPosition!.longitude;
          processedVenues = newVenues.map((v) {
            final distance = Geolocator.distanceBetween(
              lat,
              lng,
              v.latitude,
              v.longitude,
            );
            return v.copyWith(distance: distance);
          }).toList();
        }

        // Remove duplicates
        final existingIds = _featuredVenues.map((v) => v.id).toSet();
        final uniqueNewVenues = processedVenues
            .where((v) => !existingIds.contains(v.id))
            .toList();

        _featuredVenues.addAll(uniqueNewVenues);
        _featuredOffset += newVenues.length;
        _hasMoreFeatured = newVenues.length >= _featuredPageSize;
      }
    } catch (e) {
      debugPrint('Error loading more featured venues: $e');
    } finally {
      _isLoadingMoreFeatured = false;
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

    _nearbyOffset = 0;
    _hasMoreNearby = true;

    try {
      _nearbyVenues = await _venueRepository.getVenuesNearby(
        _currentPosition?.latitude ?? 0,
        _currentPosition?.longitude ?? 0,
        50000,
        limit: _nearbyPageSize,
        offset: _nearbyOffset,
      );

      if (_nearbyVenues.isEmpty) {
        _nearbyVenues = await _venueRepository.searchVenues(
          lat: _currentPosition?.latitude,
          lng: _currentPosition?.longitude,
          limit: _nearbyPageSize,
        );
      }

      // Note: Removed getVenues() fallbacks to enforce subscription filtering
      // If no subscribed venues found, show empty list

      _hasMoreNearby = _nearbyVenues.length >= _nearbyPageSize;
      _nearbyOffset = _nearbyVenues.length;
    } catch (e) {
      debugPrint('Error fetching nearby venues: $e');
      // Note: Removed getVenues() fallback to enforce subscription filtering
    } finally {
      _isLoadingNearby = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNearbyVenues() async {
    if (_isLoadingMoreNearby || !_hasMoreNearby) return;

    _isLoadingMoreNearby = true;
    notifyListeners();

    try {
      final newVenues = await _venueRepository.getVenuesNearby(
        _currentPosition?.latitude ?? 0,
        _currentPosition?.longitude ?? 0,
        50000,
        limit: _nearbyPageSize,
        offset: _nearbyOffset,
      );

      if (newVenues.isEmpty) {
        _hasMoreNearby = false;
      } else {
        // Update distances locally if we have current position
        List<Venue> processedVenues = newVenues;
        if (_currentPosition != null) {
          final lat = _currentPosition!.latitude;
          final lng = _currentPosition!.longitude;
          processedVenues = newVenues.map((v) {
            final distance = Geolocator.distanceBetween(
              lat,
              lng,
              v.latitude,
              v.longitude,
            );
            return v.copyWith(distance: distance);
          }).toList();
        }

        // Remove duplicates if any (though offset should handle it)
        final existingIds = _nearbyVenues.map((v) => v.id).toSet();
        final uniqueNewVenues = processedVenues
            .where((v) => !existingIds.contains(v.id))
            .toList();

        _nearbyVenues.addAll(uniqueNewVenues);
        _nearbyOffset += newVenues.length;
        _hasMoreNearby = newVenues.length >= _nearbyPageSize;
      }
    } catch (e) {
      debugPrint('Error loading more nearby venues: $e');
    } finally {
      _isLoadingMoreNearby = false;
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
      // Set location error message for UI to display
      if (e.toString().contains('denied') ||
          e.toString().contains('permission')) {
        _locationError = 'Konum izni verilmedi. Lütfen konum ayarlarını açın.';
        _currentLocationName = 'Konum alınamadı';
      } else if (e.toString().contains('disabled') ||
          e.toString().contains('service')) {
        _locationError = 'Konum servisi kapalı. Lütfen konumu açın.';
        _currentLocationName = 'Konum kapalı';
      } else if (e.toString().contains('TimeoutException')) {
        _locationError = 'Konum alınamadı. Lütfen tekrar deneyin.';
        _currentLocationName = 'Konum zaman aşımı';
      } else {
        _locationError =
            'Konum alınamadı. Lütfen konum ayarlarınızı kontrol edin.';
        _currentLocationName = 'Konum alınamadı';
      }
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
    String district = '',
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

      // Note: Removed getVenues() fallback to enforce subscription filtering
      // If search returns empty, show empty list
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
