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
}

class SignDebugInfo {
  final String rawLabel;
  final double maxConfidence;
  final int inferenceTimeMs;
  final double fps;

  SignDebugInfo({
    required this.rawLabel,
    required this.maxConfidence,
    required this.inferenceTimeMs,
    required this.fps,
  });
}
