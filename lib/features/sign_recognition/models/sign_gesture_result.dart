import 'dart:typed_data';

class SignGestureResult {
  final String gestureName;
  final double confidence;
  final DateTime timestamp;
  final String mappedText;

  SignGestureResult({
    required this.gestureName,
    required this.confidence,
    required this.timestamp,
    required this.mappedText,
  });

  SignGestureResult copyWith({
    String? gestureName,
    double? confidence,
    DateTime? timestamp,
    String? mappedText,
  }) {
    return SignGestureResult(
      gestureName: gestureName ?? this.gestureName,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      mappedText: mappedText ?? this.mappedText,
    );
  }
}

class SignDebugInfo {
  final String rawLabel;
  final double maxConfidence;
  final int inferenceTimeMs;
  final double fps;
  final Uint8List? previewImage;
  final int handsDetected;
  final bool leftHandDetected;
  final bool rightHandDetected;
  final int featureCount;

  SignDebugInfo({
    required this.rawLabel,
    required this.maxConfidence,
    required this.inferenceTimeMs,
    required this.fps,
    this.previewImage,
    this.handsDetected = 0,
    this.leftHandDetected = false,
    this.rightHandDetected = false,
    this.featureCount = 126,
  });
}
