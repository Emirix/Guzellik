import '../../core/utils/image_utils.dart';

enum PhotoCategory {
  interior,
  exterior,
  serviceResult,
  team,
  equipment;

  String toJson() {
    switch (this) {
      case PhotoCategory.interior:
        return 'interior';
      case PhotoCategory.exterior:
        return 'exterior';
      case PhotoCategory.serviceResult:
        return 'service_result';
      case PhotoCategory.team:
        return 'team';
      case PhotoCategory.equipment:
        return 'equipment';
    }
  }

  static PhotoCategory fromJson(String value) {
    switch (value) {
      case 'interior':
        return PhotoCategory.interior;
      case 'exterior':
        return PhotoCategory.exterior;
      case 'service_result':
        return PhotoCategory.serviceResult;
      case 'team':
        return PhotoCategory.team;
      case 'equipment':
        return PhotoCategory.equipment;
      default:
        return PhotoCategory.interior;
    }
  }

  String get displayName {
    switch (this) {
      case PhotoCategory.interior:
        return 'İç Mekan';
      case PhotoCategory.exterior:
        return 'Dış Mekan';
      case PhotoCategory.serviceResult:
        return 'Hizmet Sonuçları';
      case PhotoCategory.team:
        return 'Ekip';
      case PhotoCategory.equipment:
        return 'Ekipman';
    }
  }
}

class VenuePhoto {
  final String id;
  final String venueId;
  final String url;
  final String? thumbnailUrl;
  final String? title;
  final PhotoCategory category;
  final String? serviceId;
  final DateTime uploadedAt;
  final int sortOrder;
  final bool isHeroImage;
  final int likesCount;

  VenuePhoto({
    required this.id,
    required this.venueId,
    required this.url,
    this.thumbnailUrl,
    this.title,
    required this.category,
    this.serviceId,
    required this.uploadedAt,
    this.sortOrder = 0,
    this.isHeroImage = false,
    this.likesCount = 0,
  });

  factory VenuePhoto.fromJson(Map<String, dynamic> json) {
    return VenuePhoto(
      id: json['id'] as String? ?? '',
      venueId: json['venue_id'] as String? ?? '',
      url: ImageUtils.normalizeUrl(json['url'] as String? ?? '')!,
      thumbnailUrl: ImageUtils.normalizeUrl(json['thumbnail_url'] as String?),
      title: json['title'] as String?,
      category: json['category'] != null
          ? PhotoCategory.fromJson(json['category'] as String)
          : PhotoCategory.interior,
      serviceId: json['service_id'] as String?,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : DateTime.now(),
      sortOrder: json['sort_order'] as int? ?? 0,
      isHeroImage: json['is_hero_image'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'title': title,
      'category': category.toJson(),
      'service_id': serviceId,
      'uploaded_at': uploadedAt.toIso8601String(),
      'sort_order': sortOrder,
      'is_hero_image': isHeroImage,
      'likes_count': likesCount,
    };
  }

  VenuePhoto copyWith({
    String? id,
    String? venueId,
    String? url,
    String? thumbnailUrl,
    String? title,
    PhotoCategory? category,
    String? serviceId,
    DateTime? uploadedAt,
    int? sortOrder,
    bool? isHeroImage,
    int? likesCount,
  }) {
    return VenuePhoto(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      category: category ?? this.category,
      serviceId: serviceId ?? this.serviceId,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      isHeroImage: isHeroImage ?? this.isHeroImage,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}
