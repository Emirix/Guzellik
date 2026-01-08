import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/recent_search.dart';
import '../../data/models/search_filter.dart';
import '../../data/models/venue.dart';
import '../../data/models/venue_filter.dart';
import '../../data/repositories/venue_repository.dart';

/// Arama ekranı state yönetimi
class SearchProvider extends ChangeNotifier {
  final VenueRepository _venueRepository;

  // Arama durumu
  String _searchQuery = '';
  bool _isLoading = false;
  List<Venue> _searchResults = [];
  String? _errorMessage;
  bool _hasSearched = false;

  // Filtreler
  SearchFilter _filter = SearchFilter.empty();

  // Son aramalar (local)
  List<RecentSearch> _recentSearches = [];

  // Popüler hizmetler
  List<PopularService> _popularServices = [];
  bool _isLoadingServices = false;

  // Önerilen mekanlar
  List<Venue> _suggestedVenues = [];
  bool _isLoadingSuggestions = false;

  // Konum
  String? _selectedProvince;
  String? _selectedDistrict;
  double? _userLatitude;
  double? _userLongitude;

  // Constants
  static const String _recentSearchesKey = 'recent_searches';
  static const String _lastFilterKey = 'last_search_filter';
  static const int _maxRecentSearches = 10;

  SearchProvider({required VenueRepository venueRepository})
    : _venueRepository = venueRepository {
    _loadRecentSearches();
    _loadLastFilter();
    _loadPopularServices();
    _loadSuggestedVenues();
  }

  // Getters
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  List<Venue> get searchResults => _searchResults;
  String? get errorMessage => _errorMessage;
  bool get hasSearched => _hasSearched;
  SearchFilter get filter => _filter;
  List<RecentSearch> get recentSearches => _recentSearches;
  List<PopularService> get popularServices => _popularServices;
  bool get isLoadingServices => _isLoadingServices;
  String? get selectedProvince => _selectedProvince;
  String? get selectedDistrict => _selectedDistrict;
  double? get userLatitude => _userLatitude;
  double? get userLongitude => _userLongitude;
  List<Venue> get suggestedVenues => _suggestedVenues;
  bool get isLoadingSuggestions => _isLoadingSuggestions;

  bool get hasActiveFilters => _filter.hasActiveFilters;
  int get activeFilterCount => _filter.activeFilterCount;

  /// Arama durumunu kontrol eder
  bool get showEmptyState =>
      !_hasSearched && _searchQuery.isEmpty && _searchResults.isEmpty;

  /// Sonuç bulunamadı durumunu kontrol eder
  bool get showNoResults =>
      _hasSearched && _searchResults.isEmpty && !_isLoading;

  // ==================== Arama İşlemleri ====================

  Timer? _debounceTimer;

  /// Arama sorgusunu günceller (debounced)
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();

    _debounceTimer?.cancel();
    if (query.isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        search();
      });
    } else {
      _hasSearched = false;
      _searchResults = [];
      notifyListeners();
    }
  }

  /// Arama yapar
  Future<void> search() async {
    if (_searchQuery.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert SearchFilter to VenueFilter for repository call
      final venueFilter = VenueFilter(
        categories: _filter.venueTypes,
        maxDistanceKm: _filter.maxDistanceKm,
        minRating: _filter.minRating,
        onlyVerified: _filter.onlyVerified,
        onlyHygienic: _filter.onlyHygienic,
        onlyPreferred: _filter.onlyPreferred,
      );

      final results = await _venueRepository.searchVenues(
        query: _searchQuery,
        filter: venueFilter,
        lat: _userLatitude,
        lng: _userLongitude,
      );

      _searchResults = results;
      _hasSearched = true;

      // Son aramalara ekle
      await _addToRecentSearches(
        RecentSearch(
          query: _searchQuery,
          location: _selectedDistrict != null && _selectedProvince != null
              ? '$_selectedDistrict, $_selectedProvince'
              : null,
          type: SearchType.service,
        ),
      );
    } catch (e) {
      _errorMessage = 'Arama sırasında bir hata oluştu';
      debugPrint('Search error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Arama sorgusunu temizler
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _hasSearched = false;
    _errorMessage = null;
    _debounceTimer?.cancel();
    notifyListeners();
  }

  // ==================== Filtre İşlemleri ====================

  /// Filtreyi günceller
  void setFilter(SearchFilter newFilter) {
    _filter = newFilter;
    _saveLastFilter();
    notifyListeners();

    // Arama varsa yeniden ara
    if (_hasSearched && _searchQuery.isNotEmpty) {
      search();
    }
  }

  /// Filtreyi sıfırlar
  void clearFilters() {
    _filter = SearchFilter.empty();
    _saveLastFilter();
    notifyListeners();

    if (_hasSearched && _searchQuery.isNotEmpty) {
      search();
    }
  }

  /// Konum bilgisini günceller
  void setLocation({
    String? province,
    String? district,
    double? latitude,
    double? longitude,
  }) {
    _selectedProvince = province;
    _selectedDistrict = district;
    _userLatitude = latitude;
    _userLongitude = longitude;

    _filter = _filter.copyWith(province: province, district: district);

    notifyListeners();
  }

  // ==================== Son Aramalar ====================

  /// Son aramaları yükler
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentSearchesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _recentSearches = jsonList
            .map((e) => RecentSearch.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  /// Son aramalara ekler
  Future<void> _addToRecentSearches(RecentSearch search) async {
    // Aynı sorgu varsa kaldır
    _recentSearches.removeWhere(
      (s) => s.query.toLowerCase() == search.query.toLowerCase(),
    );

    // Başa ekle
    _recentSearches.insert(0, search);

    // Limit kontrolü
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }

    await _saveRecentSearches();
    notifyListeners();
  }

  /// Son aramaları kaydeder
  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _recentSearches.map((e) => e.toJson()).toList();
      await prefs.setString(_recentSearchesKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving recent searches: $e');
    }
  }

  /// Tek bir son aramayı siler
  Future<void> deleteRecentSearch(String id) async {
    _recentSearches.removeWhere((s) => s.id == id);
    await _saveRecentSearches();
    notifyListeners();
  }

  /// Tüm son aramaları temizler
  Future<void> clearAllRecentSearches() async {
    _recentSearches.clear();
    await _saveRecentSearches();
    notifyListeners();
  }

  /// Son aramayı seçer ve arama yapar
  void selectRecentSearch(RecentSearch search) {
    _searchQuery = search.query;
    this.search();
  }

  // ==================== Filtre Persist ====================

  /// Son filtreyi yükler
  Future<void> _loadLastFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_lastFilterKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        _filter = SearchFilter.fromJson(jsonMap);
        _selectedProvince = _filter.province;
        _selectedDistrict = _filter.district;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading last filter: $e');
    }
  }

  /// Son filtreyi kaydeder
  Future<void> _saveLastFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastFilterKey, json.encode(_filter.toJson()));
    } catch (e) {
      debugPrint('Error saving last filter: $e');
    }
  }

  // ==================== Popüler Hizmetler ====================

  /// Popüler hizmetleri yükler
  Future<void> _loadPopularServices() async {
    _isLoadingServices = true;
    notifyListeners();

    try {
      // TODO: Backend'den popüler hizmetleri çek
      // Şimdilik hardcoded liste
      _popularServices = [
        PopularService(id: '1', name: 'Botoks'),
        PopularService(id: '2', name: 'Hydrafacial'),
        PopularService(id: '3', name: 'İpek Kirpik'),
        PopularService(id: '4', name: 'Lazer Epilasyon'),
        PopularService(id: '5', name: 'Microblading'),
        PopularService(id: '6', name: 'Kalıcı Oje'),
      ];
    } catch (e) {
      debugPrint('Error loading popular services: $e');
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  /// Popüler hizmet seçer ve arama yapar
  void selectPopularService(PopularService service) {
    _searchQuery = service.name;
    search();
  }

  // ==================== Önerilen Mekanlar ====================

  /// Önerilen mekanları yükler
  Future<void> _loadSuggestedVenues() async {
    _isLoadingSuggestions = true;
    notifyListeners();

    try {
      // Öne çıkan mekanları önerilen olarak kullan
      final venues = await _venueRepository.getFeaturedVenues();
      _suggestedVenues = venues;
    } catch (e) {
      debugPrint('Error loading suggested venues: $e');
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Basit popüler hizmet modeli
class PopularService {
  final String id;
  final String name;

  const PopularService({required this.id, required this.name});
}
