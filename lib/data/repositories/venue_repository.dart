import '../models/venue.dart';
import '../models/service.dart';
import '../models/venue_filter.dart';
import '../models/review.dart';
import '../models/venue_photo.dart';
import '../models/venue_category.dart';
import '../services/supabase_service.dart';

class VenueRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<List<VenueCategory>> getVenueCategories() async {
    final response = await _supabase
        .from('venue_categories')
        .select()
        .eq('is_active', true)
        .order('name');
    return (response as List)
        .map((json) => VenueCategory.fromJson(json))
        .toList();
  }

  Future<List<Venue>> getVenues() async {
    final response = await _supabase
        .from('venues_with_coords')
        .select('*, venue_categories(*)');
    return (response as List).map((json) => Venue.fromJson(json)).toList();
  }

  Future<List<Venue>> getFeaturedVenues() async {
    final response = await _supabase
        .from('featured_venues')
        .select('*, venue_categories(*)');
    return (response as List).map((json) => Venue.fromJson(json)).toList();
  }

  Future<Venue?> getVenueById(String id) async {
    final response = await _supabase
        .from('venues_with_coords')
        .select('*, venue_categories(*)')
        .eq('id', id)
        .single();
    return Venue.fromJson(response);
  }

  Future<List<Venue>> getVenuesNearby(
    double lat,
    double lng,
    double radiusInMeters,
  ) async {
    // Note: rpc doesn't support structured join in select easily, but search_venues_advanced returns details.
    // get_nearby_venues returns SETOF venues_with_coords.
    // We might need to join separately if we want category objects here.
    final List<dynamic> response = await _supabase.rpc(
      'get_nearby_venues',
      params: {'lat': lat, 'lng': lng, 'radius_meters': radiusInMeters},
    );

    // To get category details for nearby venues, we should either update the RPC to join or fetch them later.
    // For now, let's just use what's returned.
    return response.map((json) => Venue.fromJson(json)).toList();
  }

  /// Check if current user is following a venue
  Future<bool> checkIfFollowing(String venueId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('follows')
          .select()
          .eq('user_id', userId)
          .eq('venue_id', venueId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  /// Follow a venue
  Future<void> followVenue(String venueId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('follows').insert({
        'user_id': userId,
        'venue_id': venueId,
      });
    } catch (e) {
      if (e.toString().contains('23505') || e.toString().contains('conflict')) {
        // Already following, treat as success
        return;
      }
      print('Error following venue: $e');
      rethrow;
    }
  }

  /// Unfollow a venue
  Future<void> unfollowVenue(String venueId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('follows').delete().match({
        'user_id': userId,
        'venue_id': venueId,
      });
    } catch (e) {
      print('Error unfollowing venue: $e');
      rethrow;
    }
  }

  Future<List<Service>> getServicesByVenueId(String venueId) async {
    final List<dynamic> response = await _supabase.rpc(
      'get_venue_services',
      params: {'p_venue_id': venueId},
    );

    return response.map((json) => Service.fromJson(json)).toList();
  }

  Future<List<Review>> getReviewsByVenueId(String venueId) async {
    final response = await _supabase
        .from('reviews')
        .select('*, profiles(full_name, avatar_url)')
        .eq('venue_id', venueId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Review.fromJson(json)).toList();
  }

  static const Map<String, List<String>> _categoryMapping = {
    'Saç': ['Kuaför - Kadın', 'Kuaför - Erkek'],
    'Cilt Bakımı': ['Cilt Bakımı - Yüz', 'Cilt Bakımı - Vücut'],
    'Kaş-Kirpik': ['Kaş & Kirpik'],
    'Makyaj': ['Makyaj'],
    'Tırnak': ['Tırnak - Manikür', 'Tırnak - Pedikür', 'El & Ayak Bakımı'],
    'Estetik': ['Özel Tedavi'],
    'Masaj': ['Masaj'],
    'Spa': ['Hamam & Spa'],
  };

  Future<List<Venue>> searchVenues({
    String? query,
    VenueFilter? filter,
    double? lat,
    double? lng,
  }) async {
    // Map UI categories to database categories
    List<String>? mappedCategories;
    if (filter != null && filter.categories.isNotEmpty) {
      mappedCategories = filter.categories
          .expand((cat) => _categoryMapping[cat] ?? [cat])
          .toList();
    }

    try {
      final List<dynamic> response = await _supabase.rpc(
        'search_venues_advanced',
        params: {
          'p_query': query?.isEmpty ?? true ? null : query,
          'p_categories': mappedCategories,
          'p_lat': lat,
          'p_lng': lng,
          'p_max_dist_meters': (filter?.maxDistanceKm != null)
              ? filter!.maxDistanceKm! * 1000
              : null,
          'p_only_verified': filter?.onlyVerified ?? false,
          'p_only_preferred': filter?.onlyPreferred ?? false,
          'p_only_hygienic': filter?.onlyHygienic ?? false,
          'p_min_rating': filter?.minRating,
        },
      );

      return response.map((json) => Venue.fromJson(json)).toList();
    } catch (e) {
      print('Error searching venues advanced: $e');
      // Fallback or rethrow
      rethrow;
    }
  }

  // Gallery Photo Methods

  /// Fetch all photos for a venue, ordered by sort_order
  Future<List<VenuePhoto>> fetchVenuePhotos(String venueId) async {
    final response = await _supabase
        .from('venue_photos')
        .select()
        .eq('venue_id', venueId)
        .order('sort_order', ascending: true);

    return (response as List).map((json) => VenuePhoto.fromJson(json)).toList();
  }

  /// Fetch photos filtered by category
  Future<List<VenuePhoto>> fetchPhotosByCategory(
    String venueId,
    PhotoCategory category,
  ) async {
    final response = await _supabase
        .from('venue_photos')
        .select()
        .eq('venue_id', venueId)
        .eq('category', category.toJson())
        .order('sort_order', ascending: true);

    return (response as List).map((json) => VenuePhoto.fromJson(json)).toList();
  }

  /// Submit a new review for a venue
  Future<void> submitReview({
    required String venueId,
    required double rating,
    String? comment,
  }) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('reviews').insert({
        'venue_id': venueId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      print('Error submitting review: $e');
      rethrow;
    }
  }

  /// Update an existing review
  Future<void> updateReview({
    required String reviewId,
    required double rating,
    String? comment,
  }) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('reviews')
          .update({'rating': rating, 'comment': comment})
          .match({
            'id': reviewId,
            'user_id': userId, // Ensure user owns the review
          });
    } catch (e) {
      print('Error updating review: $e');
      rethrow;
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('reviews').delete().match({
        'id': reviewId,
        'user_id': userId, // Ensure user owns the review
      });
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }

  /// Get current user's review for a specific venue
  Future<Review?> getUserReviewForVenue(String venueId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('reviews')
          .select('*, profiles(full_name, avatar_url)')
          .eq('venue_id', venueId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Review.fromJson(response);
    } catch (e) {
      print('Error fetching user review: $e');
      return null;
    }
  }

  /// Like a photo (increment likes_count)
  Future<void> likePhoto(String photoId) async {
    await _supabase.rpc('increment_photo_likes', params: {'photo_id': photoId});
  }

  /// Unlike a photo (decrement likes_count)
  Future<void> unlikePhoto(String photoId) async {
    await _supabase.rpc('decrement_photo_likes', params: {'photo_id': photoId});
  }
}
