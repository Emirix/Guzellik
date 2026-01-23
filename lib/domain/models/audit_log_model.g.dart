// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLogModel _$AuditLogModelFromJson(Map<String, dynamic> json) =>
    _AuditLogModel(
      id: json['id'] as String,
      tableName: json['tableName'] as String,
      recordId: json['recordId'] as String,
      action: $enumDecode(_$AuditActionEnumMap, json['action']),
      oldData: json['oldData'] as Map<String, dynamic>?,
      newData: json['newData'] as Map<String, dynamic>?,
      changedFields: (json['changedFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      actorId: json['actorId'] as String?,
      actorEmail: json['actorEmail'] as String?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AuditLogModelToJson(_AuditLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tableName': instance.tableName,
      'recordId': instance.recordId,
      'action': _$AuditActionEnumMap[instance.action]!,
      'oldData': instance.oldData,
      'newData': instance.newData,
      'changedFields': instance.changedFields,
      'actorId': instance.actorId,
      'actorEmail': instance.actorEmail,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AuditActionEnumMap = {
  AuditAction.insert: 'INSERT',
  AuditAction.update: 'UPDATE',
  AuditAction.delete: 'DELETE',
};

_AuditLogSummary _$AuditLogSummaryFromJson(Map<String, dynamic> json) =>
    _AuditLogSummary(
      id: json['id'] as String,
      tableName: json['tableName'] as String,
      recordId: json['recordId'] as String,
      action: $enumDecode(_$AuditActionEnumMap, json['action']),
      changedFields: (json['changedFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      actorEmail: json['actorEmail'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      entityName: json['entityName'] as String?,
      changeSummary: json['changeSummary'] as String?,
    );

Map<String, dynamic> _$AuditLogSummaryToJson(_AuditLogSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tableName': instance.tableName,
      'recordId': instance.recordId,
      'action': _$AuditActionEnumMap[instance.action]!,
      'changedFields': instance.changedFields,
      'actorEmail': instance.actorEmail,
      'createdAt': instance.createdAt.toIso8601String(),
      'entityName': instance.entityName,
      'changeSummary': instance.changeSummary,
    };
