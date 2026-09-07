import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/sign_gesture_result.dart';
import '../models/sign_vocabulary.dart';

class GestureClassifier {
  Interpreter? _interpreter;
  List<String> _labels = [];
  static const int numHands = 2;
  static const int landmarksPerHand = 21;
  static const int coordsPerLandmark = 3;
  static const int handFeatureSize = 63; // 21 * 3
  static const int featureSize = 126; // 2 * 63
  final int _sequenceLength = 30;
  final List<List<double>> _framesBuffer = [];

  /// Minimum confidence to accept a prediction (tuned to 0.70 to accept natural gesture variations like pintar at 0.725).
  static const double confidenceThreshold = 0.70;
  /// Number of consecutive same-label predictions required before emitting.
  static const int requiredConsecutive = 2;
  /// Minimum interval between inference calls (ms).
  static const int inferenceThrottleMs = 200;
  
  bool _isProcessing = false;
  String? _previousLabel;
  int _consecutiveCount = 0;
  DateTime _lastPredictTime = DateTime.fromMillisecondsSinceEpoch(0);

  int _lastHandsDetected = 0;
  bool _lastLeftDetected = false;
  bool _lastRightDetected = false;

  int get sequenceLength => _sequenceLength;
  int get currentBufferLength => _framesBuffer.length;
  List<String> get labels => List.unmodifiable(_labels);
  Interpreter? get interpreter => _interpreter;

  Future<void> initialize({Interpreter? injectedInterpreter}) async {
    try {
      if (injectedInterpreter != null) {
        _interpreter = injectedInterpreter;
      } else {
        _interpreter = await Interpreter.fromAsset('assets/models/bisindo_model.tflite');
      }
      
      final labelsData = await rootBundle.loadString('assets/models/label_map.json');
      final Map<String, dynamic> jsonMap = json.decode(labelsData);
      
      _labels = List.generate(jsonMap.length, (index) => '');
      jsonMap.forEach((key, value) {
        int idx = int.tryParse(key) ?? -1;
        if (idx >= 0 && idx < _labels.length) {
          _labels[idx] = value.toString();
        }
      });

      debugPrint('[BISINDO] Model LSTM 2-Hand loaded. Shape: [1, $_sequenceLength, $featureSize], Classes: ${_labels.length}, Labels: $_labels');
    } catch (e) {
      debugPrint('Error initializing LSTM model: $e');
    }
  }

  /// Normalizes a 126-feature frame matching 02_preprocess_data.py exactly:
  /// - Hand 0 (Left): indices 0..62
  /// - Hand 1 (Right): indices 63..125
  /// Each hand is independently wrist-relative and scaled by maximum distance from wrist.
  /// Unobserved hands remain 0.0.
  static List<double> normalizeFrame(List<double> rawLandmarks) {
    if (rawLandmarks.length != featureSize) {
      return List.filled(featureSize, 0.0);
    }

    final normalized = List<double>.from(rawLandmarks);

    for (int h = 0; h < numHands; h++) {
      final int startIdx = h * handFeatureSize;
      final int endIdx = startIdx + handFeatureSize;

      // Check if hand is detected (any non-zero coordinate)
      bool isDetected = false;
      for (int i = startIdx; i < endIdx; i++) {
        if (normalized[i] != 0.0) {
          isDetected = true;
          break;
        }
      }

      if (isDetected) {
        final double wristX = normalized[startIdx];
        final double wristY = normalized[startIdx + 1];
        final double wristZ = normalized[startIdx + 2];

        double maxDist = 0.0;
        for (int i = 0; i < landmarksPerHand; i++) {
          final int idx = startIdx + (i * coordsPerLandmark);
          final double nx = normalized[idx] - wristX;
          final double ny = normalized[idx + 1] - wristY;
          final double nz = normalized[idx + 2] - wristZ;

          normalized[idx] = nx;
          normalized[idx + 1] = ny;
          normalized[idx + 2] = nz;

          final double dist = sqrt(nx * nx + ny * ny + nz * nz);
          if (dist > maxDist) {
            maxDist = dist;
          }
        }

        if (maxDist > 0.0) {
          for (int i = startIdx; i < endIdx; i++) {
            normalized[i] = normalized[i] / maxDist;
          }
        }
      }
    }

    // Sanitize values to prevent NaN or Infinity
    for (int i = 0; i < featureSize; i++) {
      if (normalized[i].isNaN || normalized[i].isInfinite) {
        normalized[i] = 0.0;
      }
    }

    return normalized;
  }

  int _consecutiveEmptyFrames = 0;

  /// Adds a frame of 126 coordinates to the sliding buffer.
  void addFrame(List<double>? landmarks) {
    if (landmarks == null || landmarks.length != featureSize) {
      _lastHandsDetected = 0;
      _lastLeftDetected = false;
      _lastRightDetected = false;
      _consecutiveEmptyFrames++;

      // Tolerate brief micro-occlusions (up to 10 frames / ~400ms) before treating as full rest
      if (_consecutiveEmptyFrames >= 10) {
        _framesBuffer.clear();
        _previousLabel = null;
        _consecutiveCount = 0;
      } else {
        _framesBuffer.add(List.filled(featureSize, 0.0));
        if (_framesBuffer.length > _sequenceLength) {
          _framesBuffer.removeAt(0);
        }
      }
      return;
    }

    // Check hand presence
    bool hasLeft = false;
    for (int i = 0; i < handFeatureSize; i++) {
      if (landmarks[i] != 0.0) {
        hasLeft = true;
        break;
      }
    }

    bool hasRight = false;
    for (int i = handFeatureSize; i < featureSize; i++) {
      if (landmarks[i] != 0.0) {
        hasRight = true;
        break;
      }
    }

    _lastLeftDetected = hasLeft;
    _lastRightDetected = hasRight;
    _lastHandsDetected = (hasLeft ? 1 : 0) + (hasRight ? 1 : 0);

    if (_lastHandsDetected == 0) {
      _consecutiveEmptyFrames++;
      // Full resting state when hands lowered for >= 10 frames (~400-500ms)
      if (_consecutiveEmptyFrames >= 10) {
        _framesBuffer.clear();
        _previousLabel = null;
        _consecutiveCount = 0;
        return;
      }
    } else {
      _consecutiveEmptyFrames = 0;
    }

    final normalized = normalizeFrame(landmarks);
    _framesBuffer.add(normalized);

    if (_framesBuffer.length > _sequenceLength) {
      _framesBuffer.removeAt(0);
    }
  }

  void resetBuffer() {
    _framesBuffer.clear();
    _previousLabel = null;
    _consecutiveCount = 0;
    _consecutiveEmptyFrames = 0;
    _lastHandsDetected = 0;
    _lastLeftDetected = false;
    _lastRightDetected = false;
  }

  /// Run LSTM inference when buffer is full (30 frames x 126 features)
  Future<void> predict(Function(SignGestureResult?, SignDebugInfo?) onResult) async {
    if (_interpreter == null || _labels.isEmpty || _isProcessing) return;
    
    // Only run prediction if hands are actively present in the camera
    if (_lastHandsDetected == 0) {
      _consecutiveCount = 0;
      _previousLabel = null;
      return;
    }

    if (_framesBuffer.length < _sequenceLength) return;

    if (DateTime.now().difference(_lastPredictTime).inMilliseconds < inferenceThrottleMs) {
      return;
    }

    _isProcessing = true;
    _lastPredictTime = DateTime.now();
    final startTime = DateTime.now();

    try {
      // Validate input buffer dimensions: [1, 30, 126]
      if (_framesBuffer.length != _sequenceLength || _framesBuffer[0].length != featureSize) {
        debugPrint('Validation Error: Buffer shape mismatch. Expected [$_sequenceLength, $featureSize], got [${_framesBuffer.length}, ${_framesBuffer.isNotEmpty ? _framesBuffer[0].length : 0}]');
        return;
      }

      // Shape: [1, 30, 126]
      final input = [_framesBuffer.toList()];
      final output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      _interpreter!.run(input, output);

      final List<double> probabilities = (output[0] as List).cast<double>();
      
      double maxProb = 0.0;
      int maxIndex = -1;
      
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      final inferenceTime = DateTime.now().difference(startTime).inMilliseconds;
      
      if (maxIndex >= 0 && maxIndex < _labels.length) {
        final rawLabel = _labels[maxIndex];
        final mappedText = SignVocabulary.lookup(rawLabel);
        final displayName = SignVocabulary.getDisplayName(rawLabel);

        final debugInfo = SignDebugInfo(
          rawLabel: rawLabel,
          maxConfidence: maxProb,
          inferenceTimeMs: inferenceTime,
          fps: 1000 / (inferenceTime > 0 ? inferenceTime : 1),
          previewImage: null,
          handsDetected: _lastHandsDetected,
          leftHandDetected: _lastLeftDetected,
          rightHandDetected: _lastRightDetected,
          featureCount: featureSize,
        );

        // Log top-3 predictions for diagnostics
        final sortedIndices = List.generate(probabilities.length, (i) => i)
          ..sort((a, b) => probabilities[b].compareTo(probabilities[a]));
        debugPrint('[BISINDO] Prediction: '
            'Top1=${_labels[sortedIndices[0]]}(${probabilities[sortedIndices[0]].toStringAsFixed(3)}) '
            'Top2=${_labels[sortedIndices[1]]}(${probabilities[sortedIndices[1]].toStringAsFixed(3)}) '
            'Top3=${_labels[sortedIndices[2]]}(${probabilities[sortedIndices[2]].toStringAsFixed(3)}) '
            'Hands=$_lastHandsDetected L=$_lastLeftDetected R=$_lastRightDetected '
            '${inferenceTime}ms');

        if (mappedText != null && maxProb > confidenceThreshold) {
          if (rawLabel == _previousLabel) {
            _consecutiveCount++;
          } else {
            _previousLabel = rawLabel;
            _consecutiveCount = 1;
          }

          if (_consecutiveCount >= requiredConsecutive) {
            final result = SignGestureResult(
              gestureName: displayName,
              confidence: maxProb,
              timestamp: DateTime.now(),
              mappedText: mappedText,
            );
            onResult(result, debugInfo);
            _consecutiveCount = 0;
            // Fully flush buffer after successful gesture recognition
            // so stale frames never pollute subsequent different gestures.
            _framesBuffer.clear();
          } else {
            onResult(null, debugInfo);
          }
        } else {
          _previousLabel = null;
          _consecutiveCount = 0;
          onResult(null, debugInfo);
        }
      }
    } catch (e) {
      debugPrint('Error during LSTM inference: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
