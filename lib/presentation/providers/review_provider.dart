import 'package:flutter/material.dart';
import '../../data/models/review.dart';
import '../../data/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository = ReviewRepository.instance;

  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter state
  int? _filterRating;
  bool _filterHasPhotos = false;
  String _sortBy = 'newest';

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int? get filterRating => _filterRating;
  bool get filterHasPhotos => _filterHasPhotos;
  String get sortBy => _sortBy;

  /// Set the rating filter (toggle if same)
  void setFilterRating(int? rating, String venueId) {
    if (_filterRating == rating) {
      _filterRating = null;
    } else {
      _filterRating = rating;
    }
    fetchReviews(venueId);
  }

  /// Toggle photo filter
  void setFilterHasPhotos(bool value, String venueId) {
    _filterHasPhotos = value;
    fetchReviews(venueId);
  }

  /// Set sort option
  void setSortBy(String value, String venueId) {
    _sortBy = value;
    fetchReviews(venueId);
  }

  /// Initial load or Refresh
  Future<void> fetchReviews(String venueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _repository.getVenueReviews(
        venueId: venueId,
        sortBy: _sortBy,
        filterRating: _filterRating,
        filterHasPhotos: _filterHasPhotos,
        limit: 50, // Higher limit for list view or implement pagination
      );
    } catch (e) {
      _errorMessage = 'Yorumlar yüklenirken bir hata oluştu.';
      print('Error loading reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle helpful status of a review
  Future<void> toggleHelpful(String reviewId) async {
    // Optimistic update logic could be added here
    // For now, we just call the API
    try {
      await _repository.toggleHelpful(reviewId);

      // Update local state (increment/decrement)
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        // Since we don't know if we are adding or removing without tracking "isLiked",
        // we might strictly need to re-fetch or return the new count from RPC.
        // For simple UX, let's assume we can't easily optimistic update count without state.
        // But we can guess if we tracked it. The current model doesn't track "isHelpful".
        // Let's rely on re-fetching or ignores for now, or update model to include "isHelpful".
      }
    } catch (e) {
      print('Error toggling helpful: $e');
      // Show snackbar?
    }
  }
}
