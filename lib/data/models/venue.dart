import 'venue_photo.dart';

class Venue {
  final String id;
  final String name;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl; // DEPRECATED - use heroImages instead

  // Gallery Support
  final List<String> heroImages; // Hero carousel URLs
  final List<VenuePhoto>? galleryPhotos; // Detailed gallery (lazy loaded)

  // Trust Badges
  final bool isVerified;
  final bool isPreferred;
  final bool isHygienic;

  // Follow System
  final bool isFollowing; // Whether current user follows this venue
  final int followerCount; // Total number of followers

  // Detailed Info
  final Map<String, dynamic> workingHours;
  final List<dynamic> expertTeam;
  final List<dynamic> certifications;
  final List<String> paymentOptions;
  final Map<String, dynamic> accessibility;
  final List<dynamic> faq;
  final Map<String, dynamic> socialLinks;
  final List<String> features;

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
    this.heroImages = const [],
    this.galleryPhotos,
    this.isVerified = false,
    this.isPreferred = false,
    this.isHygienic = false,
    this.isFollowing = false,
    this.followerCount = 0,
    this.workingHours = const {},
    this.expertTeam = const [],
    this.certifications = const [],
    this.paymentOptions = const [],
    this.accessibility = const {},
    this.faq = const [],
    this.socialLinks = const {},
    this.features = const [],
    this.ownerId,
    required this.createdAt,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    // Handle PostGIS point format if needed, but Supabase geography usually returns simple lat/lng in some formats
    // If it's standard ST_AsGeoJSON, it will be different. Assuming a processed format or simple extraction.

    // Parse hero images from JSONB array
    List<String> heroImagesList = [];
    if (json['hero_images'] != null) {
      final heroImagesJson = json['hero_images'];
      if (heroImagesJson is List) {
        heroImagesList = heroImagesJson.map((e) => e.toString()).toList();
      }
    }

    // Fallback: if hero_images is empty but image_url exists, use it
    if (heroImagesList.isEmpty && json['image_url'] != null) {
      heroImagesList = [json['image_url'] as String];
    }

    // Parse gallery photos if provided
    List<VenuePhoto>? galleryPhotosList;
    if (json['gallery_photos'] != null && json['gallery_photos'] is List) {
      galleryPhotosList = (json['gallery_photos'] as List)
          .map(
            (photoJson) =>
                VenuePhoto.fromJson(photoJson as Map<String, dynamic>),
          )
          .toList();
    }

    return Venue(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'İsimsiz Mekan',
      description: json['description'] as String?,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      heroImages: heroImagesList,
      galleryPhotos: galleryPhotosList,
      isVerified: json['is_verified'] as bool? ?? false,
      isPreferred: json['is_preferred'] as bool? ?? false,
      isHygienic: json['is_hygienic'] as bool? ?? false,
      isFollowing: json['is_following'] as bool? ?? false,
      followerCount: json['follower_count'] as int? ?? 0,
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
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ownerId: json['owner_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
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
      'hero_images': heroImages,
      'gallery_photos': galleryPhotos?.map((photo) => photo.toJson()).toList(),
      'is_verified': isVerified,
      'is_preferred': isPreferred,
      'is_hygienic': isHygienic,
      'is_following': isFollowing,
      'follower_count': followerCount,
      'working_hours': workingHours,
      'expert_team': expertTeam,
      'certifications': certifications,
      'payment_options': paymentOptions,
      'accessibility': accessibility,
      'faq': faq,
      'social_links': socialLinks,
      'features': features,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
