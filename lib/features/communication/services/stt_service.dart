import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ISTTService {
  Future<bool> initialize();
  Future<bool> hasPermission();
  Future<void> startListening({required Function(String text) onResult});
  Future<void> stopListening();
  bool get isListening;
}

class SpeechToTextService implements ISTTService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  @override
  bool get isListening => _speechToText.isListening;

  @override
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _isInitialized = await _speechToText.initialize();
      return _isInitialized;
    }
    return false;
  }

  @override
  Future<void> startListening({required Function(String text) onResult}) async {
    if (!_isInitialized) {
      final init = await initialize();
      if (!init) return;
    }
    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(cancelOnError: false, partialResults: true),
      localeId: 'id_ID',
    );
  }

  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}
