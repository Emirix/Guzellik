// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaModel {

 String get id; String get storagePath; String? get mimeType; int? get sizeBytes; Map<String, dynamic>? get metadata; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of MediaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaModelCopyWith<MediaModel> get copyWith => _$MediaModelCopyWithImpl<MediaModel>(this as MediaModel, _$identity);

  /// Serializes this MediaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storagePath,mimeType,sizeBytes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt);

@override
String toString() {
  return 'MediaModel(id: $id, storagePath: $storagePath, mimeType: $mimeType, sizeBytes: $sizeBytes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MediaModelCopyWith<$Res>  {
  factory $MediaModelCopyWith(MediaModel value, $Res Function(MediaModel) _then) = _$MediaModelCopyWithImpl;
@useResult
$Res call({
 String id, String storagePath, String? mimeType, int? sizeBytes, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$MediaModelCopyWithImpl<$Res>
    implements $MediaModelCopyWith<$Res> {
  _$MediaModelCopyWithImpl(this._self, this._then);

  final MediaModel _self;
  final $Res Function(MediaModel) _then;

/// Create a copy of MediaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storagePath = null,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaModel].
extension MediaModelPatterns on MediaModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaModel value)  $default,){
final _that = this;
switch (_that) {
case _MediaModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaModel value)?  $default,){
final _that = this;
switch (_that) {
case _MediaModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String storagePath,  String? mimeType,  int? sizeBytes,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaModel() when $default != null:
return $default(_that.id,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String storagePath,  String? mimeType,  int? sizeBytes,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MediaModel():
return $default(_that.id,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String storagePath,  String? mimeType,  int? sizeBytes,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MediaModel() when $default != null:
return $default(_that.id,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaModel implements MediaModel {
  const _MediaModel({required this.id, required this.storagePath, this.mimeType, this.sizeBytes, final  Map<String, dynamic>? metadata, required this.createdAt, this.updatedAt}): _metadata = metadata;
  factory _MediaModel.fromJson(Map<String, dynamic> json) => _$MediaModelFromJson(json);

@override final  String id;
@override final  String storagePath;
@override final  String? mimeType;
@override final  int? sizeBytes;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of MediaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaModelCopyWith<_MediaModel> get copyWith => __$MediaModelCopyWithImpl<_MediaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storagePath,mimeType,sizeBytes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt);

@override
String toString() {
  return 'MediaModel(id: $id, storagePath: $storagePath, mimeType: $mimeType, sizeBytes: $sizeBytes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MediaModelCopyWith<$Res> implements $MediaModelCopyWith<$Res> {
  factory _$MediaModelCopyWith(_MediaModel value, $Res Function(_MediaModel) _then) = __$MediaModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String storagePath, String? mimeType, int? sizeBytes, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$MediaModelCopyWithImpl<$Res>
    implements _$MediaModelCopyWith<$Res> {
  __$MediaModelCopyWithImpl(this._self, this._then);

  final _MediaModel _self;
  final $Res Function(_MediaModel) _then;

/// Create a copy of MediaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storagePath = null,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_MediaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EntityMediaModel {

 String get id; String get mediaId; String get entityId; EntityMediaType get entityType; bool get isPrimary; int get sortOrder; DateTime get createdAt;// Populated via join
 MediaModel? get media;
/// Create a copy of EntityMediaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntityMediaModelCopyWith<EntityMediaModel> get copyWith => _$EntityMediaModelCopyWithImpl<EntityMediaModel>(this as EntityMediaModel, _$identity);

  /// Serializes this EntityMediaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntityMediaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.media, media) || other.media == media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaId,entityId,entityType,isPrimary,sortOrder,createdAt,media);

@override
String toString() {
  return 'EntityMediaModel(id: $id, mediaId: $mediaId, entityId: $entityId, entityType: $entityType, isPrimary: $isPrimary, sortOrder: $sortOrder, createdAt: $createdAt, media: $media)';
}


}

/// @nodoc
abstract mixin class $EntityMediaModelCopyWith<$Res>  {
  factory $EntityMediaModelCopyWith(EntityMediaModel value, $Res Function(EntityMediaModel) _then) = _$EntityMediaModelCopyWithImpl;
@useResult
$Res call({
 String id, String mediaId, String entityId, EntityMediaType entityType, bool isPrimary, int sortOrder, DateTime createdAt, MediaModel? media
});


$MediaModelCopyWith<$Res>? get media;

}
/// @nodoc
class _$EntityMediaModelCopyWithImpl<$Res>
    implements $EntityMediaModelCopyWith<$Res> {
  _$EntityMediaModelCopyWithImpl(this._self, this._then);

  final EntityMediaModel _self;
  final $Res Function(EntityMediaModel) _then;

/// Create a copy of EntityMediaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? mediaId = null,Object? entityId = null,Object? entityType = null,Object? isPrimary = null,Object? sortOrder = null,Object? createdAt = null,Object? media = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as EntityMediaType,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,media: freezed == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as MediaModel?,
  ));
}
/// Create a copy of EntityMediaModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaModelCopyWith<$Res>? get media {
    if (_self.media == null) {
    return null;
  }

  return $MediaModelCopyWith<$Res>(_self.media!, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}


/// Adds pattern-matching-related methods to [EntityMediaModel].
extension EntityMediaModelPatterns on EntityMediaModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntityMediaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntityMediaModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntityMediaModel value)  $default,){
final _that = this;
switch (_that) {
case _EntityMediaModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntityMediaModel value)?  $default,){
final _that = this;
switch (_that) {
case _EntityMediaModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String mediaId,  String entityId,  EntityMediaType entityType,  bool isPrimary,  int sortOrder,  DateTime createdAt,  MediaModel? media)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntityMediaModel() when $default != null:
return $default(_that.id,_that.mediaId,_that.entityId,_that.entityType,_that.isPrimary,_that.sortOrder,_that.createdAt,_that.media);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String mediaId,  String entityId,  EntityMediaType entityType,  bool isPrimary,  int sortOrder,  DateTime createdAt,  MediaModel? media)  $default,) {final _that = this;
switch (_that) {
case _EntityMediaModel():
return $default(_that.id,_that.mediaId,_that.entityId,_that.entityType,_that.isPrimary,_that.sortOrder,_that.createdAt,_that.media);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String mediaId,  String entityId,  EntityMediaType entityType,  bool isPrimary,  int sortOrder,  DateTime createdAt,  MediaModel? media)?  $default,) {final _that = this;
switch (_that) {
case _EntityMediaModel() when $default != null:
return $default(_that.id,_that.mediaId,_that.entityId,_that.entityType,_that.isPrimary,_that.sortOrder,_that.createdAt,_that.media);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntityMediaModel implements EntityMediaModel {
  const _EntityMediaModel({required this.id, required this.mediaId, required this.entityId, required this.entityType, this.isPrimary = false, this.sortOrder = 0, required this.createdAt, this.media});
  factory _EntityMediaModel.fromJson(Map<String, dynamic> json) => _$EntityMediaModelFromJson(json);

@override final  String id;
@override final  String mediaId;
@override final  String entityId;
@override final  EntityMediaType entityType;
@override@JsonKey() final  bool isPrimary;
@override@JsonKey() final  int sortOrder;
@override final  DateTime createdAt;
// Populated via join
@override final  MediaModel? media;

/// Create a copy of EntityMediaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntityMediaModelCopyWith<_EntityMediaModel> get copyWith => __$EntityMediaModelCopyWithImpl<_EntityMediaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntityMediaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntityMediaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.media, media) || other.media == media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaId,entityId,entityType,isPrimary,sortOrder,createdAt,media);

@override
String toString() {
  return 'EntityMediaModel(id: $id, mediaId: $mediaId, entityId: $entityId, entityType: $entityType, isPrimary: $isPrimary, sortOrder: $sortOrder, createdAt: $createdAt, media: $media)';
}


}

/// @nodoc
abstract mixin class _$EntityMediaModelCopyWith<$Res> implements $EntityMediaModelCopyWith<$Res> {
  factory _$EntityMediaModelCopyWith(_EntityMediaModel value, $Res Function(_EntityMediaModel) _then) = __$EntityMediaModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String mediaId, String entityId, EntityMediaType entityType, bool isPrimary, int sortOrder, DateTime createdAt, MediaModel? media
});


@override $MediaModelCopyWith<$Res>? get media;

}
/// @nodoc
class __$EntityMediaModelCopyWithImpl<$Res>
    implements _$EntityMediaModelCopyWith<$Res> {
  __$EntityMediaModelCopyWithImpl(this._self, this._then);

  final _EntityMediaModel _self;
  final $Res Function(_EntityMediaModel) _then;

/// Create a copy of EntityMediaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mediaId = null,Object? entityId = null,Object? entityType = null,Object? isPrimary = null,Object? sortOrder = null,Object? createdAt = null,Object? media = freezed,}) {
  return _then(_EntityMediaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as EntityMediaType,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,media: freezed == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as MediaModel?,
  ));
}

/// Create a copy of EntityMediaModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaModelCopyWith<$Res>? get media {
    if (_self.media == null) {
    return null;
  }

  return $MediaModelCopyWith<$Res>(_self.media!, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}


/// @nodoc
mixin _$MediaWithUrl {

 String get id; String get storagePath; String? get mimeType; int? get sizeBytes; Map<String, dynamic>? get metadata; DateTime get createdAt; DateTime? get updatedAt; bool? get isPrimary; int? get sortOrder;
/// Create a copy of MediaWithUrl
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaWithUrlCopyWith<MediaWithUrl> get copyWith => _$MediaWithUrlCopyWithImpl<MediaWithUrl>(this as MediaWithUrl, _$identity);

  /// Serializes this MediaWithUrl to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaWithUrl&&(identical(other.id, id) || other.id == id)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storagePath,mimeType,sizeBytes,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt,isPrimary,sortOrder);

@override
String toString() {
  return 'MediaWithUrl(id: $id, storagePath: $storagePath, mimeType: $mimeType, sizeBytes: $sizeBytes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, isPrimary: $isPrimary, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $MediaWithUrlCopyWith<$Res>  {
  factory $MediaWithUrlCopyWith(MediaWithUrl value, $Res Function(MediaWithUrl) _then) = _$MediaWithUrlCopyWithImpl;
@useResult
$Res call({
 String id, String storagePath, String? mimeType, int? sizeBytes, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? updatedAt, bool? isPrimary, int? sortOrder
});




}
/// @nodoc
class _$MediaWithUrlCopyWithImpl<$Res>
    implements $MediaWithUrlCopyWith<$Res> {
  _$MediaWithUrlCopyWithImpl(this._self, this._then);

  final MediaWithUrl _self;
  final $Res Function(MediaWithUrl) _then;

/// Create a copy of MediaWithUrl
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storagePath = null,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? isPrimary = freezed,Object? sortOrder = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPrimary: freezed == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool?,sortOrder: freezed == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaWithUrl].
extension MediaWithUrlPatterns on MediaWithUrl {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaWithUrl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaWithUrl() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaWithUrl value)  $default,){
final _that = this;
switch (_that) {
case _MediaWithUrl():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaWithUrl value)?  $default,){
final _that = this;
switch (_that) {
case _MediaWithUrl() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String storagePath,  String? mimeType,  int? sizeBytes,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? updatedAt,  bool? isPrimary,  int? sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaWithUrl() when $default != null:
return $default(_that.id,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.metadata,_that.createdAt,_that.updatedAt,_that.isPrimary,_that.sortOrder);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String storagePath,  String? mimeType,  int? sizeBytes,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? updatedAt,  bool? isPrimary,  int? sortOrder)  $default,) {final _that = this;
switch (_that) {
case _MediaWithUrl():
return $default(_that.id,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.metadata,_that.createdAt,_that.updatedAt,_that.isPrimary,_that.sortOrder);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String storagePath,  String? mimeType,  int? sizeBytes,  Map<String, dynamic>? metadata,  DateTime createdAt,  DateTime? updatedAt,  bool? isPrimary,  int? sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _MediaWithUrl() when $default != null:
return $default(_that.id,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.metadata,_that.createdAt,_that.updatedAt,_that.isPrimary,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaWithUrl extends MediaWithUrl {
  const _MediaWithUrl({required this.id, required this.storagePath, this.mimeType, this.sizeBytes, final  Map<String, dynamic>? metadata, required this.createdAt, this.updatedAt, this.isPrimary, this.sortOrder}): _metadata = metadata,super._();
  factory _MediaWithUrl.fromJson(Map<String, dynamic> json) => _$MediaWithUrlFromJson(json);

@override final  String id;
@override final  String storagePath;
@override final  String? mimeType;
@override final  int? sizeBytes;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override final  bool? isPrimary;
@override final  int? sortOrder;

/// Create a copy of MediaWithUrl
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaWithUrlCopyWith<_MediaWithUrl> get copyWith => __$MediaWithUrlCopyWithImpl<_MediaWithUrl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaWithUrlToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaWithUrl&&(identical(other.id, id) || other.id == id)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storagePath,mimeType,sizeBytes,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt,isPrimary,sortOrder);

@override
String toString() {
  return 'MediaWithUrl(id: $id, storagePath: $storagePath, mimeType: $mimeType, sizeBytes: $sizeBytes, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, isPrimary: $isPrimary, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$MediaWithUrlCopyWith<$Res> implements $MediaWithUrlCopyWith<$Res> {
  factory _$MediaWithUrlCopyWith(_MediaWithUrl value, $Res Function(_MediaWithUrl) _then) = __$MediaWithUrlCopyWithImpl;
@override @useResult
$Res call({
 String id, String storagePath, String? mimeType, int? sizeBytes, Map<String, dynamic>? metadata, DateTime createdAt, DateTime? updatedAt, bool? isPrimary, int? sortOrder
});




}
/// @nodoc
class __$MediaWithUrlCopyWithImpl<$Res>
    implements _$MediaWithUrlCopyWith<$Res> {
  __$MediaWithUrlCopyWithImpl(this._self, this._then);

  final _MediaWithUrl _self;
  final $Res Function(_MediaWithUrl) _then;

/// Create a copy of MediaWithUrl
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storagePath = null,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? isPrimary = freezed,Object? sortOrder = freezed,}) {
  return _then(_MediaWithUrl(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPrimary: freezed == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool?,sortOrder: freezed == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
