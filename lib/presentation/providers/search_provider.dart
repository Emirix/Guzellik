import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/recent_search.dart';
import '../../data/models/search_filter.dart';
import '../../data/models/service.dart';
import '../../data/models/venue.dart';
import '../../data/models/venue_filter.dart';
import '../../data/models/venue_category.dart';
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
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
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
      );

      _searchResults = results;
      _hasSearched = true;
    } catch (e) {
      _errorMessage = 'Kategori araması sırasında bir hata oluştu';
      debugPrint('Category search error: $e');
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

    notifyListeners();

    // Arama yapılmışsa yeni konuma göre sonuçları güncelle
    if (_hasSearched) {
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
        final List<dynamic> jsonList = json.decode(jsonString);
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
