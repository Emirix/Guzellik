class VenueService {
  final String id;
  final String venueId;
  final String serviceCategoryId;
  final String? customName;
  final String? customDescription;
  final String? customImageUrl;
  final double? price;
  final int? durationMinutes;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  // Populated from join (service_categories)
  final String? serviceName;
  final String? serviceCategory;
  final String? serviceDescription;
  final int? serviceAverageDuration;

  VenueService({
    required this.id,
    required this.venueId,
    required this.serviceCategoryId,
    this.customName,
    this.customDescription,
    this.customImageUrl,
    this.price,
    this.durationMinutes,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    this.serviceName,
    this.serviceCategory,
    this.serviceDescription,
    this.serviceAverageDuration,
  });

  factory VenueService.fromJson(Map<String, dynamic> json) {
    return VenueService(
      id: json['id'] as String? ?? '',
      venueId: json['venue_id'] as String? ?? '',
      serviceCategoryId: json['service_category_id'] as String? ?? '',
      customName: json['custom_name'] as String?,
      customDescription: json['custom_description'] as String?,
      customImageUrl: json['custom_image_url'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      serviceName: json['service_name'] as String?,
      serviceCategory: json['service_category'] as String?,
      serviceDescription: json['service_description'] as String?,
      serviceAverageDuration: (json['service_average_duration'] as num?)
          ?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'service_category_id': serviceCategoryId,
      'custom_name': customName,
      'custom_description': customDescription,
      'custom_image_url': customImageUrl,
      'price': price,
      'duration_minutes': durationMinutes,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method to get effective display name
  String get displayName => customName ?? serviceName ?? 'İsimsiz Hizmet';

  // Helper method to get effective price
  double get effectivePrice => price ?? 0.0;

  // Helper method to get effective duration
  int get effectiveDuration => durationMinutes ?? serviceAverageDuration ?? 0;
}
