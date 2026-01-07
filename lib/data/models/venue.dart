class Venue {
  final String id;
  final String name;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;

  // Trust Badges
  final bool isVerified;
  final bool isPreferred;
  final bool isHygienic;

  // Detailed Info
  final Map<String, dynamic> workingHours;
  final List<dynamic> expertTeam;
  final List<dynamic> certifications;
  final List<String> paymentOptions;
  final Map<String, dynamic> accessibility;
  final List<dynamic> faq;
  final Map<String, dynamic> socialLinks;

  final String? ownerId;
  final DateTime createdAt;

  Venue({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.isVerified = false,
    this.isPreferred = false,
    this.isHygienic = false,
    this.workingHours = const {},
    this.expertTeam = const [],
    this.certifications = const [],
    this.paymentOptions = const [],
    this.accessibility = const {},
    this.faq = const [],
    this.socialLinks = const {},
    this.ownerId,
    required this.createdAt,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    // Handle PostGIS point format if needed, but Supabase geography usually returns simple lat/lng in some formats
    // If it's standard ST_AsGeoJSON, it will be different. Assuming a processed format or simple extraction.

    return Venue(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isPreferred: json['is_preferred'] as bool? ?? false,
      isHygienic: json['is_hygienic'] as bool? ?? false,
      workingHours: json['working_hours'] as Map<String, dynamic>? ?? {},
      expertTeam: json['expert_team'] as List<dynamic>? ?? [],
      certifications: json['certifications'] as List<dynamic>? ?? [],
      paymentOptions:
          (json['payment_options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      accessibility: json['accessibility'] as Map<String, dynamic>? ?? {},
      faq: json['faq'] as List<dynamic>? ?? [],
      socialLinks: json['social_links'] as Map<String, dynamic>? ?? {},
      ownerId: json['owner_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'is_verified': isVerified,
      'is_preferred': isPreferred,
      'is_hygienic': isHygienic,
      'working_hours': workingHours,
      'expert_team': expertTeam,
      'certifications': certifications,
      'payment_options': paymentOptions,
      'accessibility': accessibility,
      'faq': faq,
      'social_links': socialLinks,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
