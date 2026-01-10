import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/campaign.dart';

/// Repository for campaign data operations
class CampaignRepository {
  final SupabaseClient _supabase;

  CampaignRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Fetch all active campaigns with venue information
  /// Returns campaigns where is_active = true AND end_date > NOW()
  Future<List<Campaign>> getAllCampaigns({
    CampaignSortType sortBy = CampaignSortType.date,
  }) async {
    try {
      final baseQuery = _supabase
          .from('campaigns')
          .select('*, venues(*)')
          .eq('is_active', true)
          .gt('end_date', DateTime.now().toIso8601String());

      // Apply sorting - use direct await to avoid type issues
      final response = switch (sortBy) {
        CampaignSortType.date => await baseQuery.order(
          'start_date',
          ascending: false,
        ),
        CampaignSortType.discount => await baseQuery.order(
          'discount_percentage',
          ascending: false,
        ),
        CampaignSortType.expiringSoon => await baseQuery.order(
          'end_date',
          ascending: true,
        ),
      };

      return (response as List)
          .map((json) => Campaign.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  /// Fetch a single campaign by ID
  Future<Campaign?> getCampaignById(String id) async {
    try {
      final response = await _supabase
          .from('campaigns')
          .select('*, venues(*)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return Campaign.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch campaign: $e');
    }
  }

  /// Fetch campaigns for a specific venue
  Future<List<Campaign>> getCampaignsByVenue(
    String venueId, {
    bool onlyActive = true,
  }) async {
    try {
      var baseQuery = _supabase
          .from('campaigns')
          .select('*, venues(*)')
          .eq('venue_id', venueId);

      if (onlyActive) {
        baseQuery = baseQuery
            .eq('is_active', true)
            .gt('end_date', DateTime.now().toIso8601String());
      }

      final response = await baseQuery.order('start_date', ascending: false);

      return (response as List)
          .map((json) => Campaign.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch venue campaigns: $e');
    }
  }

  /// Get count of active campaigns for a venue
  Future<int> getActiveCampaignCount(String venueId) async {
    try {
      final response =
          await _supabase
                  .from('campaigns')
                  .select('id')
                  .eq('venue_id', venueId)
                  .eq('is_active', true)
                  .gt('end_date', DateTime.now().toIso8601String())
              as List;

      return response.length;
    } catch (e) {
      throw Exception('Failed to get campaign count: $e');
    }
  }
}

/// Sort type for campaigns
enum CampaignSortType {
  date, // Newest first
  discount, // Highest discount first
  expiringSoon, // Ending soonest first
}
