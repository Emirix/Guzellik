import 'package:flutter/material.dart';
import '../../data/repositories/venue_repository.dart';
import '../../data/models/review.dart';

class ReviewSubmissionProvider extends ChangeNotifier {
  final VenueRepository _repository;

  ReviewSubmissionProvider(this._repository);

  double? _rating;
  String _comment = '';
  bool _isLoading = false;
  String? _errorMessage;
  Review? _existingReview;

  double? get rating => _rating;
  String get comment => _comment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get characterCount => _comment.length;
  Review? get existingReview => _existingReview;
  bool get isEditing => _existingReview != null;

  void setRating(double rating) {
    _rating = rating;
    notifyListeners();
  }

  void setComment(String comment) {
    if (comment.length <= 500) {
      _comment = comment;
      notifyListeners();
    }
  }

  Future<void> checkExistingReview(String venueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _existingReview = await _repository.getUserReviewForVenue(venueId);
      if (_existingReview != null) {
        _rating = _existingReview!.rating;
        _comment = _existingReview!.comment ?? '';
      } else {
        reset();
      }
    } catch (e) {
      _errorMessage = 'Değerlendirme kontrol edilirken bir hata oluştu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview(String venueId) async {
    if (_rating == null) {
      _errorMessage = 'Lütfen bir puan seçin.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isEditing) {
        await _repository.updateReview(
          reviewId: _existingReview!.id,
          rating: _rating!,
          comment: _comment.isEmpty ? null : _comment,
        );
      } else {
        await _repository.submitReview(
          venueId: venueId,
          rating: _rating!,
          comment: _comment.isEmpty ? null : _comment,
        );
      }
      return true;
    } catch (e) {
      _errorMessage =
          'Değerlendirme gönderilirken bir hata oluştu. Lütfen tekrar deneyin.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReview() async {
    if (!isEditing) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteReview(_existingReview!.id);
      reset();
      return true;
    } catch (e) {
      _errorMessage = 'Değerlendirme silinirken bir hata oluştu.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _rating = null;
    _comment = '';
    _isLoading = false;
    _errorMessage = null;
    _existingReview = null;
    notifyListeners();
  }
}
