import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/venue_photo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/storage_service.dart';

class AdminGalleryProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _storageService = StorageService();

  List<VenuePhoto> _photos = [];
  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0;

  List<VenuePhoto> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;
  bool get canAddMore => _photos.length < 10;

  Future<void> fetchPhotos(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('venue_photos')
          .select()
          .eq('venue_id', venueId)
          .order('sort_order', ascending: true);

      _photos = (response as List)
          .map((json) => VenuePhoto.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadPhoto(String venueId, File imageFile) async {
    if (!canAddMore) {
      throw Exception('Maksimum 10 fotoğraf yükleyebilirsiniz.');
    }

    _isLoading = true;
    _uploadProgress = 0;
    notifyListeners();

    try {
      // 1. Upload to Storage via API (with compression)
      final imageUrl = await _storageService.uploadImage(
        bucket: 'venue-gallery',
        path: venueId,
        imageFile: imageFile,
      );

      // 3. Create DB Record
      final newSortOrder = _photos.isEmpty
          ? 0
          : _photos.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

      final isFirst = _photos.isEmpty;

      await _supabase.from('venue_photos').insert({
        'venue_id': venueId,
        'url': imageUrl,
        'sort_order': newSortOrder,
        'is_hero_image': isFirst,
        'category': 'interior', // Default
      });

      await fetchPhotos(venueId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      final photo = _photos.firstWhere((p) => p.id == photoId);

      // 1. Delete from DB
      await _supabase.from('venue_photos').delete().eq('id', photoId);

      // 2. Delete from Storage
      await _storageService.deleteFileByUrl(photo.url);

      await fetchPhotos(photo.venueId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setAsHero(String photoId) async {
    try {
      final photo = _photos.firstWhere((p) => p.id == photoId);
      final venueId = photo.venueId;

      // Reset all hero images for this venue
      await _supabase
          .from('venue_photos')
          .update({'is_hero_image': false})
          .eq('venue_id', venueId);

      // Set this one as hero
      await _supabase
          .from('venue_photos')
          .update({'is_hero_image': true})
          .eq('id', photoId);

      await fetchPhotos(venueId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reorderPhotos(String venueId, List<String> orderedIds) async {
    try {
      // Optimistic
      _photos.sort((a, b) {
        final indexA = orderedIds.indexOf(a.id);
        final indexB = orderedIds.indexOf(b.id);
        return indexA.compareTo(indexB);
      });
      notifyListeners();

      for (int i = 0; i < orderedIds.length; i++) {
        await _supabase
            .from('venue_photos')
            .update({'sort_order': i})
            .eq('id', orderedIds[i]);
      }
    } catch (e) {
      await fetchPhotos(venueId);
    }
  }
}
