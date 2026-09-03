import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/sign_gesture_result.dart';
import '../models/sign_vocabulary.dart';

abstract class ISignClassifierService {
  Future<void> initialize();
  void processCameraImage(
    CameraImage image, 
    int sensorOrientation, 
    bool isFrontCamera, 
    Function(SignGestureResult?) onResult,
  );
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
    final int sensorOrientation = params['sensorOrientation'] ?? 90;
    final bool isFrontCamera = params['isFrontCamera'] ?? true;
    const int inputSize = 224;

    img.Image? imgBase;

    // 1. Center-Square Crop & Downsampling YUV420 ke 224x224 (Preserve Aspect Ratio)
    if (format == 'yuv420') {
      imgBase = img.Image(width: inputSize, height: inputSize);

      final plane0 = planeBytes[0];
      final plane1 = planeBytes[1];
      final plane2 = planeBytes[2];

      final int yRowStride = bytesPerRow[0];
      final int uvRowStride = bytesPerRow[1];
      final int uvPixelStride = bytesPerPixel[1] ?? 1;

      // Hitung koordinat crop persegi dari tengah frame sensor
      final int cropSize = height < width ? height : width;
      final int startX = (width - cropSize) ~/ 2;
      final int startY = (height - cropSize) ~/ 2;

      final double scale = cropSize / inputSize;

      for (int y = 0; y < inputSize; y++) {
        final int origY = (startY + y * scale).toInt().clamp(0, height - 1);
        final int yIndexOffset = origY * yRowStride;
        final int uvRowOffset = (origY ~/ 2) * uvRowStride;

        for (int x = 0; x < inputSize; x++) {
          final int origX = (startX + x * scale).toInt().clamp(0, width - 1);

          final int yIndex = (yIndexOffset + origX).clamp(0, plane0.length - 1);
          final int uvIndex = uvRowOffset + (origX ~/ 2) * uvPixelStride;
          final int uIndex = uvIndex.clamp(0, plane1.length - 1);
          final int vIndex = uvIndex.clamp(0, plane2.length - 1);

          final int yp = plane0[yIndex];
          final int up = plane1[uIndex];
          final int vp = plane2[vIndex];

          // Konversi warna YUV ke RGB
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

          imgBase.setPixelRgb(x, y, r, g, b);
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

    // 2. Koreksi Rotasi & Cermin (Mirroring)
    // Pada Android:
    // Kamera depan memiliki sensorOrientation 270°. Rotasi agar tegak di portrait adalah (360 - sensorOrientation) % 360 = 90°.
    // Kamera belakang memiliki sensorOrientation 90°. Rotasi agar tegak adalah sensorOrientation = 90°.
    int rotationAngle;
    if (isFrontCamera) {
      rotationAngle = (360 - sensorOrientation) % 360;
    } else {
      rotationAngle = sensorOrientation;
    }

    if (rotationAngle != 0) {
      imgBase = img.copyRotate(imgBase, angle: rotationAngle);
    }

    // Kamera depan di web browser (Teachable Machine) SELALU dicerminkan (mirrored).
    // Sensor kamera HP Android asli TIDAK dicerminkan.
    // Maka gambar kamera depan wajib di-flip horizontal agar posisi tangan kanan & kiri identik dengan model Teachable Machine!
    if (isFrontCamera) {
      imgBase = img.copyFlip(imgBase, direction: img.FlipDirection.horizontal);
    }

    // 3. Konversi ke Tensor Float32List (rentang normalisasi -1.0 hingga 1.0)
    final convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    
    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        final pixel = imgBase.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r / 127.5) - 1.0;
        buffer[pixelIndex++] = (pixel.g / 127.5) - 1.0;
        buffer[pixelIndex++] = (pixel.b / 127.5) - 1.0;
      }
    }

    return convertedBytes;
  } catch (e, stack) {
    debugPrint('Error in isolate image processing: $e\n$stack');
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

  // Detektor Gerakan Dinamis (Motion Energy Gating)
  Uint8List? _previousYPlane;
  DateTime _lastMotionTime = DateTime.fromMillisecondsSinceEpoch(0);

  double _calculateMotion(Uint8List currentY) {
    if (_previousYPlane == null || _previousYPlane!.length != currentY.length) {
      _previousYPlane = Uint8List.fromList(currentY);
      return 0.0;
    }

    int totalDiff = 0;
    int samples = 0;
    const int step = 32; // sampling setiap 32 pixel agar super cepat (<0.1ms CPU)

    for (int i = 0; i < currentY.length; i += step) {
      totalDiff += (currentY[i] - _previousYPlane![i]).abs();
      samples++;
    }

    _previousYPlane = Uint8List.fromList(currentY);
    return samples > 0 ? (totalDiff / samples) : 0.0;
  }

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
  void processCameraImage(
    CameraImage image, 
    int sensorOrientation, 
    bool isFrontCamera, 
    Function(SignGestureResult?) onResult,
  ) async {
    if (_isProcessing || _interpreter == null || _labels == null) return;

    // 1. FILTER GERAKAN DINAMIS:
    // Bahasa isyarat adalah gerakan aktif. Tembok kosong atau orang diam memiliki motion < 4.0.
    // Jika tidak ada gerakan tangan aktif, kunci status ke IDLE!
    final double motion = _calculateMotion(image.planes[0].bytes);
    if (motion >= 5.0) {
      _lastMotionTime = DateTime.now();
    }

    final bool isMotionActive = DateTime.now().difference(_lastMotionTime).inMilliseconds < 1400;

    if (!isMotionActive) {
      _previousLabel = null;
      _consecutiveCount = 0;
      onResult(null);
      return;
    }
    
    // Batasi inferensi: ~5 frame per detik (~200ms) agar responsif menangkap gestur cepat
    if (DateTime.now().difference(_lastDetectionTime).inMilliseconds < 200) {
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
        'isFrontCamera': isFrontCamera,
      };

      // LEMPAR PROSES BERAT KE BACKGROUND THREAD (COMPUTE)
      final inputTensor = await compute(_processImageInIsolate, isolateParams);

      if (inputTensor == null) {
        _isProcessing = false;
        return;
      }

      // Kembali ke Main Thread, siapkan buffer
      var inputBuffer = inputTensor.buffer.asUint8List();
      var outputShape = _interpreter!.getOutputTensor(0).shape; // [1, jumlah_kelas]
      var outputBuffer = List.filled(outputShape[1], 0.0).reshape(outputShape);

      // Jalankan Inferensi TFLite
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

      // Ambang batas deteksi aman: 0.58 (58%)
      // Berada di atas background noise tangan di bawah (~35-45%),
      // namun cukup responsif menangkap isyarat dinamis (Tolong, Terimakasih, dll.)
      const double threshold = 0.58;

      // Filter Margin Kepercayaan terhadap IDLE:
      // Tebakan gestur harus mengungguli probabilitas IDLE minimal 0.18 (18%)
      final double idleProb = probabilities.isNotEmpty ? probabilities[0] : 0.0;
      final bool beatsIdleWithMargin = (maxIndex == 0) || ((maxProb - idleProb) >= 0.18);

      if (maxIndex >= 0 && maxIndex < _labels!.length) {
        final rawLabel = _labels![maxIndex];
        final mappedText = SignVocabulary.lookup(rawLabel);
        final displayName = SignVocabulary.getDisplayName(rawLabel);

        // Cetak log ke konsol agar developer bisa memantau semua gestur secara transparan
        debugPrint('TFLite: $rawLabel (${(maxProb * 100).toStringAsFixed(1)}%) | idle: ${(idleProb * 100).toStringAsFixed(1)}%');

        if (mappedText != null && maxProb >= threshold && beatsIdleWithMargin) {
          // Validasi kestabilan frame (stabil 2 frame berturut-turut atau keyakinan kuat >= 72%)
          if (rawLabel == _previousLabel) {
            _consecutiveCount++;
          } else {
            _previousLabel = rawLabel;
            _consecutiveCount = 1;
          }

          if (_consecutiveCount >= 2 || maxProb >= 0.72) {
            final result = SignGestureResult(
              gestureName: displayName,
              confidence: maxProb,
              timestamp: DateTime.now(),
              mappedText: mappedText,
            );
            onResult(result);
            _lastDetectionTime = DateTime.now();
            _consecutiveCount = 0; // reset counter setelah terkonfirmasi
          }
        } else {
          // Jika kelas terdeteksi adalah 'idle' atau probabilitas di bawah threshold/margin
          _previousLabel = null;
          _consecutiveCount = 0;
          onResult(null);
        }
      } else {
        _previousLabel = null;
        _consecutiveCount = 0;
        onResult(null);
      }
      
    } catch (e, stack) {
      debugPrint('Terjadi kesalahan saat memproses TFLite: $e\n$stack');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
  }
}
