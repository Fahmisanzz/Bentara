import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/sign_gesture_result.dart';
import '../models/sign_vocabulary.dart';

abstract class ISignClassifierService {
  Future<void> initialize();
  void processCameraImage(CameraImage image, int sensorOrientation, Function(SignGestureResult?) onResult);
  Future<void> dispose();
}

// -----------------------------------------------------------------------------
// FUNGSI ISOLATE TOP-LEVEL (Jalan di Background Thread agar UI tidak Lag)
// -----------------------------------------------------------------------------
Future<Float32List?> _processImageInIsolate(Map<String, dynamic> params) async {
  try {
    final int width = params['width'];
    final int height = params['height'];
    final String format = params['format'];
    final List<Uint8List> planeBytes = params['planeBytes'];
    final List<int> bytesPerRow = params['bytesPerRow'];
    final List<int?> bytesPerPixel = params['bytesPerPixel'];
    final int sensorOrientation = params['sensorOrientation'];
    const int inputSize = 224;

    img.Image? imgBase;

    // 1. Direct Downsampled YUV420 Conversion to 224x224 (Blazingly Fast)
    if (format == 'yuv420') {
      imgBase = img.Image(width: inputSize, height: inputSize);
      final int uvRowStride = bytesPerRow[1];
      final int uvPixelStride = bytesPerPixel[1] ?? 1;

      final double scaleX = width / inputSize;
      final double scaleY = height / inputSize;

      for (int y = 0; y < inputSize; y++) {
        final int origY = (y * scaleY).toInt().clamp(0, height - 1);
        final int yIndexOffset = origY * bytesPerRow[0];
        final int uvRowOffset = uvRowStride * (origY ~/ 2);

        for (int x = 0; x < inputSize; x++) {
          final int origX = (x * scaleX).toInt().clamp(0, width - 1);
          final int uvIndex = uvPixelStride * (origX ~/ 2) + uvRowOffset;
          final int index = yIndexOffset + origX;

          final yp = planeBytes[0][index];
          final up = planeBytes[1][uvIndex];
          final vp = planeBytes[2][uvIndex];

          int r = (yp + vp * 1436 / 1024 - 179).round();
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
          int b = (yp + up * 1814 / 1024 - 227).round();

          imgBase.setPixelRgb(
            x, 
            y, 
            r.clamp(0, 255), 
            g.clamp(0, 255), 
            b.clamp(0, 255)
          );
        }
      }
    } else if (format == 'bgra8888') {
      final rawImg = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: planeBytes[0].buffer,
        order: img.ChannelOrder.bgra,
      );
      imgBase = img.copyResizeCropSquare(rawImg, size: inputSize);
    }

    if (imgBase == null) return null;

    // 2. Rotasi jika diperlukan
    if (sensorOrientation != 0) {
      imgBase = img.copyRotate(imgBase, angle: sensorOrientation);
    }

    img.Image resizedImage = imgBase;

    // 4. Konversi ke Tensor Float32List
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    
    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        var pixel = resizedImage.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r / 127.5) - 1.0;
        buffer[pixelIndex++] = (pixel.g / 127.5) - 1.0;
        buffer[pixelIndex++] = (pixel.b / 127.5) - 1.0;
      }
    }

    return convertedBytes;
  } catch (e) {
    debugPrint('Error in isolate: $e');
    return null;
  }
}

class TFLiteSignClassifierService implements ISignClassifierService {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isProcessing = false;
  DateTime _lastDetectionTime = DateTime.now();
  String? _previousLabel;
  int _consecutiveCount = 0;

  @override
  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/model.tflite');
      final labelsData = await rootBundle.loadString('assets/ml/labels.txt');
      _labels = labelsData.split('\n').where((s) => s.trim().isNotEmpty).toList();
      debugPrint('Model TFLite berhasil dimuat. Label: $_labels');
    } catch (e) {
      debugPrint('Gagal memuat model TFLite: $e');
      debugPrint('Pastikan file model.tflite dan labels.txt sudah dimasukkan ke folder assets/ml/');
    }
  }

  @override
  void processCameraImage(CameraImage image, int sensorOrientation, Function(SignGestureResult?) onResult) async {
    if (_isProcessing || _interpreter == null || _labels == null) return;
    
    // Batasi 2 frame per detik agar hemat resource CPU
    if (DateTime.now().difference(_lastDetectionTime).inMilliseconds < 500) {
      return;
    }

    _isProcessing = true;

    try {
      String format;
      if (image.format.group == ImageFormatGroup.yuv420) {
        format = 'yuv420';
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        format = 'bgra8888';
      } else {
        _isProcessing = false;
        return;
      }

      // Siapkan data mentah untuk dikirim ke Isolate
      final isolateParams = {
        'width': image.width,
        'height': image.height,
        'format': format,
        'planeBytes': image.planes.map((p) => p.bytes).toList(),
        'bytesPerRow': image.planes.map((p) => p.bytesPerRow).toList(),
        'bytesPerPixel': image.planes.map((p) => p.bytesPerPixel).toList(),
        'sensorOrientation': sensorOrientation,
      };

      // LEMPAR PROSES BERAT KE BACKGROUND THREAD (COMPUTE)
      final inputTensor = await compute(_processImageInIsolate, isolateParams);

      if (inputTensor == null) {
        _isProcessing = false;
        return;
      }

      // Kembali ke Main Thread, siapkan buffer
      var inputBuffer = inputTensor.buffer.asUint8List();
      var outputShape = _interpreter!.getOutputTensor(0).shape; // misal: [1, 5]
      var outputBuffer = List.filled(outputShape[1], 0.0).reshape(outputShape);

      // Jalankan Inferensi
      _interpreter!.run(inputBuffer, outputBuffer);

      // Ambil probabilitas tertinggi
      List<double> probabilities = (outputBuffer[0] as List).cast<double>();
      
      double maxProb = 0.0;
      int maxIndex = -1;
      
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // Tentukan Hasil
      if (maxProb > 0.90 && maxIndex < _labels!.length) {
        String label = _labels![maxIndex];
        
        // Membersihkan label
        if (label.contains(' ')) {
          label = label.split(' ').sublist(1).join(' ').trim();
        } else {
          label = label.trim();
        }
        
        // Cek kestabilan frame
        if (label == _previousLabel) {
          _consecutiveCount++;
        } else {
          _previousLabel = label;
          _consecutiveCount = 1;
        }

        // Butuh 2 frame berturut-turut untuk validasi
        if (_consecutiveCount >= 2) {
          if (SignVocabulary.dictionary.containsKey(label)) {
             final result = SignGestureResult(
              gestureName: label,
              confidence: maxProb,
              timestamp: DateTime.now(),
              mappedText: SignVocabulary.dictionary[label]!,
            );
            onResult(result);
            _lastDetectionTime = DateTime.now();
            _consecutiveCount = 0; // reset
          } else {
             onResult(null);
          }
        } else {
          onResult(null);
        }
      } else {
        _previousLabel = null;
        _consecutiveCount = 0;
        onResult(null);
      }
      
    } catch (e) {
      debugPrint('Terjadi kesalahan saat memproses TFLite: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
  }
}
