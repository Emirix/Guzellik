import 'package:flutter/material.dart';
import 'package:guzellik_app/data/models/review.dart';
import '../../data/repositories/review_repository.dart';

class BusinessReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository = ReviewRepository.instance;

  List<Review> _pendingReviews = [];
  List<Review> _approvedReviews = []; // or all history
  bool _isLoading = false;
  String? _errorMessage;

  List<Review> get pendingReviews => _pendingReviews;
  List<Review> get approvedReviews => _approvedReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadReviews(String venueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getOwnerReviews(
          venueId: venueId,
          status: ReviewStatus.pending,
        ),
        _repository.getOwnerReviews(
          venueId: venueId,
          status: ReviewStatus.approved,
        ),
      ]);

      _pendingReviews = results[0];
      _approvedReviews = results[1];
    } catch (e) {
      _errorMessage = 'Yorumlar yüklenirken hata oluştu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveReview(String reviewId, String? replyText) async {
    try {
      await _repository.approveReview(reviewId: reviewId, replyText: replyText);

      // Find the review to move it to approved list
      final index = _pendingReviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final review = _pendingReviews[index];
        _pendingReviews.removeAt(index);

        // Add to approved if it exists in local state
        _approvedReviews.insert(0, review);
      }

      notifyListeners();
    } catch (e) {
      print('Error approving: $e');
      _errorMessage = 'Yorum onaylanırken bir hata oluştu.';
      notifyListeners();
    }
  }
}
