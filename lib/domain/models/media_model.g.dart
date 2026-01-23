// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaModel _$MediaModelFromJson(Map<String, dynamic> json) => _MediaModel(
  id: json['id'] as String,
  storagePath: json['storagePath'] as String,
  mimeType: json['mimeType'] as String?,
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MediaModelToJson(_MediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storagePath': instance.storagePath,
      'mimeType': instance.mimeType,
      'sizeBytes': instance.sizeBytes,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_EntityMediaModel _$EntityMediaModelFromJson(Map<String, dynamic> json) =>
    _EntityMediaModel(
      id: json['id'] as String,
      mediaId: json['mediaId'] as String,
      entityId: json['entityId'] as String,
      entityType: $enumDecode(_$EntityMediaTypeEnumMap, json['entityType']),
      isPrimary: json['isPrimary'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: json['media'] == null
          ? null
          : MediaModel.fromJson(json['media'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EntityMediaModelToJson(_EntityMediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mediaId': instance.mediaId,
      'entityId': instance.entityId,
      'entityType': _$EntityMediaTypeEnumMap[instance.entityType]!,
      'isPrimary': instance.isPrimary,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'media': instance.media,
    };

const _$EntityMediaTypeEnumMap = {
  EntityMediaType.venueHero: 'venue_hero',
  EntityMediaType.venueGallery: 'venue_gallery',
  EntityMediaType.specialistPhoto: 'specialist_photo',
  EntityMediaType.specialistCertificate: 'specialist_certificate',
  EntityMediaType.profileAvatar: 'profile_avatar',
};

_MediaWithUrl _$MediaWithUrlFromJson(Map<String, dynamic> json) =>
    _MediaWithUrl(
      id: json['id'] as String,
      storagePath: json['storagePath'] as String,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isPrimary: json['isPrimary'] as bool?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MediaWithUrlToJson(_MediaWithUrl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storagePath': instance.storagePath,
      'mimeType': instance.mimeType,
      'sizeBytes': instance.sizeBytes,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isPrimary': instance.isPrimary,
      'sortOrder': instance.sortOrder,
    };
