import 'package:flutter/foundation.dart';

/// Enum defining the available subscription tiers
enum SubscriptionTier {
  standard,
  premium,
  enterprise;

  String get value => name;

  static SubscriptionTier fromString(String? value) {
    return SubscriptionTier.values.firstWhere(
      (e) => e.name == value?.toLowerCase(),
      orElse: () => SubscriptionTier.standard,
    );
  }
}

/// Business subscription model
/// Represents a business account's subscription status and features
class BusinessSubscription {
  final String id;
  final String venueId;
  final SubscriptionTier tier;
  final String status;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> features;
  final int creditsBalance;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessSubscription({
    required this.id,
    required this.venueId,
    required this.tier,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    required this.features,
    this.creditsBalance = 0,
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
    switch (tier) {
      case SubscriptionTier.standard:
        return 'Standart Üyelik';
      case SubscriptionTier.premium:
        return 'Premium Üyelik';
      case SubscriptionTier.enterprise:
        return 'Kurumsal Üyelik';
    }
  }

  /// Check if a specific feature is enabled
  bool hasFeature(String featureName) {
    if (!features.containsKey(featureName)) return false;
    final feature = features[featureName];
    if (feature is bool) return feature;
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
      id: json['id']?.toString() ?? '',
      venueId:
          json['venue_id']?.toString() ??
          (json['profile_id']?.toString() ?? ''),
      tier: SubscriptionTier.fromString(json['subscription_type']?.toString()),
      status: json['status']?.toString() ?? 'active',
      startedAt: DateTime.parse(
        json['started_at'] ?? DateTime.now().toIso8601String(),
      ),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      features: json['features'] as Map<String, dynamic>? ?? {},
      creditsBalance: json['credits_balance'] as int? ?? 0,
      paymentMethod: json['payment_method'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'subscription_type': tier.name,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'features': features,
      'credits_balance': creditsBalance,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  BusinessSubscription copyWith({
    String? id,
    String? venueId,
    SubscriptionTier? tier,
    String? status,
    DateTime? startedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? features,
    int? creditsBalance,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessSubscription(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      features: features ?? this.features,
      creditsBalance: creditsBalance ?? this.creditsBalance,
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
        other.venueId == venueId &&
        other.tier == tier &&
        other.status == status &&
        other.startedAt == startedAt &&
        other.expiresAt == expiresAt &&
        mapEquals(other.features, features) &&
        other.creditsBalance == creditsBalance &&
        other.paymentMethod == paymentMethod &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      venueId,
      tier,
      status,
      startedAt,
      expiresAt,
      features,
      creditsBalance,
      paymentMethod,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'BusinessSubscription(id: $id, tier: ${tier.name}, status: $status, daysRemaining: $daysRemaining, creditsBalance: $creditsBalance)';
  }
}
