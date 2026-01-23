import 'package:flutter/material.dart';
import '../../data/models/review.dart';
import '../../data/repositories/review_repository.dart';

class UserReviewsProvider extends ChangeNotifier {
  final ReviewRepository _repository = ReviewRepository.instance;

  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _repository.getUserReviews();
    } catch (e) {
      _errorMessage = 'İncelemeler yüklenirken bir hata oluştu.';
      print('Error loading user reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _repository.deleteReview(reviewId);

      _reviews.removeWhere((r) => r.id == reviewId);
      notifyListeners();
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }

  Future<void> toggleHelpful(String reviewId) async {
    try {
      final newCount = await _repository.toggleHelpful(reviewId);

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
