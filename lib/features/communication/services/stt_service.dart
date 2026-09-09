import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ISTTService {
  Future<bool> initialize();
  Future<bool> hasPermission();
  Future<void> startListening({
    required Function(String text) onResult,
    Function(double soundLevel)? onSoundLevelChange,
    Function(String status)? onStatus,
    Function(String error)? onError,
  });
  Future<void> stopListening();
  Future<void> cancelListening();
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
      _isInitialized = await _speechToText.initialize(
        onError: (errorNotification) {
          // Handled via listener or startListening
        },
        onStatus: (status) {
          // Handled via listener or startListening
        },
      );
      return _isInitialized;
    }
    return false;
  }

  @override
  Future<void> startListening({
    required Function(String text) onResult,
    Function(double soundLevel)? onSoundLevelChange,
    Function(String status)? onStatus,
    Function(String error)? onError,
  }) async {
    if (!_isInitialized) {
      final init = await initialize();
      if (!init) return;
    }

    if (onStatus != null) {
      _speechToText.statusListener = (status) => onStatus(status);
    }
    if (onError != null) {
      _speechToText.errorListener = (error) => onError(error.errorMsg);
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      onSoundLevelChange: onSoundLevelChange,
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 5),
        localeId: 'id_ID',
      ),
    );
  }

  @override
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  @override
  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }
}

