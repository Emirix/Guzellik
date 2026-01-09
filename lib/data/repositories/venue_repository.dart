import '../models/venue.dart';
import '../models/service.dart';
import '../models/venue_filter.dart';
import '../models/review.dart';
import '../models/venue_photo.dart';
import '../models/venue_category.dart';
import '../services/supabase_service.dart';
import '../../core/services/cache_service.dart';

/// Venue verilerini yöneten repository
/// Singleton pattern - uygulama genelinde tek instance
class VenueRepository {
  // Singleton pattern
  static final VenueRepository _instance = VenueRepository._internal();
  static VenueRepository get instance => _instance;
  factory VenueRepository() => _instance;
  VenueRepository._internal();

  final SupabaseService _supabase = SupabaseService.instance;
  final CacheService _cache = CacheService.instance;

  /// Kategorileri cache'den veya API'den getirir (30 dk cache)
  Future<List<VenueCategory>> getVenueCategories() async {
    // Cache'den kontrol et
    final cached = _cache.get<List<VenueCategory>>(CacheService.categoriesKey);
    if (cached != null) return cached;

    // API'den çek
    final response = await _supabase
        .from('venue_categories')
        .select()
        .eq('is_active', true)
        .order('order', ascending: true);
    final categories = (response as List)
        .map((json) => VenueCategory.fromJson(json))
        .toList();

    // Cache'e kaydet
    _cache.set(
      CacheService.categoriesKey,
      categories,
      ttlSeconds: CacheService.categoriesTTL,
    );

    return categories;
  }

  Future<List<Venue>> getVenues() async {
    final response = await _supabase
        .from('venues_with_coords')
        .select('*, venue_categories(*)');
    return (response as List).map((json) => Venue.fromJson(json)).toList();
  }

  /// Featured venues - konum varsa hesaplanır, yoksa cache kullanılır (5 dk)
  Future<List<Venue>> getFeaturedVenues({double? lat, double? lng}) async {
    if (lat != null && lng != null) {
      // Konum varsa distance hesaplaması gerekir, cache kullanma
      return searchVenues(
        lat: lat,
        lng: lng,
        filter: VenueFilter(minRating: 0.0),
      );
    }

    // Cache'den kontrol et (konum olmadan)
    final cached = _cache.get<List<Venue>>(CacheService.featuredVenuesKey);
    if (cached != null) return cached;

    final response = await _supabase
        .from('featured_venues')
        .select('*, venue_categories(*)');
    final venues = (response as List)
        .map((json) => Venue.fromJson(json))
        .toList();

    // Cache'e kaydet
    _cache.set(
      CacheService.featuredVenuesKey,
      venues,
      ttlSeconds: CacheService.featuredVenuesTTL,
    );

    return venues;
  }

  /// Venue detayları - 2 dk cache
  Future<Venue?> getVenueById(String id) async {
    // Cache'den kontrol et
    final cacheKey = CacheService.venueDetailKey(id);
    final cached = _cache.get<Venue>(cacheKey);
    if (cached != null) return cached;

    final response = await _supabase
        .from('venues_with_coords')
        .select('*, venue_categories(*)')
        .eq('id', id)
        .single();
    final venue = Venue.fromJson(response);

    // Cache'e kaydet
    _cache.set(cacheKey, venue, ttlSeconds: CacheService.venueDetailsTTL);

    return venue;
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

  /// Get list of venues followed by the current user
  Future<List<Venue>> getFollowedVenues() async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('follows')
          .select('venue_id, venues_with_coords(*, venue_categories(*))')
          .eq('user_id', userId);

      return (response as List)
          .where((item) => item['venues_with_coords'] != null)
          .map((item) {
            final venueJson = Map<String, dynamic>.from(
              item['venues_with_coords'],
            );
            venueJson['is_following'] = true;
            return Venue.fromJson(venueJson);
          })
          .toList();
    } catch (e) {
      print('Error getting followed venues: $e');
      return [];
    }
  }

  /// Check if current user has favorited a venue
  Future<bool> checkIfFavorited(String venueId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('user_favorites')
          .select()
          .eq('user_id', userId)
          .eq('venue_id', venueId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  /// Add a venue to favorites
  Future<void> addFavorite(String venueId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('user_favorites').insert({
        'user_id': userId,
        'venue_id': venueId,
      });
    } catch (e) {
      if (e.toString().contains('23505') || e.toString().contains('conflict')) {
        return;
      }
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  /// Remove a venue from favorites
  Future<void> removeFavorite(String venueId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('user_favorites').delete().match({
        'user_id': userId,
        'venue_id': venueId,
      });
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  /// Get list of favorited venues for the current user
  Future<List<Venue>> getFavoriteVenues() async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('user_favorites')
          .select('venue_id, venues_with_coords(*, venue_categories(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .where((item) => item['venues_with_coords'] != null)
          .map((item) {
            final venueJson = Map<String, dynamic>.from(
              item['venues_with_coords'],
            );
            venueJson['is_favorited'] = true;
            return Venue.fromJson(venueJson);
          })
          .toList();
    } catch (e) {
      print('Error getting favorite venues: $e');
      return [];
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

  Future<List<Venue>> searchVenues({
    String? query,
    VenueFilter? filter,
    double? lat,
    double? lng,
  }) async {
    // Use categories directly as they now come from the database
    final List<String>? mappedCategories =
        (filter != null && filter.categories.isNotEmpty)
        ? filter.categories
        : null;

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
          'p_category_id': filter?.categoryId,
          'p_sort_by': filter?.sortBy.name ?? 'recommended',
          'p_service_ids': (filter?.serviceIds.isNotEmpty ?? false)
              ? filter!.serviceIds
              : null,
        },
      );

      return response
          .map((json) => Venue.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching venues advanced: $e');
      rethrow;
    }
  }

  /// Elastic search - comprehensive full-text search across venues, services, and locations
  /// Supports Turkish character normalization and fuzzy matching
  Future<List<Venue>> elasticSearchVenues({
    required String query,
    double? lat,
    double? lng,
    int? provinceId,
    String? districtId,
    double? maxDistanceKm,
    bool onlyVerified = false,
    bool onlyPreferred = false,
    bool onlyHygienic = false,
    double? minRating,
    String sortBy = 'recommended',
    List<String>? serviceIds,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final List<dynamic> response = await _supabase.rpc(
        'elastic_search_venues',
        params: {
          'p_query': query.trim(),
          'p_lat': lat,
          'p_lng': lng,
          'p_province_id': provinceId,
          'p_district_id': districtId,
          'p_max_dist_meters': maxDistanceKm != null
              ? maxDistanceKm * 1000
              : null,
          'p_only_verified': onlyVerified,
          'p_only_preferred': onlyPreferred,
          'p_only_hygienic': onlyHygienic,
          'p_min_rating': minRating,
          'p_sort_by': sortBy,
          'p_limit': limit,
          'p_service_ids': (serviceIds?.isNotEmpty ?? false)
              ? serviceIds
              : null,
        },
      );

      return response.map((json) => Venue.fromJson(json)).toList();
    } catch (e) {
      print('Error in elastic search: $e');
      // Fallback to basic search if elastic search fails
      return searchVenues(query: query, lat: lat, lng: lng);
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

  /// Get services for a specific venue category
  Future<List<Service>> getServicesByCategory(String categoryId) async {
    final List<dynamic> response = await _supabase.rpc(
      'get_services_by_venue_category',
      params: {'p_category_id': categoryId},
    );

    return response.map((json) => Service.fromJson(json)).toList();
  }
}
