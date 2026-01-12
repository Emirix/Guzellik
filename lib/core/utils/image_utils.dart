import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageUtils {
  /// Compresses an image file and returns the compressed file.
  /// [quality] is the quality of compression (1-100).
  /// [maxWidth] and [maxHeight] are the maximum dimensions of the compressed image.
  static Future<File> compressImage(
    File file, {
    int quality = 80,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    // Bypass compression on Windows to avoid potential missing plugin errors
    if (Platform.isWindows) {
      debugPrint('Bypassing image compression on Windows.');
      return file;
    }

    try {
      final String extension = p.extension(file.path).toLowerCase();
      // Only compress common formats, or default to jpg for temp
      final String targetExtension =
          (extension == '.png' ||
              extension == '.jpg' ||
              extension == '.jpeg' ||
              extension == '.webp')
          ? extension
          : '.jpg';

      final String targetPath = p.join(
        (await getTemporaryDirectory()).path,
        'temp_${DateTime.now().millisecondsSinceEpoch}$targetExtension',
      );

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: quality,
            minWidth: maxWidth,
            minHeight: maxHeight,
            format: _getFormatFromExtension(targetExtension),
          );

      if (compressedFile == null) {
        debugPrint('Image compression returned null, using original file.');
        return file;
      }

      return File(compressedFile.path);
    } catch (e) {
      debugPrint('Error during image compression: $e');
      return file;
    }
  }

  static CompressFormat _getFormatFromExtension(String ext) {
    switch (ext) {
      case '.png':
        return CompressFormat.png;
      case '.webp':
        return CompressFormat.webp;
      case '.heic':
        return CompressFormat.heic;
      default:
        return CompressFormat.jpeg;
    }
  }
}
