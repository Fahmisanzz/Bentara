import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../communication/providers/communication_provider.dart';
import '../services/sign_classifier_service.dart';
import 'sign_recognition_state.dart';
import '../models/sign_gesture_result.dart';

final signClassifierServiceProvider = Provider<ISignClassifierService>((ref) => TFLiteSignClassifierService());

class SignRecognitionNotifier extends StateNotifier<SignRecognitionState> {
  final ISignClassifierService _classifierService;
  final Ref _ref;
  
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];

  SignRecognitionNotifier(this._classifierService, this._ref) : super(SignRecognitionState.initial());

  CameraController? get cameraController => _cameraController;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        state = state.copyWith(errorMessage: 'Kamera tidak ditemukan pada perangkat ini.');
        return;
      }
      await _setupCamera(state.isFrontCamera);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal membuka kamera: $e');
    }
  }

  Future<void> _setupCamera(bool useFront) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    final cameraIndex = _cameras.indexWhere((c) => c.lensDirection == (useFront ? CameraLensDirection.front : CameraLensDirection.back));
    final targetCamera = cameraIndex != -1 ? _cameras[cameraIndex] : _cameras.first;

    _cameraController = CameraController(
      targetCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _classifierService.initialize();

    state = state.copyWith(isCameraInitialized: true, isDetecting: true, errorMessage: null, isFrontCamera: useFront);

    // Start video stream
    _cameraController!.startImageStream((image) {
      if (!state.isDetecting) return;
      
      _classifierService.processCameraImage(image, targetCamera.sensorOrientation, (result) {
        if (result != null && result.confidence >= state.confidenceThreshold) {
          _onGestureDetected(result);
        }
      });
    });
  }

  void _onGestureDetected(SignGestureResult result) {
    // Avoid repeating the same gesture too quickly
    if (state.currentGesture != null && 
        state.currentGesture!.gestureName == result.gestureName &&
        DateTime.now().difference(state.currentGesture!.timestamp).inSeconds < 2) {
      return;
    }

    final newSentence = state.composedSentence.isEmpty 
        ? result.mappedText 
        : '${state.composedSentence} ${result.mappedText}';

    state = state.copyWith(
      currentGesture: result,
      composedSentence: newSentence,
    );
  }

  Future<void> flipCamera() async {
    state = state.copyWith(isCameraInitialized: false);
    await _setupCamera(!state.isFrontCamera);
  }

  void clearSentence() {
    state = state.copyWith(composedSentence: '', currentGesture: null);
  }

  Future<void> speakSentence() async {
    if (state.composedSentence.trim().isEmpty) return;
    
    // Pause detection while speaking
    state = state.copyWith(isDetecting: false);
    
    // Use TTS from communication provider
    final ttsService = _ref.read(ttsServiceProvider);
    await ttsService.speak(state.composedSentence);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) state = state.copyWith(isDetecting: true);
    });
  }

  @override
  void dispose() {
    state = state.copyWith(isDetecting: false);
    _cameraController?.dispose();
    _classifierService.dispose();
    super.dispose();
  }
}

final signRecognitionNotifierProvider = StateNotifierProvider.autoDispose<SignRecognitionNotifier, SignRecognitionState>((ref) {
  return SignRecognitionNotifier(ref.read(signClassifierServiceProvider), ref);
});
