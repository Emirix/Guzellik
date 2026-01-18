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
    try {
      final newCount = await _repository.toggleHelpful(reviewId);

      // Update local state
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = _reviews[index].copyWith(helpfulCount: newCount);
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling helpful: $e');
    }
  }
}
