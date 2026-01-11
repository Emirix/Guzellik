import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_subscription.dart';
import '../../data/models/venue.dart';

/// Repository for business-related operations
class BusinessRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if user has a business account
  Future<bool> checkBusinessAccount(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('is_business_account')
          .eq('id', userId)
          .single();

      return response['is_business_account'] == true;
    } catch (e) {
      print('Error checking business account: $e');
      return false;
    }
  }

  /// Get business venue for a user
  Future<Venue?> getBusinessVenue(String userId) async {
    try {
      final response = await _supabase.rpc(
        'get_business_venue',
        params: {'p_profile_id': userId},
      );

      if (response == null || (response is List && response.isEmpty)) {
        return null;
      }

      final venueData = response is List ? response.first : response;
      return Venue.fromJson(venueData as Map<String, dynamic>);
    } catch (e) {
      print('Error getting business venue: $e');
      return null;
    }
  }

  /// Get subscription for a user
  Future<BusinessSubscription?> getSubscription(String userId) async {
    try {
      final response = await _supabase.rpc(
        'get_business_subscription',
        params: {'p_profile_id': userId},
      );

      if (response == null || (response is List && response.isEmpty)) {
        return null;
      }

      final subscriptionData = response is List ? response.first : response;
      return BusinessSubscription.fromJson(
        subscriptionData as Map<String, dynamic>,
      );
    } catch (e) {
      print('Error getting subscription: $e');
      return null;
    }
  }

  /// Update business venue ID in profile
  Future<bool> updateBusinessVenueId(String userId, String venueId) async {
    try {
      await _supabase
          .from('profiles')
          .update({'business_venue_id': venueId})
          .eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating business venue ID: $e');
      return false;
    }
  }

  /// Create default subscription for business account
  Future<BusinessSubscription?> createDefaultSubscription(String userId) async {
    try {
      final response = await _supabase
          .from('business_subscriptions')
          .insert({
            'profile_id': userId,
            'subscription_type': 'standard',
            'status': 'active',
            'features': {
              'campaigns': {'enabled': true, 'max': 5},
              'notifications': {'enabled': true, 'monthly_limit': 100},
              'analytics': {'enabled': false},
            },
          })
          .select()
          .single();

      return BusinessSubscription.fromJson(response);
    } catch (e) {
      print('Error creating default subscription: $e');
      return null;
    }
  }

  /// Check if user has access to a specific feature
  Future<bool> checkFeatureAccess(String userId, String feature) async {
    try {
      final response = await _supabase.rpc(
        'check_business_feature',
        params: {'p_profile_id': userId, 'p_feature': feature},
      );

      return response == true;
    } catch (e) {
      print('Error checking feature access: $e');
      return false;
    }
  }
}
