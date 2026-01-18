import 'package:supabase_flutter/supabase_flutter.dart';

class VenueClaimRepository {
  static final VenueClaimRepository instance = VenueClaimRepository._();
  VenueClaimRepository._();

  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> searchVenues(String query) async {
    final response = await _supabase
        .from('venues')
        .select('id, name, address, owner_id')
        .ilike('name', '%$query%')
        .limit(10);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> submitClaimRequest({
    required String profileId,
    required String venueId,
    required List<String> documentUrls,
  }) async {
    await _supabase.from('venue_claim_requests').insert({
      'profile_id': profileId,
      'venue_id': venueId,
      'documents': documentUrls,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getMyClaimRequests(
    String profileId,
  ) async {
    final response = await _supabase
        .from('venue_claim_requests')
        .select('*, venues(name, address)')
        .eq('profile_id', profileId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
