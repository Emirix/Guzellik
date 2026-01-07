import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/venue.dart';
import '../../data/models/venue_filter.dart';
import '../../data/repositories/venue_repository.dart';
import '../../data/services/location_service.dart';

enum DiscoveryViewMode { map, list }

class DiscoveryProvider extends ChangeNotifier {
  final VenueRepository _venueRepository = VenueRepository();
  final LocationService _locationService = LocationService();

  DiscoveryViewMode _viewMode = DiscoveryViewMode.map;
  List<Venue> _venues = [];
  List<Venue> _filteredVenues = [];
  String _searchQuery = '';
  bool _isLoading = false;

  Position? _currentPosition;
  String _currentLocationName = 'Konum belirleniyor...';
  VenueFilter _filter = VenueFilter();

  DiscoveryViewMode get viewMode => _viewMode;
  List<Venue> get venues => _filteredVenues;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String get currentLocationName => _currentLocationName;
  Position? get currentPosition => _currentPosition;
  VenueFilter get filter => _filter;

  DiscoveryProvider() {
    refresh();

    // Ensure the app is ready to show the permission dialog
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await updateLocation();
      await refresh();
    });
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
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      // If location fails, we might still have the default or previous location
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
