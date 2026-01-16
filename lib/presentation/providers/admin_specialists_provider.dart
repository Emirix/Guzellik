import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/specialist.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/storage_service.dart';

class AdminSpecialistsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _storageService = StorageService();

  List<Specialist> _specialists = [];
  bool _isLoading = false;
  String? _error;

  List<Specialist> get specialists => _specialists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSpecialists(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('specialists')
          .select()
          .eq('venue_id', venueId)
          .order('sort_order', ascending: true);

      _specialists = (response as List)
          .map((json) => Specialist.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSpecialist(
    String venueId, {
    required String name,
    required String profession,
    required String gender,
    File? imageFile,
    String? bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? photoUrl;

      // Image upload step
      if (imageFile != null) {
        try {
          photoUrl = await _storageService.uploadImage(
            bucket: 'specialists',
            path: venueId,
            imageFile: imageFile,
          );
        } catch (e) {
          debugPrint('❌ [addSpecialist] Resim yükleme hatası: $e');
          rethrow;
        }
      }

      // Database insert step
      try {
        // Map gender to Turkish for database constraint
        String dbGender;
        switch (gender.toLowerCase()) {
          case 'male':
            dbGender = 'Erkek';
            break;
          case 'female':
            dbGender = 'Kadın';
            break;
          default:
            dbGender = 'Belirtilmemiş';
        }

        final insertData = {
          'venue_id': venueId,
          'name': name,
          'profession': profession,
          'gender': dbGender,
          'photo_url': photoUrl,
          'bio': bio,
        };

        await _supabase.from('specialists').insert(insertData);
      } catch (e) {
        rethrow;
      }

      await fetchSpecialists(venueId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSpecialist(
    String specialistId, {
    String? name,
    String? profession,
    String? gender,
    File? newImageFile,
    String? bio,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (profession != null) updates['profession'] = profession;
      if (gender != null) {
        // Map gender to Turkish for database constraint
        switch (gender.toLowerCase()) {
          case 'male':
            updates['gender'] = 'Erkek';
            break;
          case 'female':
            updates['gender'] = 'Kadın';
            break;
          default:
            updates['gender'] = 'Belirtilmemiş';
        }
      }
      if (bio != null) updates['bio'] = bio;

      if (newImageFile != null) {
        final current = _specialists.firstWhere((s) => s.id == specialistId);
        final venueId = current.venueId;

        // Delete old image if exists
        if (current.photoUrl != null) {
          _storageService.deleteFileByUrl(current.photoUrl!);
        }

        updates['photo_url'] = await _storageService.uploadImage(
          bucket: 'specialists',
          path: venueId,
          imageFile: newImageFile,
        );
      }

      await _supabase
          .from('specialists')
          .update(updates)
          .eq('id', specialistId);

      final current = _specialists.firstWhere((s) => s.id == specialistId);
      await fetchSpecialists(current.venueId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSpecialist(String specialistId) async {
    try {
      final spec = _specialists.firstWhere((s) => s.id == specialistId);
      final venueId = spec.venueId;

      await _supabase.from('specialists').delete().eq('id', specialistId);

      if (spec.photoUrl != null) {
        await _storageService.deleteFileByUrl(spec.photoUrl!);
      }

      await fetchSpecialists(venueId);
    } catch (e) {
      rethrow;
    }
  }
}
