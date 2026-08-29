import 'package:flutter_tts/flutter_tts.dart';

abstract class ITTSService {
  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setLanguage(String langCode);
  Future<void> setSpeechRate(double rate);
}

class FlutterTtsService implements ITTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  @override
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  Future<void> setLanguage(String langCode) async {
    await _flutterTts.setLanguage(langCode);
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }
}
