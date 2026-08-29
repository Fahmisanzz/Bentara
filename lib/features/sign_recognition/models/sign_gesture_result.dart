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
