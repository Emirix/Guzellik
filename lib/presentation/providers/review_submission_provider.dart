import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/models/review.dart';
import '../../data/services/storage_service.dart';

class ReviewSubmissionProvider extends ChangeNotifier {
  final ReviewRepository _repository;
  final StorageService _storageService = StorageService();

  ReviewSubmissionProvider(this._repository);

  double? _rating;
  String _comment = '';
  bool _isLoading = false;
  String? _errorMessage;
  Review? _existingReview;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedPhotos = [];

  double? get rating => _rating;
  String get comment => _comment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get characterCount => _comment.length;
  Review? get existingReview => _existingReview;
  bool get isEditing => _existingReview != null;
  List<XFile> get selectedPhotos => _selectedPhotos;

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

  Future<void> pickPhotos() async {
    if (_selectedPhotos.length >= 2) return;

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        limit: 2 - _selectedPhotos.length,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        _selectedPhotos.addAll(images);
        if (_selectedPhotos.length > 2) {
          _selectedPhotos = _selectedPhotos.sublist(0, 2);
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Fotoğraf seçilirken hata oluştu.';
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    _selectedPhotos.removeAt(index);
    notifyListeners();
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
        // Photos usually not editable or need fetching
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
        // Upload photos
        List<String> photoPaths = [];
        if (_selectedPhotos.isNotEmpty) {
          final userId = Supabase.instance.client.auth.currentUser?.id;
          if (userId != null) {
            photoPaths = await _uploadPhotos(userId);
          }
        }

        await _repository.submitReview(
          venueId: venueId,
          rating: _rating!,
          comment: _comment.isEmpty ? null : _comment,
          photos: photoPaths,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = 'Değerlendirme gönderilirken bir hata oluştu: $e';
      print('Review submit error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> _uploadPhotos(String userId) async {
    final List<String> paths = [];

    for (var photo in _selectedPhotos) {
      try {
        final url = await _storageService.uploadImage(
          bucket: 'review-photos',
          path: userId,
          imageFile: File(photo.path),
        );
        paths.add(url); // This is the full URL from FTP
      } catch (e) {
        print('Error uploading photo to FTP: $e');
        // If one photo fails, we might still want to proceed with the review
      }
    }
    return paths;
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
    _selectedPhotos = [];
    _isLoading = false;
    _errorMessage = null;
    _existingReview = null;
    notifyListeners();
  }
}
