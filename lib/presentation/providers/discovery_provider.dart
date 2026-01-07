import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/venue.dart';
import '../../data/models/venue_filter.dart';
import '../../data/repositories/venue_repository.dart';
import '../../data/services/location_service.dart';

enum DiscoveryViewMode { home, map, list }

class DiscoveryProvider extends ChangeNotifier {
  final VenueRepository _venueRepository = VenueRepository();
  final LocationService _locationService = LocationService();

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

  DiscoveryProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadHomeData();
    await refresh();

    // Ensure the app is ready to show the permission dialog
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await updateLocation();
      await refresh();
    });
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
    notifyListeners();
  }

  Future<void> updateLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        _currentPosition = position;
        final address = await _locationService.getAddressFromCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        );
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
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateManualLocation(String city, String district) {
    _manualCity = city;
    _manualDistrict = district;
    _isUsingManualLocation = true;
    _currentLocationName = '$district, $city';
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
    _viewMode = _viewMode == DiscoveryViewMode.map
        ? DiscoveryViewMode.list
        : DiscoveryViewMode.map;
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

  Future<void> _loadVenues() async {
    _isLoading = true;
    notifyListeners();

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
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadVenues();
  }
}
