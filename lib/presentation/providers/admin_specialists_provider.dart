import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/specialist.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class AdminSpecialistsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

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
      debugPrint(
        '🔵 [addSpecialist] Başlıyor: venueId=$venueId, name=$name, profession=$profession, gender=$gender',
      );

      String? photoUrl;

      // Image upload step
      if (imageFile != null) {
        try {
          debugPrint('📤 [addSpecialist] Resim yükleme başlıyor...');
          final fileName =
              'specialist_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
          final storagePath = '$venueId/$fileName';

          debugPrint('📤 [addSpecialist] Storage path: $storagePath');

          await _supabase.storage
              .from('specialists')
              .upload(storagePath, imageFile);

          debugPrint('✅ [addSpecialist] Resim yüklendi');

          photoUrl = _supabase.storage
              .from('specialists')
              .getPublicUrl(storagePath);

          debugPrint('🔗 [addSpecialist] Photo URL: $photoUrl');
        } catch (e) {
          debugPrint('❌ [addSpecialist] Resim yükleme hatası: $e');
          rethrow;
        }
      } else {
        debugPrint('ℹ️ [addSpecialist] Resim yok, atlanıyor');
      }

      // Database insert step
      try {
        debugPrint('💾 [addSpecialist] Veritabanına ekleme başlıyor...');

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

        debugPrint('💾 [addSpecialist] Eklenecek veri: $insertData');

        await _supabase.from('specialists').insert(insertData);

        debugPrint('✅ [addSpecialist] Veritabanına eklendi');
      } catch (e) {
        debugPrint('❌ [addSpecialist] Veritabanı ekleme hatası: $e');
        rethrow;
      }

      // Refresh specialists list
      try {
        debugPrint('🔄 [addSpecialist] Uzman listesi yenileniyor...');
        await fetchSpecialists(venueId);
        debugPrint('✅ [addSpecialist] İşlem başarıyla tamamlandı');
      } catch (e) {
        debugPrint('❌ [addSpecialist] Listeyi yenileme hatası: $e');
        rethrow;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('🔴 [addSpecialist] GENEL HATA: $e');
      debugPrint('🔴 [addSpecialist] Hata detayı: ${e.runtimeType}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint(
        '🏁 [addSpecialist] İşlem tamamlandı, notifyListeners çağrıldı',
      );
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
        // Fetch current to delete old image if needed
        final current = _specialists.firstWhere((s) => s.id == specialistId);
        final venueId = current.venueId;

        final fileName =
            'specialist_${DateTime.now().millisecondsSinceEpoch}${path.extension(newImageFile.path)}';
        final storagePath = '$venueId/$fileName';

        await _supabase.storage
            .from('specialists')
            .upload(storagePath, newImageFile);
        updates['photo_url'] = _supabase.storage
            .from('specialists')
            .getPublicUrl(storagePath);
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
        final uri = Uri.parse(spec.photoUrl!);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 2) {
          final storagePath = pathSegments
              .sublist(pathSegments.length - 2)
              .join('/');
          await _supabase.storage.from('specialists').remove([storagePath]);
        }
      }

      await fetchSpecialists(venueId);
    } catch (e) {
      rethrow;
    }
  }
}
