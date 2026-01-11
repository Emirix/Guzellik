import 'package:flutter/foundation.dart';

/// Business subscription model
/// Represents a business account's subscription status and features
class BusinessSubscription {
  final String id;
  final String profileId;
  final String subscriptionType;
  final String status;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> features;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessSubscription({
    required this.id,
    required this.profileId,
    required this.subscriptionType,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    required this.features,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if subscription is active
  bool get isActive => status == 'active';

  /// Check if subscription has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get days remaining until expiration
  int get daysRemaining {
    if (expiresAt == null) return -1; // -1 indicates no expiry
    final difference = expiresAt!.difference(DateTime.now());
    return difference.inDays;
  }

  /// Get subscription display name
  String get displayName {
    switch (subscriptionType) {
      case 'standard':
        return 'Standart Üyelik';
      case 'premium':
        return 'Premium Üyelik';
      case 'enterprise':
        return 'Kurumsal Üyelik';
      default:
        return 'Üyelik';
    }
  }

  /// Check if a specific feature is enabled
  bool hasFeature(String featureName) {
    if (!features.containsKey(featureName)) return false;
    final feature = features[featureName];
    if (feature is Map) {
      return feature['enabled'] == true;
    }
    return false;
  }

  /// Get feature limit (returns -1 for unlimited)
  int getFeatureLimit(String featureName, String limitKey) {
    if (!features.containsKey(featureName)) return 0;
    final feature = features[featureName];
    if (feature is Map && feature.containsKey(limitKey)) {
      final limit = feature[limitKey];
      if (limit is int) return limit;
      if (limit is String) return int.tryParse(limit) ?? 0;
    }
    return 0;
  }

  /// Create from JSON
  factory BusinessSubscription.fromJson(Map<String, dynamic> json) {
    return BusinessSubscription(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      subscriptionType: json['subscription_type'] as String,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      features: json['features'] as Map<String, dynamic>? ?? {},
      paymentMethod: json['payment_method'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'subscription_type': subscriptionType,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'features': features,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  BusinessSubscription copyWith({
    String? id,
    String? profileId,
    String? subscriptionType,
    String? status,
    DateTime? startedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? features,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessSubscription(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      features: features ?? this.features,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessSubscription &&
        other.id == id &&
        other.profileId == profileId &&
        other.subscriptionType == subscriptionType &&
        other.status == status &&
        other.startedAt == startedAt &&
        other.expiresAt == expiresAt &&
        mapEquals(other.features, features) &&
        other.paymentMethod == paymentMethod &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      profileId,
      subscriptionType,
      status,
      startedAt,
      expiresAt,
      features,
      paymentMethod,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'BusinessSubscription(id: $id, type: $subscriptionType, status: $status, daysRemaining: $daysRemaining)';
  }
}
