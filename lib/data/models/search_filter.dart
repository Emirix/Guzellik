/// Sıralama seçenekleri
enum SortOption { recommended, nearest, highestRated, mostReviewed }

/// Arama filtresi modeli
class SearchFilter {
  final String? province;
  final String? district;
  final double? maxDistanceKm;
  final List<String> serviceIds;
  final List<String> venueTypes;
  final String? venueCategoryId;
  final double? minRating;
  final bool onlyVerified;
  final bool onlyHygienic;
  final bool onlyPreferred;
  final SortOption sortBy;

  const SearchFilter({
    this.province,
    this.district,
    this.maxDistanceKm,
    this.serviceIds = const [],
    this.venueTypes = const [],
    this.venueCategoryId,
    this.minRating,
    this.onlyVerified = false,
    this.onlyHygienic = false,
    this.onlyPreferred = false,
    this.sortBy = SortOption.recommended,
  });

  /// Boş filtre oluşturur
  factory SearchFilter.empty() => const SearchFilter();

  /// Filtrenin aktif olup olmadığını kontrol eder
  bool get hasActiveFilters =>
      province != null ||
      district != null ||
      maxDistanceKm != null ||
      serviceIds.isNotEmpty ||
      venueTypes.isNotEmpty ||
      venueCategoryId != null ||
      minRating != null ||
      onlyVerified ||
      onlyHygienic ||
      onlyPreferred ||
      sortBy != SortOption.recommended;

  /// Aktif filtre sayısını döndürür
  int get activeFilterCount {
    int count = 0;
    if (province != null) count++;
    if (maxDistanceKm != null) count++;
    if (serviceIds.isNotEmpty) count++;
    if (venueTypes.isNotEmpty) count++;
    if (venueCategoryId != null) count++;
    if (minRating != null) count++;
    if (onlyVerified) count++;
    if (onlyHygienic) count++;
    if (onlyPreferred) count++;
    return count;
  }

  SearchFilter copyWith({
    String? province,
    String? district,
    double? maxDistanceKm,
    List<String>? serviceIds,
    List<String>? venueTypes,
    String? venueCategoryId,
    double? minRating,
    bool? onlyVerified,
    bool? onlyHygienic,
    bool? onlyPreferred,
    SortOption? sortBy,
    bool clearProvince = false,
    bool clearDistrict = false,
    bool clearMaxDistance = false,
    bool clearMinRating = false,
    bool clearVenueCategory = false,
  }) {
    return SearchFilter(
      province: clearProvince ? null : (province ?? this.province),
      district: clearDistrict ? null : (district ?? this.district),
      maxDistanceKm: clearMaxDistance
          ? null
          : (maxDistanceKm ?? this.maxDistanceKm),
      serviceIds: serviceIds ?? this.serviceIds,
      venueTypes: venueTypes ?? this.venueTypes,
      venueCategoryId: clearVenueCategory
          ? null
          : (venueCategoryId ?? this.venueCategoryId),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      onlyVerified: onlyVerified ?? this.onlyVerified,
      onlyHygienic: onlyHygienic ?? this.onlyHygienic,
      onlyPreferred: onlyPreferred ?? this.onlyPreferred,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// JSON'a dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'province': province,
      'district': district,
      'maxDistanceKm': maxDistanceKm,
      'serviceIds': serviceIds,
      'venueTypes': venueTypes,
      'venueCategoryId': venueCategoryId,
      'minRating': minRating,
      'onlyVerified': onlyVerified,
      'onlyHygienic': onlyHygienic,
      'onlyPreferred': onlyPreferred,
      'sortBy': sortBy.name,
    };
  }

  /// JSON'dan oluşturur
  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      province: json['province'] as String?,
      district: json['district'] as String?,
      maxDistanceKm: (json['maxDistanceKm'] as num?)?.toDouble(),
      serviceIds:
          (json['serviceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      venueTypes:
          (json['venueTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      venueCategoryId: json['venueCategoryId'] as String?,
      minRating: (json['minRating'] as num?)?.toDouble(),
      onlyVerified: json['onlyVerified'] as bool? ?? false,
      onlyHygienic: json['onlyHygienic'] as bool? ?? false,
      onlyPreferred: json['onlyPreferred'] as bool? ?? false,
      sortBy: SortOption.values.firstWhere(
        (e) => e.name == json['sortBy'],
        orElse: () => SortOption.recommended,
      ),
    );
  }

  @override
  String toString() {
    return 'SearchFilter(province: $province, district: $district, maxDistanceKm: $maxDistanceKm, serviceIds: $serviceIds, venueTypes: $venueTypes, venueCategoryId: $venueCategoryId, minRating: $minRating, onlyVerified: $onlyVerified, onlyHygienic: $onlyHygienic, onlyPreferred: $onlyPreferred, sortBy: $sortBy)';
  }
}
