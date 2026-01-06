import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Storage service for image and file uploads to Supabase Storage
/// Handles venue images, profile pictures, certificates, etc.
class StorageService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  /// Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$path/$fileName';
      
      await _supabaseService.storage
          .from(bucket)
          .uploadBinary(filePath, bytes);
      
      return getPublicUrl(bucket: bucket, path: filePath);
    } catch (e) {
      throw StorageException('Dosya yüklenirken hata oluştu: $e');
    }
  }
  
  /// Upload image with compression
  Future<String> uploadImage({
    required String bucket,
    required String path,
    required File imageFile,
  }) async {
    // TODO: Add image compression before upload
    return await uploadFile(
      bucket: bucket,
      path: path,
      file: imageFile,
    );
  }
  
  /// Upload venue image
  Future<String> uploadVenueImage(File imageFile, String venueId) async {
    return await uploadImage(
      bucket: 'venue-images',
      path: venueId,
      imageFile: imageFile,
    );
  }
  
  /// Upload profile picture
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    return await uploadImage(
      bucket: 'profile-pictures',
      path: userId,
      imageFile: imageFile,
    );
  }
  
  /// Upload certificate
  Future<String> uploadCertificate(File file, String venueId) async {
    return await uploadFile(
      bucket: 'certificates',
      path: venueId,
      file: file,
    );
  }
  
  /// Get public URL for a file
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _supabaseService.storage.from(bucket).getPublicUrl(path);
  }
  
  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabaseService.storage.from(bucket).remove([path]);
    } catch (e) {
      throw StorageException('Dosya silinirken hata oluştu: $e');
    }
  }
  
  /// List files in a directory
  Future<List<FileObject>> listFiles({
    required String bucket,
    required String path,
  }) async {
    try {
      return await _supabaseService.storage.from(bucket).list(path: path);
    } catch (e) {
      throw StorageException('Dosyalar listelenirken hata oluştu: $e');
    }
  }
  
  /// Download file
  Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      return await _supabaseService.storage.from(bucket).download(path);
    } catch (e) {
      throw StorageException('Dosya indirilirken hata oluştu: $e');
    }
  }
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  
  @override
  String toString() => message;
}
