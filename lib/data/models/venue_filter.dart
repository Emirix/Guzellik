class VenueFilter {
  final List<String> categories;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final double? maxDistanceKm;
  final bool onlyVerified;
  final bool onlyPreferred;
  final bool onlyHygienic;

  VenueFilter({
    this.categories = const [],
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.maxDistanceKm, // Default null to show all by default
    this.onlyVerified = false,
    this.onlyPreferred = false,
    this.onlyHygienic = false,
  });

  VenueFilter copyWith({
    List<String>? categories,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? maxDistanceKm,
    bool? onlyVerified,
    bool? onlyPreferred,
    bool? onlyHygienic,
  }) {
    return VenueFilter(
      categories: categories ?? this.categories,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      onlyVerified: onlyVerified ?? this.onlyVerified,
      onlyPreferred: onlyPreferred ?? this.onlyPreferred,
      onlyHygienic: onlyHygienic ?? this.onlyHygienic,
    );
  }

  bool get hasFilters =>
      categories.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      minRating != null ||
      maxDistanceKm != null ||
      onlyVerified ||
      onlyPreferred ||
      onlyHygienic;
}
