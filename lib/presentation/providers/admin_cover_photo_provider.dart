import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/venue.dart';
import '../../../data/repositories/venue_repository.dart';
import '../../../data/services/storage_service.dart';

class AdminCoverPhotoProvider extends ChangeNotifier {
  final VenueRepository _venueRepository = VenueRepository.instance;
  final StorageService _storageService = StorageService();

  Venue? _venue;
  List<String> _categoryPhotos = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedPhotoUrl;

  Venue? get venue => _venue;
  List<String> get categoryPhotos => _categoryPhotos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedPhotoUrl => _selectedPhotoUrl;

  Future<void> init(Venue venue) async {
    _venue = venue;
    _selectedPhotoUrl = venue.imageUrl;
    await loadCategoryPhotos();
  }

  Future<void> loadCategoryPhotos() async {
    _setLoading(true);
    try {
      // Her zaman tüm hazır fotoğrafları getir
      _categoryPhotos = await _storageService.listCategoryPhotos('all');
      _error = null;
    } catch (e) {
      _error = 'Fotoğraflar yüklenirken hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectPhoto(String url) async {
    if (_venue == null) return;

    final oldSelection = _selectedPhotoUrl;
    _selectedPhotoUrl = url;
    notifyListeners();

    // Eğer yeni seçim bir kategori fotoğrafıysa ve eski seçim custom bir fotoğrafsa, eski custom fotoğrafı sil
    // Kategori fotoğrafları: storage/categories/
    // Custom fotoğraflar: venue-photos/{venueId}/cover
    if (url.contains('storage/categories/') &&
        oldSelection != null &&
        oldSelection != _venue?.imageUrl &&
        oldSelection.contains('venue-photos/') &&
        oldSelection.contains('${_venue!.id}/cover')) {
      try {
        await _storageService.deleteFileByUrl(oldSelection);
        debugPrint(
          'Eski custom kapak fotoğrafı silindi (kategori seçildi): $oldSelection',
        );
      } catch (deleteError) {
        debugPrint('Eski custom kapak fotoğrafı silinirken hata: $deleteError');
        // Silme hatası kritik değil, devam et
      }
    }
  }

  Future<void> uploadCustomPhoto(File file) async {
    if (_venue == null) return;

    _setLoading(true);
    try {
      final oldSelection = _selectedPhotoUrl;

      // Yeni fotoğrafı yükle
      final url = await _storageService.uploadVenueImage(
        file,
        '${_venue!.id}/cover',
      );
      _selectedPhotoUrl = url;
      _error = null;

      // Eğer eski seçim bir custom URL ise ve DB'deki orijinal URL değilse (yani bu oturumda yüklenmişse), onu sil
      // Kategori fotoğrafları (storage/categories/) silinmeyecek
      if (oldSelection != null &&
          oldSelection != _venue?.imageUrl &&
          oldSelection.contains('venue-photos/') &&
          oldSelection.contains('${_venue!.id}/cover')) {
        try {
          await _storageService.deleteFileByUrl(oldSelection);
          debugPrint('Eski geçici kapak fotoğrafı silindi: $oldSelection');
        } catch (deleteError) {
          debugPrint(
            'Eski geçici kapak fotoğrafı silinirken hata: $deleteError',
          );
          // Silme hatası kritik değil, devam et
        }
      }
    } catch (e) {
      _error = 'Fotoğraf yüklenirken hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveCoverPhoto() async {
    if (_venue == null || _selectedPhotoUrl == null) return false;

    final oldUrl = _venue?.imageUrl;
    final newUrl = _selectedPhotoUrl!;

    _setLoading(true);
    try {
      // Önce veritabanını güncelle
      await _venueRepository.updateCoverPhoto(_venue!.id, newUrl);

      // Eski fotoğraf eğer custom bir fotoğrafsa (venue-photos/ içeriyorsa) ve yeni fotoğraftan farklıysa sil
      // Kategori fotoğrafları (storage/categories/) silinmeyecek
      if (oldUrl != null &&
          oldUrl != newUrl &&
          oldUrl.contains('venue-photos/') &&
          oldUrl.contains('${_venue!.id}/cover')) {
        try {
          await _storageService.deleteFileByUrl(oldUrl);
          debugPrint('Eski kapak fotoğrafı silindi: $oldUrl');
        } catch (deleteError) {
          debugPrint('Eski kapak fotoğrafı silinirken hata: $deleteError');
          // Silme hatası kritik değil, devam et
        }
      }

      _venue = _venue!.copyWith(imageUrl: newUrl);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Kapak fotoğrafı güncellenirken hata oluştu: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
