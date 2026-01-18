import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/recent_search.dart';
import '../../data/models/search_filter.dart';
import '../../data/models/service.dart';
import '../../data/models/popular_service.dart';
import '../../data/models/venue.dart';
import '../../data/models/venue_filter.dart';
import '../../data/models/venue_category.dart';
import '../../data/repositories/venue_repository.dart';

import '../../core/services/voice_search_service.dart';

/// Arama ekranı state yönetimi
class SearchProvider extends ChangeNotifier {
  final VenueRepository _venueRepository;
  final VoiceSearchService _voiceService = VoiceSearchService.instance;

  // Sesli arama durumu
  bool _isVoiceSearching = false;
  String? _voiceSearchError;
  bool _isVoiceAvailable = false;

  // Arama durumu
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Venue> _searchResults = [];
  String? _errorMessage;
  bool _hasSearched = false;
  int _offset = 0;
  bool _hasMore = true;
  static const int _pageSize = 20;

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

  // Kategoriler
  List<VenueCategory> _categories = [];
  bool _isLoadingCategories = false;
  VenueCategory? _selectedCategory;
  List<Service> _categoryServices = [];
  bool _isLoadingCategoryServices = false;

  // Konum
  String? _selectedProvince;
  String? _selectedDistrict;
  int? _selectedProvinceId;
  String? _selectedDistrictId;
  double? _userLatitude;
  double? _userLongitude;

  // Constants
  static const String _recentSearchesKey = 'recent_searches';
  static const String _lastFilterKey = 'last_search_filter';
  static const int _maxRecentSearches = 3;

  SearchProvider({required VenueRepository venueRepository})
    : _venueRepository = venueRepository {
    _loadRecentSearches();
    _loadLastFilter();
    _loadPopularServices();
    _loadSuggestedVenues();
    _loadCategories();
    _initVoiceSearch();
  }

  // Voice Getters
  bool get isVoiceSearching => _isVoiceSearching;
  String? get voiceSearchError => _voiceSearchError;
  bool get isVoiceAvailable => _isVoiceAvailable;

  Future<void> _initVoiceSearch() async {
    _isVoiceAvailable = await _voiceService.initialize();
    notifyListeners();
  }

  Future<void> startVoiceSearch() async {
    _voiceSearchError = null;
    _isVoiceSearching = true;
    notifyListeners();

    await _voiceService.startListening(
      onResult: (text) {
        setSearchQuery(text);
      },
      onError: (error) {
        _voiceSearchError = error;
        _isVoiceSearching = false;
        notifyListeners();
      },
      onDone: () {
        _isVoiceSearching = false;
        notifyListeners();
      },
    );
  }

  Future<void> stopVoiceSearch() async {
    await _voiceService.stopListening();
    _isVoiceSearching = false;
    notifyListeners();
  }

  // Getters
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<Venue> get searchResults => _searchResults;
  String? get errorMessage => _errorMessage;
  bool get hasSearched => _hasSearched;
  bool get hasMore => _hasMore;
  SearchFilter get filter => _filter;
  List<RecentSearch> get recentSearches => _recentSearches;
  List<PopularService> get popularServices => _popularServices;
  bool get isLoadingServices => _isLoadingServices;
  String? get selectedProvince => _selectedProvince;
  String? get selectedDistrict => _selectedDistrict;
  int? get selectedProvinceId => _selectedProvinceId;
  String? get selectedDistrictId => _selectedDistrictId;
  double? get userLatitude => _userLatitude;
  double? get userLongitude => _userLongitude;
  List<Venue> get suggestedVenues => _suggestedVenues;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  List<VenueCategory> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  VenueCategory? get selectedCategory => _selectedCategory;
  List<Service> get categoryServices => _categoryServices;
  bool get isLoadingCategoryServices => _isLoadingCategoryServices;

  bool get hasActiveFilters => _filter.hasActiveFilters;
  int get activeFilterCount => _filter.activeFilterCount;
  bool get isCategorySelected => _selectedCategory != null;

  /// Kategori Id'sine göre kategoriyi döner (restorasyon için)
  void _syncSelectedCategory() {
    if (_filter.venueCategoryId != null && _categories.isNotEmpty) {
      try {
        final category = _categories.firstWhere(
          (c) => c.id == _filter.venueCategoryId,
        );
        _selectedCategory = category;
        _hasSearched = true; // Kayıtlı kategori varsa sonuçları göster
        notifyListeners();
        // Eğer kategori varsa ama sonuçlar boşsa yükle
        if (_searchResults.isEmpty && _searchQuery.isEmpty) {
          searchByCategory(showLoading: false);
        }
      } catch (e) {
        debugPrint('Could not restore selected category: $e');
      }
    }
  }

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
      // Kategori seçiliyse kategori aramasına geri dön
      if (isCategorySelected) {
        _hasSearched = true;
        _searchResults = []; // Geçici olarak temizle
        searchByCategory();
      } else {
        _hasSearched = false;
        _searchResults = [];
      }
      notifyListeners();
    }
  }

  /// Arama yapar - Elastic Search kullanarak tam metin araması
  Future<void> search({bool showLoading = true}) async {
    if (_searchQuery.isEmpty) return;

    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      _offset = 0;
      _hasMore = true;
      notifyListeners();
    }

    try {
      // Use elastic search for comprehensive full-text search
      final results = await _venueRepository.elasticSearchVenues(
        query: _searchQuery,
        lat: _userLatitude,
        lng: _userLongitude,
        provinceId: _selectedProvinceId,
        districtId: _selectedDistrictId,
        maxDistanceKm: _filter.maxDistanceKm,
        onlyVerified: _filter.onlyVerified,
        onlyPreferred: _filter.onlyPreferred,
        onlyHygienic: _filter.onlyHygienic,
        minRating: _filter.minRating,
        sortBy: _filter.sortBy.name,
        serviceIds: _filter.serviceIds,
        limit: _pageSize,
        offset: _offset,
      );

      // Map distances locally if needed
      if (_userLatitude != null && _userLongitude != null) {
        _searchResults = results.map((v) {
          final distance = Geolocator.distanceBetween(
            _userLatitude!,
            _userLongitude!,
            v.latitude,
            v.longitude,
          );
          return v.copyWith(distance: distance);
        }).toList();
      } else {
        _searchResults = results;
      }

      _hasSearched = true;
      _hasMore = results.length >= _pageSize;
      _offset = results.length;

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

  /// Kategori seçer ve kategoriye göre filtreleme yapar (arama sorgusu kullanmadan)
  void selectCategory(VenueCategory category) {
    // Kategori seçildiğinde diğer filtreleri sıfırla
    _selectedCategory = category;
    _filter = SearchFilter(
      venueCategoryId: category.id,
      venueTypes: [category.name],
    );
    _searchQuery = ''; // Arama sorgusunu temizle
    _hasSearched = true; // Sonuçları göstermek için
    _categoryServices = []; // Hizmetleri sıfırla
    _saveLastFilter();
    notifyListeners();
    loadServicesByCategory(category.id);
    searchByCategory(); // Elastic search yerine kategoriye göre ara
  }

  /// Sadece kategoriye göre arama yapar
  Future<void> searchByCategory({bool showLoading = true}) async {
    debugPrint('🔍 searchByCategory called with:');
    debugPrint('  - categoryId: ${_filter.venueCategoryId}');
    debugPrint('  - venueTypes: ${_filter.venueTypes}');
    debugPrint('  - showLoading: $showLoading');

    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      _offset = 0;
      _hasMore = true;
      notifyListeners();
    }

    try {
      final venueFilter = VenueFilter(
        categoryId: _filter.venueCategoryId,
        categories: _filter.venueTypes,
        maxDistanceKm: _filter.maxDistanceKm,
        minRating: _filter.minRating,
        onlyVerified: _filter.onlyVerified,
        onlyHygienic: _filter.onlyHygienic,
        onlyPreferred: _filter.onlyPreferred,
        sortBy: _mapSortOptionToVenueSortBy(_filter.sortBy),
        serviceIds: _filter.serviceIds,
      );

      final results = await _venueRepository.searchVenues(
        query: null,
        filter: venueFilter,
        lat: _userLatitude,
        lng: _userLongitude,
        limit: _pageSize,
        offset: _offset,
      );

      debugPrint('✅ searchVenues returned ${results.length} results');

      // Map distances locally if needed
      if (_userLatitude != null && _userLongitude != null) {
        _searchResults = results.map((v) {
          final distance = Geolocator.distanceBetween(
            _userLatitude!,
            _userLongitude!,
            v.latitude,
            v.longitude,
          );
          return v.copyWith(distance: distance);
        }).toList();
      } else {
        _searchResults = results;
      }

      _hasSearched = true;
      _hasMore = results.length >= _pageSize;
      _offset = results.length;
    } catch (e, stackTrace) {
      _errorMessage = 'Kategori araması sırasında bir hata oluştu';
      debugPrint('Category search error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint(
        'Filter details: categoryId=${_filter.venueCategoryId}, venueTypes=${_filter.venueTypes}',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Daha fazla sonuç yükler
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      List<Venue> results = [];
      if (_searchQuery.isNotEmpty) {
        results = await _venueRepository.elasticSearchVenues(
          query: _searchQuery,
          lat: _userLatitude,
          lng: _userLongitude,
          provinceId: _selectedProvinceId,
          districtId: _selectedDistrictId,
          maxDistanceKm: _filter.maxDistanceKm,
          onlyVerified: _filter.onlyVerified,
          onlyPreferred: _filter.onlyPreferred,
          onlyHygienic: _filter.onlyHygienic,
          minRating: _filter.minRating,
          sortBy: _filter.sortBy.name,
          serviceIds: _filter.serviceIds,
          limit: _pageSize,
          offset: _offset,
        );
      } else if (isCategorySelected || _filter.venueCategoryId != null) {
        final venueFilter = VenueFilter(
          categoryId: _filter.venueCategoryId,
          categories: _filter.venueTypes,
          maxDistanceKm: _filter.maxDistanceKm,
          minRating: _filter.minRating,
          onlyVerified: _filter.onlyVerified,
          onlyHygienic: _filter.onlyHygienic,
          onlyPreferred: _filter.onlyPreferred,
          sortBy: _mapSortOptionToVenueSortBy(_filter.sortBy),
          serviceIds: _filter.serviceIds,
        );

        results = await _venueRepository.searchVenues(
          query: null,
          filter: venueFilter,
          lat: _userLatitude,
          lng: _userLongitude,
          limit: _pageSize,
          offset: _offset,
        );
      }

      if (results.isEmpty) {
        _hasMore = false;
      } else {
        // Update distances locally if we have current position
        List<Venue> processedResults = results;
        if (_userLatitude != null && _userLongitude != null) {
          processedResults = results.map((v) {
            final distance = Geolocator.distanceBetween(
              _userLatitude!,
              _userLongitude!,
              v.latitude,
              v.longitude,
            );
            return v.copyWith(distance: distance);
          }).toList();
        }

        // Double check for duplicates
        final existingIds = _searchResults.map((v) => v.id).toSet();
        final uniqueResults = processedResults
            .where((v) => !existingIds.contains(v.id))
            .toList();

        _searchResults.addAll(uniqueResults);
        _offset += results.length;
        _hasMore = results.length >= _pageSize;
      }
    } catch (e) {
      debugPrint('Load more error: $e');
    } finally {
      _isLoadingMore = false;
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
    if (_hasSearched) {
      if (_searchQuery.isNotEmpty) {
        search();
      } else if (_selectedCategory != null || _filter.venueCategoryId != null) {
        searchByCategory();
      }
    }
  }

  /// Filtreyi sıfırlar
  void clearFilters() {
    _filter = SearchFilter.empty();
    _selectedCategory = null;
    _saveLastFilter();
    notifyListeners();

    if (_hasSearched && _searchQuery.isNotEmpty) {
      search();
    } else if (isCategorySelected) {
      searchByCategory();
    }
  }

  /// Konum bilgisini günceller
  void setLocation({
    String? province,
    String? district,
    int? provinceId,
    String? districtId,
    double? latitude,
    double? longitude,
  }) {
    // Only update if values actually changed to avoid redundant searches
    final bool locationChanged =
        _userLatitude != latitude ||
        _userLongitude != longitude ||
        _selectedProvinceId != provinceId ||
        _selectedDistrictId != districtId;

    if (!locationChanged) return;

    _selectedProvince = province;
    _selectedDistrict = district;
    _selectedProvinceId = provinceId;
    _selectedDistrictId = districtId;
    _userLatitude = latitude;
    _userLongitude = longitude;

    _filter = _filter.copyWith(province: province, district: district);

    // Sadece arama yapılmışsa yenile, yoksa notifyListeners çağırma
    if (_hasSearched) {
      notifyListeners();
      refreshSearch(showLoading: false);
    }
  }

  /// Mevcut arama kriterlerine göre sonuçları yeniler
  Future<void> refreshSearch({bool showLoading = true}) async {
    if (_searchQuery.isNotEmpty) {
      await search(showLoading: showLoading);
    } else if (_selectedCategory != null || _filter.venueCategoryId != null) {
      await searchByCategory(showLoading: showLoading);
    }
  }

  // ==================== Son Aramalar ====================

  /// Son aramaları yükler
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentSearchesKey);
      if (jsonString != null) {
        // JSON parsing'i isolate'te yap
        final List<dynamic> jsonList = await compute(
          _parseJsonList,
          jsonString,
        );
        _recentSearches = jsonList
            .map((e) => RecentSearch.fromJson(e))
            .toList();

        // Limit loaded searches
        if (_recentSearches.length > _maxRecentSearches) {
          _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  // Isolate function for JSON parsing
  static List<dynamic> _parseJsonList(String jsonString) {
    return json.decode(jsonString) as List<dynamic>;
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
        // JSON parsing'i isolate'te yap
        final jsonMap = await compute(_parseJsonMap, jsonString);
        _filter = SearchFilter.fromJson(jsonMap);
        _selectedProvince = _filter.province;
        _selectedDistrict = _filter.district;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading last filter: $e');
    }
  }

  // Isolate function for JSON map parsing
  static Map<String, dynamic> _parseJsonMap(String jsonString) {
    return json.decode(jsonString) as Map<String, dynamic>;
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
      _popularServices = await _venueRepository.getPopularServices(limit: 7);
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

      // Update distances locally if we have current position
      if (_userLatitude != null && _userLongitude != null) {
        _suggestedVenues = venues.map((v) {
          final distance = Geolocator.distanceBetween(
            _userLatitude!,
            _userLongitude!,
            v.latitude,
            v.longitude,
          );
          return v.copyWith(distance: distance);
        }).toList();
      } else {
        _suggestedVenues = venues;
      }
    } catch (e) {
      debugPrint('Error loading suggested venues: $e');
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  /// Mekan kategorilerini yükler
  Future<void> _loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _venueRepository.getVenueCategories();
      _syncSelectedCategory(); // Kategoriler yüklenince seçili olanı eşle
    } catch (e) {
      debugPrint('Error loading search categories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Seçili kategoriye ait hizmetleri yükler
  Future<void> loadServicesByCategory(String categoryId) async {
    _isLoadingCategoryServices = true;
    notifyListeners();

    try {
      _categoryServices = await _venueRepository.getServicesByCategory(
        categoryId,
      );
    } catch (e) {
      debugPrint('Error loading category services: $e');
      _categoryServices = [];
    } finally {
      _isLoadingCategoryServices = false;
      notifyListeners();
    }
  }

  VenueSortBy _mapSortOptionToVenueSortBy(SortOption option) {
    switch (option) {
      case SortOption.nearest:
        return VenueSortBy.nearest;
      case SortOption.highestRated:
        return VenueSortBy.highestRated;
      case SortOption.mostReviewed:
        return VenueSortBy.mostReviewed;
      case SortOption.recommended:
        return VenueSortBy.recommended;
    }
  }

  // ==================== Mekan Takip İşlemleri ====================

  /// Mekanı takip eder veya takibi bırakır
  Future<void> toggleFollowVenue(Venue venue) async {
    final index = _searchResults.indexWhere((v) => v.id == venue.id);
    if (index == -1) return;

    final isFollowing = venue.isFollowing;
    final newFollowerCount = isFollowing
        ? (venue.followerCount > 0 ? venue.followerCount - 1 : 0)
        : venue.followerCount + 1;

    // Local state update for immediate feedback
    _searchResults[index] = venue.copyWith(
      isFollowing: !isFollowing,
      followerCount: newFollowerCount,
    );
    notifyListeners();

    try {
      if (isFollowing) {
        await _venueRepository.unfollowVenue(venue.id);
      } else {
        await _venueRepository.followVenue(venue.id);
      }
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      // Revert local state on error
      _searchResults[index] = venue;
      notifyListeners();
      rethrow;
    }
  }

  /// Mekanı favorilere ekler veya favorilerden çıkarır
  Future<void> toggleFavoriteVenue(Venue venue) async {
    final index = _searchResults.indexWhere((v) => v.id == venue.id);
    if (index == -1) return;

    final isFavorited = venue.isFavorited;

    // Local state update for immediate feedback
    _searchResults[index] = venue.copyWith(isFavorited: !isFavorited);
    notifyListeners();

    try {
      if (isFavorited) {
        await _venueRepository.removeFavorite(venue.id);
      } else {
        await _venueRepository.addFavorite(venue.id);
      }
    } catch (e) {
      debugPrint('Error toggling favorite in Search: $e');
      // Revert local state on error
      _searchResults[index] = venue;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
