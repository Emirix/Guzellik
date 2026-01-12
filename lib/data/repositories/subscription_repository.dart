import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_subscription.dart';

/// Repository for subscription-related operations
class SubscriptionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get subscription for a profile
  Future<BusinessSubscription?> getSubscription(String profileId) async {
    try {
      final response = await _supabase
          .from('venues_subscription')
          .select('*, venues!inner(owner_id)')
          .eq('venues.owner_id', profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return BusinessSubscription.fromJson(response);
    } catch (e) {
      print('Error getting subscription: $e');
      return null;
    }
  }

  /// Check if profile has access to a feature
  Future<bool> checkFeatureAccess(String profileId, String feature) async {
    try {
      final subscription = await getSubscription(profileId);
      if (subscription == null || !subscription.isActive) return false;

      return subscription.hasFeature(feature);
    } catch (e) {
      print('Error checking feature access: $e');
      return false;
    }
  }

  /// Get feature limit for a profile
  Future<int> getFeatureLimit(
    String profileId,
    String feature,
    String limitKey,
  ) async {
    try {
      final subscription = await getSubscription(profileId);
      if (subscription == null || !subscription.isActive) return 0;

      return subscription.getFeatureLimit(feature, limitKey);
    } catch (e) {
      print('Error getting feature limit: $e');
      return 0;
    }
  }

  /// Update subscription status
  Future<bool> updateSubscriptionStatus(
    String subscriptionId,
    String status,
  ) async {
    try {
      await _supabase
          .from('venues_subscription')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', subscriptionId);
      return true;
    } catch (e) {
      print('Error updating subscription status: $e');
      return false;
    }
  }

  /// Extend subscription expiry date
  Future<bool> extendSubscription(
    String subscriptionId,
    DateTime newExpiryDate,
  ) async {
    try {
      await _supabase
          .from('venues_subscription')
          .update({
            'expires_at': newExpiryDate.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', subscriptionId);
      return true;
    } catch (e) {
      print('Error extending subscription: $e');
      return false;
    }
  }
}
