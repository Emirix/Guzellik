import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log_model.freezed.dart';
part 'audit_log_model.g.dart';

/// Represents an audit log entry for tracking data changes
@freezed
class AuditLogModel with _$AuditLogModel {
  const AuditLogModel._();

  const factory AuditLogModel({
    required String id,
    required String tableName,
    required String recordId,
    required AuditAction action,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    List<String>? changedFields,
    String? actorId,
    String? actorEmail,
    String? ipAddress,
    String? userAgent,
    required DateTime createdAt,
  }) = _AuditLogModel;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$AuditLogModelFromJson(json);

  /// Get a human-readable summary of the change
  String get changeSummary {
    switch (action) {
      case AuditAction.insert:
        return 'Oluşturuldu';
      case AuditAction.delete:
        return 'Silindi';
      case AuditAction.update:
        if (changedFields != null && changedFields!.isNotEmpty) {
          return 'Güncellendi: ${changedFields!.join(', ')}';
        }
        return 'Güncellendi';
    }
  }

  /// Get the entity name if available
  String? get entityName {
    if (tableName == 'venues') {
      return newData?['name'] as String? ?? oldData?['name'] as String?;
    }
    return null;
  }

  /// Get a specific field change
  FieldChange? getFieldChange(String fieldName) {
    if (action != AuditAction.update) return null;
    if (changedFields == null || !changedFields!.contains(fieldName)) {
      return null;
    }

    return FieldChange(
      fieldName: fieldName,
      oldValue: oldData?[fieldName],
      newValue: newData?[fieldName],
    );
  }

  /// Get all field changes
  List<FieldChange> get allFieldChanges {
    if (action != AuditAction.update || changedFields == null) {
      return [];
    }

    return changedFields!
        .map(
          (field) => FieldChange(
            fieldName: field,
            oldValue: oldData?[field],
            newValue: newData?[field],
          ),
        )
        .toList();
  }

  /// Get a formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

/// Audit action types
enum AuditAction {
  @JsonValue('INSERT')
  insert,
  @JsonValue('UPDATE')
  update,
  @JsonValue('DELETE')
  delete,
}

extension AuditActionExtension on AuditAction {
  String get value {
    switch (this) {
      case AuditAction.insert:
        return 'INSERT';
      case AuditAction.update:
        return 'UPDATE';
      case AuditAction.delete:
        return 'DELETE';
    }
  }

  String get displayName {
    switch (this) {
      case AuditAction.insert:
        return 'Ekleme';
      case AuditAction.update:
        return 'Güncelleme';
      case AuditAction.delete:
        return 'Silme';
    }
  }

  static AuditAction fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INSERT':
        return AuditAction.insert;
      case 'UPDATE':
        return AuditAction.update;
      case 'DELETE':
        return AuditAction.delete;
      default:
        throw ArgumentError('Unknown AuditAction: $value');
    }
  }
}

/// Represents a single field change in an audit log
class FieldChange {
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;

  const FieldChange({required this.fieldName, this.oldValue, this.newValue});

  /// Get a human-readable field name
  String get displayName {
    // Convert snake_case to Title Case
    return fieldName
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  /// Get a formatted change description
  String get changeDescription {
    if (oldValue == null && newValue != null) {
      return '$displayName: "$newValue" olarak ayarlandı';
    } else if (oldValue != null && newValue == null) {
      return '$displayName: "$oldValue" kaldırıldı';
    } else {
      return '$displayName: "$oldValue" → "$newValue"';
    }
  }

  @override
  String toString() => changeDescription;
}

/// Summary view of audit logs
@freezed
class AuditLogSummary with _$AuditLogSummary {
  const factory AuditLogSummary({
    required String id,
    required String tableName,
    required String recordId,
    required AuditAction action,
    List<String>? changedFields,
    String? actorEmail,
    required DateTime createdAt,
    String? entityName,
    String? changeSummary,
  }) = _AuditLogSummary;

  factory AuditLogSummary.fromJson(Map<String, dynamic> json) =>
      _$AuditLogSummaryFromJson(json);

  factory AuditLogSummary.fromAuditLog(AuditLogModel log) {
    return AuditLogSummary(
      id: log.id,
      tableName: log.tableName,
      recordId: log.recordId,
      action: log.action,
      changedFields: log.changedFields,
      actorEmail: log.actorEmail,
      createdAt: log.createdAt,
      entityName: log.entityName,
      changeSummary: log.changeSummary,
    );
  }
}
