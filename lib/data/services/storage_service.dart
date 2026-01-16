import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../../core/utils/image_utils.dart';

/// Storage service for image and file uploads to FTP Server via PHP API
/// Handles venue images, profile pictures, certificates, etc.
class StorageService {
  static const String _apiBaseUrl = 'https://guzellikharitam.com/api';
  static const String _storageBaseUrl = 'https://guzellikharitam.com/storage';
  static const String _apiKey = 'GuzellikHaritam_Secure_2026_Key';

  /// Upload file to storage via API
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBaseUrl/upload.php'),
      );

      request.headers['Authorization'] = _apiKey;
      request.fields['path'] = bucket == 'venue-images'
          ? 'venue-photos/$path'
          : '$bucket/$path';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename:
              '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}',
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);

      if (response.statusCode == 200 && result['success'] == true) {
        return result['url'];
      } else {
        throw StorageException(result['error'] ?? 'Dosya yüklenemedi');
      }
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
    try {
      // Compress image before upload
      final compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return uploadFile(bucket: bucket, path: path, file: compressedFile);
    } catch (e) {
      // If compression fails, try uploading original
      return uploadFile(bucket: bucket, path: path, file: imageFile);
    }
  }

  /// Upload venue image
  Future<String> uploadVenueImage(File imageFile, String venueId) async {
    return uploadImage(
      bucket: 'venue-images',
      path: venueId,
      imageFile: imageFile,
    );
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    return uploadImage(
      bucket: 'profile-pictures',
      path: userId,
      imageFile: imageFile,
    );
  }

  /// Upload certificate
  Future<String> uploadCertificate(File file, String venueId) async {
    return uploadFile(bucket: 'certificates', path: venueId, file: file);
  }

  /// Get public URL for a file
  String getPublicUrl({required String bucket, required String path}) {
    // Bucket venue-images ise FTP'deki venue-photos klasörüne yönlendir
    final finalBucket = bucket == 'venue-images' ? 'venue-photos' : bucket;
    return '$_storageBaseUrl/$finalBucket/$path';
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final finalBucket = bucket == 'venue-images' ? 'venue-photos' : bucket;
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/delete.php'),
        headers: {'Authorization': _apiKey, 'Content-Type': 'application/json'},
        body: json.encode({'path': '$finalBucket/$path'}),
      );

      if (response.statusCode != 200) {
        final result = json.decode(response.body);
        throw StorageException(result['error'] ?? 'Dosya silinemedi');
      }
    } catch (e) {
      throw StorageException('Dosya silinirken hata oluştu: $e');
    }
  }

  /// Delete file by its full public URL
  Future<void> deleteFileByUrl(String url) async {
    try {
      // Check if URL belongs to our storage
      if (!url.contains('guzellikharitam.com/storage')) {
        print('Skipping delete: URL does not belong to our storage');
        return;
      }

      // Extract path relative to storage/
      // Supports both with and without 'www'
      final storageMarker = '/storage/';
      final startIndex = url.indexOf(storageMarker);
      if (startIndex == -1) return;

      final relativePath = url.substring(startIndex + storageMarker.length);
      print('Attempting to delete relative path: $relativePath');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/delete.php'),
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'path': relativePath}),
      );

      final result = json.decode(response.body);
      if (response.statusCode == 200) {
        print('Delete success: ${result['message']}');
      } else {
        print('Delete failed: ${result['error']}');
      }
    } catch (e) {
      print('Error during deleteFileByUrl: $e');
    }
  }

  /// List files in a directory (Not directly supported via simple PHP API yet)
  Future<List<dynamic>> listFiles({
    required String bucket,
    required String path,
  }) async {
    // FTP listeleme için ek PHP endpoint gerekebilir
    return [];
  }

  /// List ready-to-use category photos from FTP
  Future<List<String>> listCategoryPhotos(String categorySlug) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_apiBaseUrl/list-category-photos.php?category=$categorySlug',
        ),
        headers: {'Authorization': _apiKey},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return List<String>.from(result['photos']);
        }
      }
      return [];
    } catch (e) {
      print('Error listing category photos: $e');
      return [];
    }
  }

  /// Download file
  Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final url = getPublicUrl(bucket: bucket, path: path);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw StorageException('Dosya indirilemedi');
      }
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
