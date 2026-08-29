import 'package:flutter/foundation.dart';
import 'dart:typed_data';
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

class TFLiteSignClassifierService implements ISignClassifierService {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isProcessing = false;
  DateTime _lastDetectionTime = DateTime.now();
  String? _previousLabel;
  int _consecutiveCount = 0;
  
  static const int inputSize = 224; // Ukuran standar model Teachable Machine

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
    
    // Batasi 2 frame per detik agar UI tidak macet saat konversi gambar
    if (DateTime.now().difference(_lastDetectionTime).inMilliseconds < 500) {
      return;
    }

    _isProcessing = true;

    try {
      // 1. Konversi format kamera (YUV/BGRA) ke format gambar standar (RGB)
      img.Image? convertedImage = _convertCameraImage(image);
      
      if (convertedImage == null) {
        _isProcessing = false;
        return;
      }

      // 2. Putar gambar agar sesuai posisi asli sensor HP
      if (sensorOrientation != 0) {
        convertedImage = img.copyRotate(convertedImage, angle: sensorOrientation);
      }

      // 3. Potong (Crop) dan sesuaikan ukuran (Resize) menjadi 224x224 pixel
      img.Image resizedImage = img.copyResizeCropSquare(convertedImage, size: inputSize);

      // 4. Siapkan Tensor Input (Ubah piksel RGB menjadi rentang -1 hingga 1)
      var inputTensor = _imageToByteListFloat32(resizedImage, inputSize);
      var inputBuffer = inputTensor.buffer.asUint8List();

      // 5. Siapkan Tensor Output
      var outputShape = _interpreter!.getOutputTensor(0).shape; // misal: [1, 5]
      var outputBuffer = List.filled(outputShape[1], 0.0).reshape(outputShape);

      // 6. Jalankan Inferensi (Prediksi)
      _interpreter!.run(inputBuffer, outputBuffer);

      // 7. Ambil probabilitas tertinggi
      List<double> probabilities = (outputBuffer[0] as List).cast<double>();
      
      double maxProb = 0.0;
      int maxIndex = -1;
      
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // 8. Tentukan Hasil (Ambang batas ditingkatkan ke 90% dan wajib 2 frame berturut-turut stabil)
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

        // Butuh 2 frame berturut-turut untuk validasi (mencegah kedipan atau false positive wajah)
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

  // --- FUNGSI UTILITAS KONVERSI GAMBAR KAMERA ---

  img.Image? _convertCameraImage(CameraImage image) {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
    return null;
  }

  img.Image _convertBGRA8888(CameraImage image) {
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  img.Image _convertYUV420(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final img.Image imgBase = img.Image(width: width, height: height);

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final int index = y * image.planes[0].bytesPerRow + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + vp * 1436 / 1024 - 179).round();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
        int b = (yp + up * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        imgBase.setPixelRgb(x, y, r, g, b);
      }
    }
    return imgBase;
  }

  Float32List _imageToByteListFloat32(img.Image image, int inputSize) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        // Normalisasi warna RGB dari rentang 0-255 menjadi rentang -1.0 hingga 1.0
        // Ini adalah format input wajib untuk model klasifikasi Teachable Machine
        buffer[pixelIndex++] = (pixel.r / 127.5) - 1.0;
        buffer[pixelIndex++] = (pixel.g / 127.5) - 1.0;
        buffer[pixelIndex++] = (pixel.b / 127.5) - 1.0;
      }
    }
    return convertedBytes;
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
  }
}
