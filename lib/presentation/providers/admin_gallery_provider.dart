import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/venue_photo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class AdminGalleryProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<VenuePhoto> _photos = [];
  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0;

  List<VenuePhoto> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;
  bool get canAddMore => _photos.length < 5;

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
    debugPrint('=== UPLOAD PHOTO START ===');
    debugPrint('Venue ID: $venueId');
    debugPrint('Image path: ${imageFile.path}');
    debugPrint('Can add more: $canAddMore');

    if (!canAddMore) {
      debugPrint('ERROR: Cannot add more photos (max 5)');
      throw Exception('Maksimum 5 fotoğraf yükleyebilirsiniz.');
    }

    _isLoading = true;
    _uploadProgress = 0;
    notifyListeners();

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final filePath = '$venueId/$fileName';
      debugPrint('Upload path: $filePath');

      // 1. Upload to Storage
      debugPrint('Step 1: Uploading to storage...');
      await _supabase.storage
          .from('venue-gallery')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      debugPrint('Step 1: Upload successful');

      // 2. Get Public URL
      debugPrint('Step 2: Getting public URL...');
      final imageUrl = _supabase.storage
          .from('venue-gallery')
          .getPublicUrl(filePath);
      debugPrint('Step 2: URL: $imageUrl');

      // 3. Create DB Record
      debugPrint('Step 3: Creating DB record...');
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
      debugPrint('Step 3: DB record created');

      debugPrint('Step 4: Fetching updated photos...');
      await fetchPhotos(venueId);
      debugPrint('=== UPLOAD PHOTO SUCCESS ===');
    } catch (e) {
      debugPrint('=== UPLOAD PHOTO ERROR ===');
      debugPrint('Error: $e');
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

      // 2. Delete from Storage (URL'den dosya yolunu çıkarıyoruz)
      final uri = Uri.parse(photo.url);
      final pathSegments = uri.pathSegments;
      // public/storage/v1/object/public/venue-gallery/VENUE_ID/FILENAME
      if (pathSegments.length >= 2) {
        final storagePath = pathSegments
            .sublist(pathSegments.length - 2)
            .join('/');
        await _supabase.storage.from('venue-gallery').remove([storagePath]);
      }

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
