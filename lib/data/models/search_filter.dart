/// Sıralama seçenekleri
enum SortOption {
  recommended,
  nearest,
  highestRated,
  mostReviewed,
  priceAsc,
  priceDesc,
}

/// Arama filtresi modeli
class SearchFilter {
  final String? province;
  final String? district;
  final double? maxDistanceKm;
  final List<String> serviceIds;
  final List<String> venueTypes;
  final double? minRating;
  final bool onlyVerified;
  final bool onlyHygienic;
  final bool onlyPreferred;
  final bool isOpenNow;
  final SortOption sortBy;

  const SearchFilter({
    this.province,
    this.district,
    this.maxDistanceKm,
    this.serviceIds = const [],
    this.venueTypes = const [],
    this.minRating,
    this.onlyVerified = false,
    this.onlyHygienic = false,
    this.onlyPreferred = false,
    this.isOpenNow = false,
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
      minRating != null ||
      onlyVerified ||
      onlyHygienic ||
      onlyPreferred ||
      isOpenNow ||
      sortBy != SortOption.recommended;

  /// Aktif filtre sayısını döndürür
  int get activeFilterCount {
    int count = 0;
    if (province != null) count++;
    if (maxDistanceKm != null) count++;
    if (serviceIds.isNotEmpty) count++;
    if (venueTypes.isNotEmpty) count++;
    if (minRating != null) count++;
    if (onlyVerified) count++;
    if (onlyHygienic) count++;
    if (onlyPreferred) count++;
    if (isOpenNow) count++;
    return count;
  }

  SearchFilter copyWith({
    String? province,
    String? district,
    double? maxDistanceKm,
    List<String>? serviceIds,
    List<String>? venueTypes,
    double? minRating,
    bool? onlyVerified,
    bool? onlyHygienic,
    bool? onlyPreferred,
    bool? isOpenNow,
    SortOption? sortBy,
    bool clearProvince = false,
    bool clearDistrict = false,
    bool clearMaxDistance = false,
    bool clearMinRating = false,
  }) {
    return SearchFilter(
      province: clearProvince ? null : (province ?? this.province),
      district: clearDistrict ? null : (district ?? this.district),
      maxDistanceKm: clearMaxDistance
          ? null
          : (maxDistanceKm ?? this.maxDistanceKm),
      serviceIds: serviceIds ?? this.serviceIds,
      venueTypes: venueTypes ?? this.venueTypes,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      onlyVerified: onlyVerified ?? this.onlyVerified,
      onlyHygienic: onlyHygienic ?? this.onlyHygienic,
      onlyPreferred: onlyPreferred ?? this.onlyPreferred,
      isOpenNow: isOpenNow ?? this.isOpenNow,
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
      'minRating': minRating,
      'onlyVerified': onlyVerified,
      'onlyHygienic': onlyHygienic,
      'onlyPreferred': onlyPreferred,
      'isOpenNow': isOpenNow,
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
      minRating: (json['minRating'] as num?)?.toDouble(),
      onlyVerified: json['onlyVerified'] as bool? ?? false,
      onlyHygienic: json['onlyHygienic'] as bool? ?? false,
      onlyPreferred: json['onlyPreferred'] as bool? ?? false,
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      sortBy: SortOption.values.firstWhere(
        (e) => e.name == json['sortBy'],
        orElse: () => SortOption.recommended,
      ),
    );
  }

  @override
  String toString() {
    return 'SearchFilter(province: $province, district: $district, maxDistanceKm: $maxDistanceKm, serviceIds: $serviceIds, venueTypes: $venueTypes, minRating: $minRating, onlyVerified: $onlyVerified, onlyHygienic: $onlyHygienic, onlyPreferred: $onlyPreferred, isOpenNow: $isOpenNow, sortBy: $sortBy)';
  }
}
