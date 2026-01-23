// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditLogModel {

 String get id; String get tableName; String get recordId; AuditAction get action; Map<String, dynamic>? get oldData; Map<String, dynamic>? get newData; List<String>? get changedFields; String? get actorId; String? get actorEmail; String? get ipAddress; String? get userAgent; DateTime get createdAt;
/// Create a copy of AuditLogModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogModelCopyWith<AuditLogModel> get copyWith => _$AuditLogModelCopyWithImpl<AuditLogModel>(this as AuditLogModel, _$identity);

  /// Serializes this AuditLogModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.recordId, recordId) || other.recordId == recordId)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other.oldData, oldData)&&const DeepCollectionEquality().equals(other.newData, newData)&&const DeepCollectionEquality().equals(other.changedFields, changedFields)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actorEmail, actorEmail) || other.actorEmail == actorEmail)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tableName,recordId,action,const DeepCollectionEquality().hash(oldData),const DeepCollectionEquality().hash(newData),const DeepCollectionEquality().hash(changedFields),actorId,actorEmail,ipAddress,userAgent,createdAt);

@override
String toString() {
  return 'AuditLogModel(id: $id, tableName: $tableName, recordId: $recordId, action: $action, oldData: $oldData, newData: $newData, changedFields: $changedFields, actorId: $actorId, actorEmail: $actorEmail, ipAddress: $ipAddress, userAgent: $userAgent, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AuditLogModelCopyWith<$Res>  {
  factory $AuditLogModelCopyWith(AuditLogModel value, $Res Function(AuditLogModel) _then) = _$AuditLogModelCopyWithImpl;
@useResult
$Res call({
 String id, String tableName, String recordId, AuditAction action, Map<String, dynamic>? oldData, Map<String, dynamic>? newData, List<String>? changedFields, String? actorId, String? actorEmail, String? ipAddress, String? userAgent, DateTime createdAt
});




}
/// @nodoc
class _$AuditLogModelCopyWithImpl<$Res>
    implements $AuditLogModelCopyWith<$Res> {
  _$AuditLogModelCopyWithImpl(this._self, this._then);

  final AuditLogModel _self;
  final $Res Function(AuditLogModel) _then;

/// Create a copy of AuditLogModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tableName = null,Object? recordId = null,Object? action = null,Object? oldData = freezed,Object? newData = freezed,Object? changedFields = freezed,Object? actorId = freezed,Object? actorEmail = freezed,Object? ipAddress = freezed,Object? userAgent = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,recordId: null == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,oldData: freezed == oldData ? _self.oldData : oldData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,newData: freezed == newData ? _self.newData : newData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,changedFields: freezed == changedFields ? _self.changedFields : changedFields // ignore: cast_nullable_to_non_nullable
as List<String>?,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,actorEmail: freezed == actorEmail ? _self.actorEmail : actorEmail // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogModel].
extension AuditLogModelPatterns on AuditLogModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogModel value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogModel value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tableName,  String recordId,  AuditAction action,  Map<String, dynamic>? oldData,  Map<String, dynamic>? newData,  List<String>? changedFields,  String? actorId,  String? actorEmail,  String? ipAddress,  String? userAgent,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogModel() when $default != null:
return $default(_that.id,_that.tableName,_that.recordId,_that.action,_that.oldData,_that.newData,_that.changedFields,_that.actorId,_that.actorEmail,_that.ipAddress,_that.userAgent,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tableName,  String recordId,  AuditAction action,  Map<String, dynamic>? oldData,  Map<String, dynamic>? newData,  List<String>? changedFields,  String? actorId,  String? actorEmail,  String? ipAddress,  String? userAgent,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AuditLogModel():
return $default(_that.id,_that.tableName,_that.recordId,_that.action,_that.oldData,_that.newData,_that.changedFields,_that.actorId,_that.actorEmail,_that.ipAddress,_that.userAgent,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tableName,  String recordId,  AuditAction action,  Map<String, dynamic>? oldData,  Map<String, dynamic>? newData,  List<String>? changedFields,  String? actorId,  String? actorEmail,  String? ipAddress,  String? userAgent,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogModel() when $default != null:
return $default(_that.id,_that.tableName,_that.recordId,_that.action,_that.oldData,_that.newData,_that.changedFields,_that.actorId,_that.actorEmail,_that.ipAddress,_that.userAgent,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLogModel extends AuditLogModel {
  const _AuditLogModel({required this.id, required this.tableName, required this.recordId, required this.action, final  Map<String, dynamic>? oldData, final  Map<String, dynamic>? newData, final  List<String>? changedFields, this.actorId, this.actorEmail, this.ipAddress, this.userAgent, required this.createdAt}): _oldData = oldData,_newData = newData,_changedFields = changedFields,super._();
  factory _AuditLogModel.fromJson(Map<String, dynamic> json) => _$AuditLogModelFromJson(json);

@override final  String id;
@override final  String tableName;
@override final  String recordId;
@override final  AuditAction action;
 final  Map<String, dynamic>? _oldData;
@override Map<String, dynamic>? get oldData {
  final value = _oldData;
  if (value == null) return null;
  if (_oldData is EqualUnmodifiableMapView) return _oldData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _newData;
@override Map<String, dynamic>? get newData {
  final value = _newData;
  if (value == null) return null;
  if (_newData is EqualUnmodifiableMapView) return _newData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _changedFields;
@override List<String>? get changedFields {
  final value = _changedFields;
  if (value == null) return null;
  if (_changedFields is EqualUnmodifiableListView) return _changedFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? actorId;
@override final  String? actorEmail;
@override final  String? ipAddress;
@override final  String? userAgent;
@override final  DateTime createdAt;

/// Create a copy of AuditLogModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogModelCopyWith<_AuditLogModel> get copyWith => __$AuditLogModelCopyWithImpl<_AuditLogModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.recordId, recordId) || other.recordId == recordId)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other._oldData, _oldData)&&const DeepCollectionEquality().equals(other._newData, _newData)&&const DeepCollectionEquality().equals(other._changedFields, _changedFields)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actorEmail, actorEmail) || other.actorEmail == actorEmail)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tableName,recordId,action,const DeepCollectionEquality().hash(_oldData),const DeepCollectionEquality().hash(_newData),const DeepCollectionEquality().hash(_changedFields),actorId,actorEmail,ipAddress,userAgent,createdAt);

@override
String toString() {
  return 'AuditLogModel(id: $id, tableName: $tableName, recordId: $recordId, action: $action, oldData: $oldData, newData: $newData, changedFields: $changedFields, actorId: $actorId, actorEmail: $actorEmail, ipAddress: $ipAddress, userAgent: $userAgent, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AuditLogModelCopyWith<$Res> implements $AuditLogModelCopyWith<$Res> {
  factory _$AuditLogModelCopyWith(_AuditLogModel value, $Res Function(_AuditLogModel) _then) = __$AuditLogModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String tableName, String recordId, AuditAction action, Map<String, dynamic>? oldData, Map<String, dynamic>? newData, List<String>? changedFields, String? actorId, String? actorEmail, String? ipAddress, String? userAgent, DateTime createdAt
});




}
/// @nodoc
class __$AuditLogModelCopyWithImpl<$Res>
    implements _$AuditLogModelCopyWith<$Res> {
  __$AuditLogModelCopyWithImpl(this._self, this._then);

  final _AuditLogModel _self;
  final $Res Function(_AuditLogModel) _then;

/// Create a copy of AuditLogModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tableName = null,Object? recordId = null,Object? action = null,Object? oldData = freezed,Object? newData = freezed,Object? changedFields = freezed,Object? actorId = freezed,Object? actorEmail = freezed,Object? ipAddress = freezed,Object? userAgent = freezed,Object? createdAt = null,}) {
  return _then(_AuditLogModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,recordId: null == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,oldData: freezed == oldData ? _self._oldData : oldData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,newData: freezed == newData ? _self._newData : newData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,changedFields: freezed == changedFields ? _self._changedFields : changedFields // ignore: cast_nullable_to_non_nullable
as List<String>?,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,actorEmail: freezed == actorEmail ? _self.actorEmail : actorEmail // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AuditLogSummary {

 String get id; String get tableName; String get recordId; AuditAction get action; List<String>? get changedFields; String? get actorEmail; DateTime get createdAt; String? get entityName; String? get changeSummary;
/// Create a copy of AuditLogSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogSummaryCopyWith<AuditLogSummary> get copyWith => _$AuditLogSummaryCopyWithImpl<AuditLogSummary>(this as AuditLogSummary, _$identity);

  /// Serializes this AuditLogSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.recordId, recordId) || other.recordId == recordId)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other.changedFields, changedFields)&&(identical(other.actorEmail, actorEmail) || other.actorEmail == actorEmail)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.entityName, entityName) || other.entityName == entityName)&&(identical(other.changeSummary, changeSummary) || other.changeSummary == changeSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tableName,recordId,action,const DeepCollectionEquality().hash(changedFields),actorEmail,createdAt,entityName,changeSummary);

@override
String toString() {
  return 'AuditLogSummary(id: $id, tableName: $tableName, recordId: $recordId, action: $action, changedFields: $changedFields, actorEmail: $actorEmail, createdAt: $createdAt, entityName: $entityName, changeSummary: $changeSummary)';
}


}

/// @nodoc
abstract mixin class $AuditLogSummaryCopyWith<$Res>  {
  factory $AuditLogSummaryCopyWith(AuditLogSummary value, $Res Function(AuditLogSummary) _then) = _$AuditLogSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String tableName, String recordId, AuditAction action, List<String>? changedFields, String? actorEmail, DateTime createdAt, String? entityName, String? changeSummary
});




}
/// @nodoc
class _$AuditLogSummaryCopyWithImpl<$Res>
    implements $AuditLogSummaryCopyWith<$Res> {
  _$AuditLogSummaryCopyWithImpl(this._self, this._then);

  final AuditLogSummary _self;
  final $Res Function(AuditLogSummary) _then;

/// Create a copy of AuditLogSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tableName = null,Object? recordId = null,Object? action = null,Object? changedFields = freezed,Object? actorEmail = freezed,Object? createdAt = null,Object? entityName = freezed,Object? changeSummary = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,recordId: null == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,changedFields: freezed == changedFields ? _self.changedFields : changedFields // ignore: cast_nullable_to_non_nullable
as List<String>?,actorEmail: freezed == actorEmail ? _self.actorEmail : actorEmail // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,entityName: freezed == entityName ? _self.entityName : entityName // ignore: cast_nullable_to_non_nullable
as String?,changeSummary: freezed == changeSummary ? _self.changeSummary : changeSummary // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogSummary].
extension AuditLogSummaryPatterns on AuditLogSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogSummary value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tableName,  String recordId,  AuditAction action,  List<String>? changedFields,  String? actorEmail,  DateTime createdAt,  String? entityName,  String? changeSummary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogSummary() when $default != null:
return $default(_that.id,_that.tableName,_that.recordId,_that.action,_that.changedFields,_that.actorEmail,_that.createdAt,_that.entityName,_that.changeSummary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tableName,  String recordId,  AuditAction action,  List<String>? changedFields,  String? actorEmail,  DateTime createdAt,  String? entityName,  String? changeSummary)  $default,) {final _that = this;
switch (_that) {
case _AuditLogSummary():
return $default(_that.id,_that.tableName,_that.recordId,_that.action,_that.changedFields,_that.actorEmail,_that.createdAt,_that.entityName,_that.changeSummary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tableName,  String recordId,  AuditAction action,  List<String>? changedFields,  String? actorEmail,  DateTime createdAt,  String? entityName,  String? changeSummary)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogSummary() when $default != null:
return $default(_that.id,_that.tableName,_that.recordId,_that.action,_that.changedFields,_that.actorEmail,_that.createdAt,_that.entityName,_that.changeSummary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLogSummary implements AuditLogSummary {
  const _AuditLogSummary({required this.id, required this.tableName, required this.recordId, required this.action, final  List<String>? changedFields, this.actorEmail, required this.createdAt, this.entityName, this.changeSummary}): _changedFields = changedFields;
  factory _AuditLogSummary.fromJson(Map<String, dynamic> json) => _$AuditLogSummaryFromJson(json);

@override final  String id;
@override final  String tableName;
@override final  String recordId;
@override final  AuditAction action;
 final  List<String>? _changedFields;
@override List<String>? get changedFields {
  final value = _changedFields;
  if (value == null) return null;
  if (_changedFields is EqualUnmodifiableListView) return _changedFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? actorEmail;
@override final  DateTime createdAt;
@override final  String? entityName;
@override final  String? changeSummary;

/// Create a copy of AuditLogSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogSummaryCopyWith<_AuditLogSummary> get copyWith => __$AuditLogSummaryCopyWithImpl<_AuditLogSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.recordId, recordId) || other.recordId == recordId)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other._changedFields, _changedFields)&&(identical(other.actorEmail, actorEmail) || other.actorEmail == actorEmail)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.entityName, entityName) || other.entityName == entityName)&&(identical(other.changeSummary, changeSummary) || other.changeSummary == changeSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tableName,recordId,action,const DeepCollectionEquality().hash(_changedFields),actorEmail,createdAt,entityName,changeSummary);

@override
String toString() {
  return 'AuditLogSummary(id: $id, tableName: $tableName, recordId: $recordId, action: $action, changedFields: $changedFields, actorEmail: $actorEmail, createdAt: $createdAt, entityName: $entityName, changeSummary: $changeSummary)';
}


}

/// @nodoc
abstract mixin class _$AuditLogSummaryCopyWith<$Res> implements $AuditLogSummaryCopyWith<$Res> {
  factory _$AuditLogSummaryCopyWith(_AuditLogSummary value, $Res Function(_AuditLogSummary) _then) = __$AuditLogSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String tableName, String recordId, AuditAction action, List<String>? changedFields, String? actorEmail, DateTime createdAt, String? entityName, String? changeSummary
});




}
/// @nodoc
class __$AuditLogSummaryCopyWithImpl<$Res>
    implements _$AuditLogSummaryCopyWith<$Res> {
  __$AuditLogSummaryCopyWithImpl(this._self, this._then);

  final _AuditLogSummary _self;
  final $Res Function(_AuditLogSummary) _then;

/// Create a copy of AuditLogSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tableName = null,Object? recordId = null,Object? action = null,Object? changedFields = freezed,Object? actorEmail = freezed,Object? createdAt = null,Object? entityName = freezed,Object? changeSummary = freezed,}) {
  return _then(_AuditLogSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,recordId: null == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,changedFields: freezed == changedFields ? _self._changedFields : changedFields // ignore: cast_nullable_to_non_nullable
as List<String>?,actorEmail: freezed == actorEmail ? _self.actorEmail : actorEmail // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,entityName: freezed == entityName ? _self.entityName : entityName // ignore: cast_nullable_to_non_nullable
as String?,changeSummary: freezed == changeSummary ? _self.changeSummary : changeSummary // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
