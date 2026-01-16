import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_model.freezed.dart';
part 'media_model.g.dart';

/// Represents a media asset in the centralized media system
@freezed
class MediaModel with _$MediaModel {
  const factory MediaModel({
    required String id,
    required String storagePath,
    String? mimeType,
    int? sizeBytes,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _MediaModel;

  factory MediaModel.fromJson(Map<String, dynamic> json) =>
      _$MediaModelFromJson(json);
}

/// Represents the association between an entity and media
@freezed
class EntityMediaModel with _$EntityMediaModel {
  const factory EntityMediaModel({
    required String id,
    required String mediaId,
    required String entityId,
    required EntityMediaType entityType,
    @Default(false) bool isPrimary,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    // Populated via join
    MediaModel? media,
  }) = _EntityMediaModel;

  factory EntityMediaModel.fromJson(Map<String, dynamic> json) =>
      _$EntityMediaModelFromJson(json);
}

/// Types of entities that can have media
enum EntityMediaType {
  @JsonValue('venue_hero')
  venueHero,
  @JsonValue('venue_gallery')
  venueGallery,
  @JsonValue('specialist_photo')
  specialistPhoto,
  @JsonValue('specialist_certificate')
  specialistCertificate,
  @JsonValue('profile_avatar')
  profileAvatar,
}

extension EntityMediaTypeExtension on EntityMediaType {
  String get value {
    switch (this) {
      case EntityMediaType.venueHero:
        return 'venue_hero';
      case EntityMediaType.venueGallery:
        return 'venue_gallery';
      case EntityMediaType.specialistPhoto:
        return 'specialist_photo';
      case EntityMediaType.specialistCertificate:
        return 'specialist_certificate';
      case EntityMediaType.profileAvatar:
        return 'profile_avatar';
    }
  }

  static EntityMediaType fromString(String value) {
    switch (value) {
      case 'venue_hero':
        return EntityMediaType.venueHero;
      case 'venue_gallery':
        return EntityMediaType.venueGallery;
      case 'specialist_photo':
        return EntityMediaType.specialistPhoto;
      case 'specialist_certificate':
        return EntityMediaType.specialistCertificate;
      case 'profile_avatar':
        return EntityMediaType.profileAvatar;
      default:
        throw ArgumentError('Unknown EntityMediaType: $value');
    }
  }
}

/// Helper class for media with full URL
@freezed
class MediaWithUrl with _$MediaWithUrl {
  const MediaWithUrl._();

  const factory MediaWithUrl({
    required String id,
    required String storagePath,
    String? mimeType,
    int? sizeBytes,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    DateTime? updatedAt,
    bool? isPrimary,
    int? sortOrder,
  }) = _MediaWithUrl;

  factory MediaWithUrl.fromJson(Map<String, dynamic> json) =>
      _$MediaWithUrlFromJson(json);

  factory MediaWithUrl.fromMedia(
    MediaModel media, {
    bool? isPrimary,
    int? sortOrder,
  }) {
    return MediaWithUrl(
      id: media.id,
      storagePath: media.storagePath,
      mimeType: media.mimeType,
      sizeBytes: media.sizeBytes,
      metadata: media.metadata,
      createdAt: media.createdAt,
      updatedAt: media.updatedAt,
      isPrimary: isPrimary,
      sortOrder: sortOrder,
    );
  }

  /// Get the full storage URL
  String getUrl([String? _]) {
    return 'https://guzellikharitam.com/storage/media/$storagePath';
  }

  /// Get alt text from metadata
  String? get altText => metadata?['alt_text'] as String?;

  /// Get blurhash from metadata
  String? get blurhash => metadata?['blurhash'] as String?;

  /// Get width from metadata
  int? get width => metadata?['width'] as int?;

  /// Get height from metadata
  int? get height => metadata?['height'] as int?;
}
