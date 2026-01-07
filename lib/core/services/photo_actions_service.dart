import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class PhotoActionsService {
  static Future<bool> downloadPhoto(String url, String filename) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) return false;

      // Download content
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return false;

      // Get directory to save
      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/Guzellik_${dateStr}_$filename';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Note: On specialized platforms, you'd use something like gallery_saver
      // but path_provider + File works for basic "downloaded" status
      return true;
    } catch (e) {
      print('Download error: $e');
      return false;
    }
  }

  static Future<void> sharePhoto(
    String url,
    String venueName, {
    String? title,
  }) async {
    final message =
        'Mekan: $venueName\n${title ?? "Fotoğraf"}\n\nDaima ile keşfedildi: $url';
    await Share.share(message, subject: '$venueName - ${title ?? "Fotoğraf"}');
  }
}
