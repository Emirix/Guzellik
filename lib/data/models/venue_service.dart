class VenueService {
  final String id;
  final String venueId;
  final String serviceCategoryId;
  final double? customPrice;
  final int? customDurationMinutes;
  final bool isAvailable;
  final DateTime createdAt;

  // Populated from join
  final String? serviceName;
  final String? serviceCategory;
  final String? serviceDescription;
  final int? serviceAverageDuration;

  VenueService({
    required this.id,
    required this.venueId,
    required this.serviceCategoryId,
    this.customPrice,
    this.customDurationMinutes,
    this.isAvailable = true,
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
      customPrice: (json['custom_price'] as num?)?.toDouble(),
      customDurationMinutes: (json['custom_duration_minutes'] as num?)?.toInt(),
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      serviceName: json['service_name'] as String?,
      serviceCategory: json['service_category'] as String?,
      serviceDescription: json['service_description'] as String?,
      serviceAverageDuration: (json['service_average_duration'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'service_category_id': serviceCategoryId,
      'custom_price': customPrice,
      'custom_duration_minutes': customDurationMinutes,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method to get effective price
  double getEffectivePrice() => customPrice ?? 0.0;

  // Helper method to get effective duration
  int getEffectiveDuration() => customDurationMinutes ?? serviceAverageDuration ?? 0;
}
