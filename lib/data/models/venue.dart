import 'venue_category.dart';
import 'venue_photo.dart';
import '../../core/utils/image_utils.dart';

class Venue {
  final String id;
  final String name;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final List<String> heroImages; // Hero carousel URLs
  final List<VenuePhoto>? galleryPhotos; // Detailed gallery (lazy loaded)

  // Category & Icon
  final VenueCategory? category;
  final String? icon;

  // Trust Badges
  final bool isVerified;
  final bool isPreferred;
  final bool isHygienic;

  // Follow & Favorite System
  final bool isFollowing; // Whether current user follows this venue
  final int followerCount; // Total number of followers
  final bool isFavorited; // Whether current user favorited this venue

  // Detailed Info
  final Map<String, dynamic> workingHours;
  final List<dynamic> expertTeam;
  final List<String> paymentOptions;
  final Map<String, dynamic> accessibility;
  final List<dynamic> faq;
  final Map<String, dynamic> socialLinks;
  final List<String> features;

  final String? ownerId;
  final DateTime createdAt;

  // Rating Info
  final double rating;
  final int ratingCount;

  // Distance (transient field, populated by search RPC)
  final double? distance;

  // Location Info
  final int? provinceId;
  final String? districtId;
  final String? provinceName;
  final String? districtName;

  // Discovery Info
  final bool isDiscover;

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
    this.category,
    this.icon,
    this.isVerified = false,
    this.isPreferred = false,
    this.isHygienic = false,
    this.isFollowing = false,
    this.followerCount = 0,
    this.isFavorited = false,
    this.workingHours = const {},
    this.expertTeam = const [],
    this.paymentOptions = const [],
    this.accessibility = const {},
    this.faq = const [],
    this.socialLinks = const {},
    this.features = const [],
    this.ownerId,
    required this.createdAt,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.distance,
    this.provinceId,
    this.districtId,
    this.provinceName,
    this.districtName,
    this.isDiscover = false,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    // Handle PostGIS point format if needed, but Supabase geography usually returns simple lat/lng in some formats
    // If it's standard ST_AsGeoJSON, it will be different. Assuming a processed format or simple extraction.

    // Parse hero images from JSONB array
    List<String> heroImagesList = [];
    if (json['hero_images'] != null) {
      final heroImagesJson = json['hero_images'];
      if (heroImagesJson is List) {
        heroImagesList = heroImagesJson
            .map((e) => ImageUtils.normalizeUrl(e.toString())!)
            .toList();
      }
    }

    // Fallback: if hero_images is empty but image_url exists, use it
    if (heroImagesList.isEmpty && json['image_url'] != null) {
      heroImagesList = [ImageUtils.normalizeUrl(json['image_url'] as String)!];
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

    // Parse category if provided (as a joined relation or flattened fields)
    VenueCategory? venueCategory;
    String? categoryIcon = json['category_icon'] as String?;

    if (json['venue_categories'] != null) {
      venueCategory = VenueCategory.fromJson(
        json['venue_categories'] as Map<String, dynamic>,
      );
      categoryIcon ??= venueCategory.icon;
    } else if (json['category'] != null) {
      venueCategory = VenueCategory.fromJson(
        json['category'] as Map<String, dynamic>,
      );
      categoryIcon ??= venueCategory.icon;
    } else if (json['category_name'] != null) {
      // Handle flattened category fields from search RPC
      venueCategory = VenueCategory(
        id: json['category_id'] as String? ?? '',
        name: json['category_name'] as String,
        slug: '',
        icon: categoryIcon ?? 'spa',
      );
    }

    return Venue(
      id: _toString(json['id']) ?? '',
      name: _toString(json['name']) ?? 'İsimsiz Mekan',
      description: _toString(json['description']),
      address: _toString(json['address']) ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      imageUrl: ImageUtils.normalizeUrl(_toString(json['image_url'])),
      heroImages: heroImagesList,
      galleryPhotos: galleryPhotosList,
      category: venueCategory,
      icon: categoryIcon ?? _toString(json['icon']),
      isVerified: _toBool(json['is_verified']),
      isPreferred: _toBool(json['is_preferred']),
      isHygienic: _toBool(json['is_hygienic']),
      isFollowing: _toBool(json['is_following']),
      followerCount: _toInt(json['follower_count']),
      isFavorited: _toBool(json['is_favorited']),
      workingHours: json['working_hours'] as Map<String, dynamic>? ?? {},
      expertTeam: json['expert_team'] as List<dynamic>? ?? [],
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
      ownerId: _toString(json['owner_id']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      rating: _toDouble(json['rating']),
      ratingCount: _toInt(json['review_count']),
      distance: _toDoubleNullable(json['distance_meters'] ?? json['distance']),
      provinceId: _toInt(json['province_id']),
      districtId: _toString(json['district_id']),
      provinceName: _toString(json['province_name']),
      districtName: _toString(json['district_name']),
      isDiscover: _toBool(json['is_discover']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return 0.0;
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return null;
      return double.tryParse(value);
    }
    return null;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
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
      'category': category?.toJson(),
      'icon': icon,
      'is_verified': isVerified,
      'is_preferred': isPreferred,
      'is_hygienic': isHygienic,
      'is_following': isFollowing,
      'follower_count': followerCount,
      'is_favorited': isFavorited,
      'working_hours': workingHours,
      'expert_team': expertTeam,
      'payment_options': paymentOptions,
      'accessibility': accessibility,
      'faq': faq,
      'social_links': socialLinks,
      'features': features,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
      'review_count': ratingCount,
      'distance_meters': distance,
      'province_id': provinceId,
      'district_id': districtId,
      'province_name': provinceName,
      'district_name': districtName,
      'is_discover': isDiscover,
    };
  }

  Venue copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? heroImages,
    List<VenuePhoto>? galleryPhotos,
    VenueCategory? category,
    bool? isVerified,
    bool? isPreferred,
    bool? isHygienic,
    bool? isFollowing,
    int? followerCount,
    bool? isFavorited,
    Map<String, dynamic>? workingHours,
    List<dynamic>? expertTeam,
    List<String>? paymentOptions,
    Map<String, dynamic>? accessibility,
    List<dynamic>? faq,
    Map<String, dynamic>? socialLinks,
    List<String>? features,
    String? ownerId,
    DateTime? createdAt,
    double? rating,
    int? ratingCount,
    double? distance,
    int? provinceId,
    String? districtId,
    String? provinceName,
    String? districtName,
    bool? isDiscover,
  }) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      heroImages: heroImages ?? this.heroImages,
      galleryPhotos: galleryPhotos ?? this.galleryPhotos,
      category: category ?? this.category,
      isVerified: isVerified ?? this.isVerified,
      isPreferred: isPreferred ?? this.isPreferred,
      isHygienic: isHygienic ?? this.isHygienic,
      isFollowing: isFollowing ?? this.isFollowing,
      followerCount: followerCount ?? this.followerCount,
      isFavorited: isFavorited ?? this.isFavorited,
      workingHours: workingHours ?? this.workingHours,
      expertTeam: expertTeam ?? this.expertTeam,
      paymentOptions: paymentOptions ?? this.paymentOptions,
      accessibility: accessibility ?? this.accessibility,
      faq: faq ?? this.faq,
      socialLinks: socialLinks ?? this.socialLinks,
      features: features ?? this.features,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      distance: distance ?? this.distance,
      provinceId: provinceId ?? this.provinceId,
      districtId: districtId ?? this.districtId,
      provinceName: provinceName ?? this.provinceName,
      districtName: districtName ?? this.districtName,
      isDiscover: isDiscover ?? this.isDiscover,
    );
  }
}
