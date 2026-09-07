import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class HandLandmarkService {
  static const MethodChannel _channel = MethodChannel('com.bisindo/hand_landmarker');
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Extract model from assets to local file for Native MediaPipe
      final bytes = await rootBundle.load('assets/models/hand_landmarker.task');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/hand_landmarker.task');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      // Initialize native MediaPipe
      final result = await _channel.invokeMethod('initialize', {
        'modelPath': file.path,
      });

      _isInitialized = result == true;
    } catch (e) {
      debugPrint('Error initializing HandLandmarkService: $e');
    }
  }

  Future<List<double>?> processCameraImage(
    CameraImage image, 
    int sensorOrientation, {
    bool isFrontCamera = true,
  }) async {
    if (!_isInitialized) return null;

    try {
      // CameraImage format is typically NV21 on Android (or YUV_420_888 which camera plugin converts to NV21 bytes conceptually if mapped correctly).
      // camera plugin usually gives a single planes[0].bytes if NV21 format, or 3 planes for YUV420.
      // We will concatenate the bytes if needed, but for ImageFormatGroup.nv21, planes[0] contains the full NV21 byte array.

      Uint8List imageBytes;
      if (image.format.group == ImageFormatGroup.nv21) {
        if (image.planes.length == 1) {
          imageBytes = image.planes[0].bytes;
        } else {
          final int ySize = image.width * image.height;
          final int uvSize = ySize ~/ 2;
          imageBytes = Uint8List(ySize + uvSize);
          imageBytes.setRange(0, ySize, image.planes[0].bytes);
        }
      } else if (image.format.group == ImageFormatGroup.yuv420) {
        // Build an NV21 sized buffer (Y + V + U) to prevent YuvImage crash
        final int ySize = image.width * image.height;
        final int uvSize = ySize ~/ 2;
        imageBytes = Uint8List(ySize + uvSize);
        
        final yPlane = image.planes[0].bytes;
        final uPlane = image.planes[1].bytes;
        final vPlane = image.planes[2].bytes;
        
        // Copy Y channel
        imageBytes.setRange(0, ySize, yPlane);
        
        // Dump V and U just to satisfy YuvImage format size requirement.
        // MediaPipe Hand Landmarker relies heavily on Luma (Y) anyway.
        int offset = ySize;
        if (offset + vPlane.length <= imageBytes.length) {
            imageBytes.setRange(offset, offset + vPlane.length, vPlane);
            offset += vPlane.length;
        }
        if (offset + uPlane.length <= imageBytes.length) {
            imageBytes.setRange(offset, offset + uPlane.length, uPlane);
        }
      } else {
        debugPrint('Unsupported image format: ${image.format.group}');
        return null;
      }

      final result = await _channel.invokeMethod<List<dynamic>>('detect', {
        'imageBytes': imageBytes,
        'width': image.width,
        'height': image.height,
        'rotation': sensorOrientation,
        'isFrontCamera': isFrontCamera,
      });

      if (result != null) {
        return result.cast<double>();
      }
    } catch (e) {
      debugPrint('Error processing frame in Native: $e');
    }
    return null;
  }

  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error disposing HandLandmarkService: $e');
    }
  }
}
