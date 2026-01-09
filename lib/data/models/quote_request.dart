import 'service_category.dart';

enum QuoteStatus {
  active,
  closed;

  static QuoteStatus fromString(String value) {
    if (value.toLowerCase() == 'closed') return QuoteStatus.closed;
    return QuoteStatus.active;
  }

  String get displayName {
    switch (this) {
      case QuoteStatus.active:
        return 'Yayında';
      case QuoteStatus.closed:
        return 'Kapandı';
    }
  }
}

class QuoteRequest {
  final String id;
  final String userId;
  final DateTime? preferredDate;
  final String? preferredTimeSlot;
  final String? notes;
  final int? provinceId;
  final String? districtId;
  final QuoteStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final List<ServiceCategory> services;
  final int responseCount;

  QuoteRequest({
    required this.id,
    required this.userId,
    this.preferredDate,
    this.preferredTimeSlot,
    this.notes,
    this.provinceId,
    this.districtId,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.services = const [],
    this.responseCount = 0,
  });

  factory QuoteRequest.fromJson(Map<String, dynamic> json) {
    return QuoteRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      preferredDate: json['preferred_date'] != null
          ? DateTime.parse(json['preferred_date'] as String)
          : null,
      preferredTimeSlot: json['preferred_time_slot'] as String?,
      notes: json['notes'] as String?,
      provinceId: json['province_id'] as int?,
      districtId: json['district_id'] as String?,
      status: QuoteStatus.fromString(json['status'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      responseCount: json['response_count'] as int? ?? 0,
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'preferred_date': preferredDate?.toIso8601String().split('T')[0],
      'preferred_time_slot': preferredTimeSlot,
      'notes': notes,
      'province_id': provinceId,
      'district_id': districtId,
      'status': status.name,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
