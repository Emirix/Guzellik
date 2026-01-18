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
          .from('venues')
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle();

      return response != null;
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
      // First get the venue ID for this user
      final venue = await getBusinessVenue(userId);
      if (venue == null) return null;

      final response = await _supabase
          .from('venues_subscription')
          .select()
          .eq('venue_id', venue.id)
          .maybeSingle();

      if (response == null) return null;

      return BusinessSubscription.fromJson(response);
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
  Future<BusinessSubscription?> createDefaultSubscription(
    String venueId,
  ) async {
    try {
      final response = await _supabase
          .from('venues_subscription')
          .insert({
            'venue_id': venueId,
            'subscription_type': SubscriptionTier.standard.name,
            'status': 'active',
            'features': {
              'campaigns': {'enabled': true, 'monthly_limit': 3},
              'notifications': {'enabled': true, 'daily_limit': 5},
              'analytics': {'enabled': true, 'type': 'basic'},
              'support': {'type': 'email'},
              'featured_listing': {'enabled': false},
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

  /// Update venue working hours
  Future<bool> updateVenueWorkingHours(
    String venueId,
    Map<String, dynamic> workingHours,
  ) async {
    try {
      await _supabase
          .from('venues')
          .update({'working_hours': workingHours})
          .eq('id', venueId);
      return true;
    } catch (e) {
      print('Error updating working hours: $e');
      return false;
    }
  }

  /// Update venue FAQ
  Future<bool> updateVenueFaq(String venueId, List<dynamic> faq) async {
    try {
      await _supabase.from('venues').update({'faq': faq}).eq('id', venueId);
      return true;
    } catch (e) {
      print('Error updating FAQ: $e');
      return false;
    }
  }

  /// Check if user can convert to business account
  /// Returns false if user already has a business account
  Future<bool> canConvertToBusinessAccount(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('is_business_account')
          .eq('id', userId)
          .single();

      return response['is_business_account'] == false;
    } catch (e) {
      print('Error checking conversion eligibility: $e');
      return false;
    }
  }

  /// Convert a regular user account to a business account
  /// Creates a trial subscription valid for 1 year
  /// Stores business name and type in profile for later venue creation
  Future<void> convertToBusinessAccount({
    required String userId,
    required String businessName,
    required String businessType,
  }) async {
    try {
      // 1. Check if user can convert
      final canConvert = await canConvertToBusinessAccount(userId);
      if (!canConvert) {
        throw Exception('Bu hesap zaten işletme hesabıdır');
      }

      // 2. Create the Venue first (needs to exist for some checks/relationships)
      final venueResponse = await _supabase
          .from('venues')
          .insert({
            'name': businessName,
            'owner_id': userId,
            'category_id': businessType,
            'is_active': true,
            'is_verified': false,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      final venueId = venueResponse['id'] as String;

      // 3. Update profile with business account flag, business info, and venue link
      await _supabase
          .from('profiles')
          .update({
            'is_business_account': true,
            'business_name': businessName,
            'business_type': businessType,
            'business_venue_id': venueId,
          })
          .eq('id', userId);

      // 4. Create standard subscription for the new venue
      final expiresAt = DateTime.now().add(const Duration(days: 365));
      await _supabase.from('venues_subscription').insert({
        'venue_id': venueId,
        'subscription_type': SubscriptionTier.standard.name,
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'features': {
          'campaigns': {'enabled': true, 'monthly_limit': 3},
          'notifications': {'enabled': true, 'daily_limit': 5},
          'analytics': {'enabled': true, 'type': 'basic'},
          'support': {'type': 'email'},
          'featured_listing': {'enabled': false},
        },
      });
    } catch (e) {
      print('Error converting to business account: $e');
      rethrow;
    }
  }
}
