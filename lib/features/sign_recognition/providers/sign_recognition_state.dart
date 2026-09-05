import '../models/sign_gesture_result.dart';

class SignRecognitionState {
  final bool isCameraInitialized;
  final bool isDetecting;
  final SignGestureResult? currentGesture;
  final String composedSentence;
  final double confidenceThreshold;
  final String? errorMessage;
  final bool isFrontCamera;
  final SignDebugInfo? debugInfo;

  SignRecognitionState({
    required this.isCameraInitialized,
    required this.isDetecting,
    this.currentGesture,
    required this.composedSentence,
    required this.confidenceThreshold,
    this.errorMessage,
    this.isFrontCamera = true,
    this.debugInfo,
  });

  factory SignRecognitionState.initial() {
    return SignRecognitionState(
      isCameraInitialized: false,
      isDetecting: false,
      currentGesture: null,
      composedSentence: '',
      confidenceThreshold: 0.58,
      errorMessage: null,
      isFrontCamera: true,
      debugInfo: null,
    );
  }

  SignRecognitionState copyWith({
    bool? isCameraInitialized,
    bool? isDetecting,
    SignGestureResult? currentGesture,
    String? composedSentence,
    double? confidenceThreshold,
    String? errorMessage,
    bool? isFrontCamera,
    SignDebugInfo? debugInfo,
  }) {
    return SignRecognitionState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      isDetecting: isDetecting ?? this.isDetecting,
      currentGesture: currentGesture ?? this.currentGesture,
      composedSentence: composedSentence ?? this.composedSentence,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      errorMessage: errorMessage ?? this.errorMessage,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      debugInfo: debugInfo ?? this.debugInfo,
    );
  }
}
