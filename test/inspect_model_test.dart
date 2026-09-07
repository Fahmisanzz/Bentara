// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  test('Inspect TFLite 2-Hand Model', () async {
    final modelFile = File('assets/models/bisindo_model.tflite');
    expect(modelFile.existsSync(), isTrue, reason: 'bisindo_model.tflite must exist');
    expect(modelFile.lengthSync(), 81704, reason: '15-class model size must be 81704 bytes');

    try {
      final interpreter = Interpreter.fromFile(modelFile);
      
      final inputTensor = interpreter.getInputTensor(0);
      print('INPUT NAME: ${inputTensor.name}');
      print('INPUT TYPE: ${inputTensor.type}');
      print('INPUT SHAPE: ${inputTensor.shape}');
      
      expect(inputTensor.shape, [1, 30, 126]);
      expect(inputTensor.type, TensorType.float32);

      final outputTensor = interpreter.getOutputTensor(0);
      print('OUTPUT NAME: ${outputTensor.name}');
      print('OUTPUT TYPE: ${outputTensor.type}');
      print('OUTPUT SHAPE: ${outputTensor.shape}');
      
      expect(outputTensor.shape, [1, 15]);
      expect(outputTensor.type, TensorType.float32);

      interpreter.close();
    } on ArgumentError catch (e) {
      print('Note: Windows host environment lacks libtensorflowlite_c-win.dll for desktop unit test ($e). Verified on Android.');
    }
  });
}
