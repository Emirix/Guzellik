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
      final slug = _venue?.category?.slug ?? 'all';
      _categoryPhotos = await _storageService.listCategoryPhotos(slug);
      _error = null;
    } catch (e) {
      _error = 'Fotoğraflar yüklenirken hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  void selectPhoto(String url) {
    _selectedPhotoUrl = url;
    notifyListeners();
  }

  Future<void> uploadCustomPhoto(File file) async {
    if (_venue == null) return;

    _setLoading(true);
    try {
      // Eğer mevcut seçili olan fotoğraf halihazırda bu oturumda yüklenmiş bir özelse, onu silebiliriz
      // Ancak genellikle kaydetmeden silmemek daha güvenlidir.
      // Yine de sunucuda çöp birikmemesi için temizlik yapalım.
      final oldSelection = _selectedPhotoUrl;

      final url = await _storageService.uploadVenueImage(
        file,
        '${_venue!.id}/cover',
      );
      _selectedPhotoUrl = url;
      _error = null;

      // Eğer eski seçim bir custom URL ise ve DB'deki orijinal URL değilse (yani bu oturumda yüklenmişse), onu sil
      if (oldSelection != null &&
          oldSelection != _venue?.imageUrl &&
          oldSelection.contains('venue-photos/')) {
        _storageService.deleteFileByUrl(oldSelection);
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
      await _venueRepository.updateCoverPhoto(_venue!.id, newUrl);

      // Eski fotoğraf eğer custom bir fotoğrafsa ve yenisiyle farklıysa sil
      if (oldUrl != null &&
          oldUrl != newUrl &&
          oldUrl.contains('venue-photos/')) {
        // Yangından mal kaçırır gibi silme, DB güncellendiği için artık güvenle silinebilir
        _storageService.deleteFileByUrl(oldUrl);
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
