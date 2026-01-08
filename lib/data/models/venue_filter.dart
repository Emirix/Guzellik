enum VenueSortBy { recommended, nearest, highestRated, mostReviewed }

class VenueFilter {
  final List<String> categories;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final double? maxDistanceKm;
  final bool onlyVerified;
  final bool onlyPreferred;
  final bool onlyHygienic;
  final List<String> serviceIds;
  final VenueSortBy sortBy;

  // Location filters for elastic search
  final int? provinceId;
  final String? districtId;

  VenueFilter({
    this.categories = const [],
    this.categoryId,
    this.serviceIds = const [],
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.maxDistanceKm, // Default null to show all by default
    this.onlyVerified = false,
    this.onlyPreferred = false,
    this.onlyHygienic = false,
    this.sortBy = VenueSortBy.recommended,
    this.provinceId,
    this.districtId,
  });

  VenueFilter copyWith({
    List<String>? categories,
    String? categoryId,
    List<String>? serviceIds,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? maxDistanceKm,
    bool? onlyVerified,
    bool? onlyPreferred,
    bool? onlyHygienic,
    VenueSortBy? sortBy,
    int? provinceId,
    String? districtId,
  }) {
    return VenueFilter(
      categories: categories ?? this.categories,
      categoryId: categoryId ?? this.categoryId,
      serviceIds: serviceIds ?? this.serviceIds,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      onlyVerified: onlyVerified ?? this.onlyVerified,
      onlyPreferred: onlyPreferred ?? this.onlyPreferred,
      onlyHygienic: onlyHygienic ?? this.onlyHygienic,
      sortBy: sortBy ?? this.sortBy,
      provinceId: provinceId ?? this.provinceId,
      districtId: districtId ?? this.districtId,
    );
  }

  bool get hasFilters =>
      categories.isNotEmpty ||
      categoryId != null ||
      minPrice != null ||
      maxPrice != null ||
      minRating != null ||
      maxDistanceKm != null ||
      onlyVerified ||
      onlyPreferred ||
      onlyHygienic ||
      sortBy != VenueSortBy.recommended ||
      provinceId != null ||
      districtId != null;
}
