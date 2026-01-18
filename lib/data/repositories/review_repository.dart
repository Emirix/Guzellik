import 'package:guzellik_app/data/models/review.dart';
import '../services/supabase_service.dart';

class ReviewRepository {
  static final ReviewRepository _instance = ReviewRepository._internal();
  static ReviewRepository get instance => _instance;
  factory ReviewRepository() => _instance;
  ReviewRepository._internal();

  final SupabaseService _supabase = SupabaseService.instance;

  Future<void> submitReview({
    required String venueId,
    required double rating,
    String? comment,
    List<String>? photos,
  }) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // 1. Insert review
      final reviewResponse = await _supabase
          .from('reviews')
          .insert({
            'venue_id': venueId,
            'user_id': userId,
            'rating': rating,
            'comment': comment,
            'status': 'pending', // Default
          })
          .select()
          .single();

      final reviewId = reviewResponse['id'];

      // 2. Insert photos into entity_media if any
      if (photos != null && photos.isNotEmpty) {
        for (final path in photos) {
          try {
            // Create media record
            final mediaResponse = await _supabase
                .from('media')
                .insert({
                  'storage_path': path,
                  'mime_type': 'image/jpeg', // Defaulting to jpeg for now
                  'metadata': {},
                })
                .select()
                .single();

            final mediaId = mediaResponse['id'];

            // Link to review
            await _supabase.from('entity_media').insert({
              'media_id': mediaId,
              'entity_id': reviewId,
              'entity_type': 'review_photo',
              'is_primary': false,
            });
          } catch (e) {
            print('Error linking photo $path: $e');
            // Continue with other photos even if one fails
          }
        }
      }
    } catch (e) {
      print('Error submitting review: $e');
      rethrow;
    }
  }

  Future<int> toggleHelpful(String reviewId) async {
    try {
      final response = await _supabase.rpc(
        'toggle_review_helpful',
        params: {'p_review_id': reviewId},
      );
      return response as int;
    } catch (e) {
      print('Error toggling helpful: $e');
      rethrow;
    }
  }

  Future<void> approveReview({
    required String reviewId,
    String? replyText,
  }) async {
    try {
      await _supabase.rpc(
        'approve_review',
        params: {'p_review_id': reviewId, 'p_reply_text': replyText},
      );
    } catch (e) {
      print('Error approving review: $e');
      rethrow;
    }
  }

  Future<List<Review>> getVenueReviews({
    required String venueId,
    String sortBy = 'newest',
    int? filterRating,
    bool filterHasPhotos = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final List<dynamic> response = await _supabase.rpc(
        'get_venue_reviews_advanced',
        params: {
          'p_venue_id': venueId,
          'p_sort_by': sortBy,
          'p_filter_rating': filterRating,
          'p_filter_has_photos': filterHasPhotos,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      return response.map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching venue reviews: $e');
      rethrow;
    }
  }

  Future<List<Review>> getOwnerReviews({
    required String venueId,
    ReviewStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('reviews')
          .select('*, profiles(full_name, avatar_url)')
          .eq('venue_id', venueId);

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching owner reviews: $e');
      rethrow;
    }
  }

  // Method to link uploaded photos to the review
  Future<void> linkReviewPhotos(String reviewId, List<String> mediaIds) async {
    try {
      final List<Map<String, dynamic>> records = mediaIds
          .map(
            (mediaId) => {
              'media_id': mediaId,
              'entity_id': reviewId,
              'entity_type': 'review_photo',
            },
          )
          .toList();

      await _supabase.from('entity_media').insert(records);
    } catch (e) {
      print('Error linking review photos: $e');
      rethrow;
    }
  }

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
          .update({'rating': rating, 'comment': comment, 'status': 'pending'})
          .match({'id': reviewId, 'user_id': userId});
    } catch (e) {
      print('Error updating review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('reviews').delete().match({
        'id': reviewId,
        'user_id': userId,
      });
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }
}
