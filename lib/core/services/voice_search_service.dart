import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceSearchService {
  static final VoiceSearchService _instance = VoiceSearchService._internal();
  static VoiceSearchService get instance => _instance;
  VoiceSearchService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) => debugPrint('Voice status: $status'),
        onError: (error) => debugPrint('Voice error: $error'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Voice initialization failed: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    required VoidCallback onDone,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('Sesli arama başlatılamadı');
        return;
      }
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      onError('Mikrofon izni verilmedi');
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            onDone();
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'tr_TR',
      );
    } catch (e) {
      onError('Dinleme sırasında bir hata oluştu');
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
