import '../models/venue.dart';
import '../models/service.dart';
import '../models/venue_filter.dart';
import '../services/supabase_service.dart';

class VenueRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<Venue>> getVenues() async {
    final response = await _supabase.from('venues_with_coords').select();
    return (response as List).map((json) => Venue.fromJson(json)).toList();
  }

  Future<Venue?> getVenueById(String id) async {
    final response = await _supabase
        .from('venues_with_coords')
        .select()
        .eq('id', id)
        .single();
    return Venue.fromJson(response);
  }

  Future<List<Venue>> getVenuesNearby(
    double lat,
    double lng,
    double radiusInMeters,
  ) async {
    final List<dynamic> response = await _supabase.rpc(
      'get_nearby_venues',
      params: {'lat': lat, 'lng': lng, 'radius_meters': radiusInMeters},
    );

    return response.map((json) => Venue.fromJson(json)).toList();
  }

  Future<void> followVenue(String venueId) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('follows').insert({
      'user_id': userId,
      'venue_id': venueId,
    });
  }

  Future<void> unfollowVenue(String venueId) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('follows').delete().match({
      'user_id': userId,
      'venue_id': venueId,
    });
  }

  Future<List<Service>> getServicesByVenueId(String venueId) async {
    final response = await _supabase
        .from('services')
        .select()
        .eq('venue_id', venueId)
        .order('category', ascending: true);

    return (response as List).map((json) => Service.fromJson(json)).toList();
  }

  Future<List<Venue>> searchVenues({
    String? query,
    VenueFilter? filter,
    double? lat,
    double? lng,
  }) async {
    // If RPC fails or is not available, we can fallback to local filtering
    // For now, let's use the basic getVenues or getVenuesNearby and filter in Dart
    // to ensure functionality even if Supabase RPC is not fully set up.
    List<Venue> venues;
    if (lat != null && lng != null && (filter?.maxDistanceKm != null)) {
      venues = await getVenuesNearby(lat, lng, filter!.maxDistanceKm! * 1000);
    } else {
      venues = await getVenues();
    }

    if ((query == null || query.isEmpty) &&
        (filter == null || !filter.hasFilters)) {
      return venues;
    }

    return venues.where((v) {
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        final matchesQuery =
            v.name.toLowerCase().contains(lowerQuery) ||
            (v.description?.toLowerCase().contains(lowerQuery) ?? false) ||
            v.address.toLowerCase().contains(lowerQuery);
        if (!matchesQuery) return false;
      }

      if (filter != null) {
        if (filter.onlyVerified && !v.isVerified) return false;
        if (filter.onlyPreferred && !v.isPreferred) return false;
        if (filter.onlyHygienic && !v.isHygienic) return false;
        // Pricing and rating would require additional data/joins if done locally
      }

      return true;
    }).toList();
  }
}
