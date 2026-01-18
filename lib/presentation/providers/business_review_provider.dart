import 'package:flutter/material.dart';
import '../../data/models/review.dart';
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
      // Remove from pending
      _pendingReviews.removeWhere((r) => r.id == reviewId);

      // Ideally we fetch the updated one or construct it, but simpler to just refresh or move
      // Since 'approved' list might be paginated, just removing from pending is key.
      notifyListeners();
    } catch (e) {
      print('Error approving: $e');
      // Show error
    }
  }
}
