package com.example.bentara

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.bisindo/hand_landmarker"
    private var handLandmarkerHelper: HandLandmarkerHelper? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val modelPath = call.argument<String>("modelPath")
                    if (modelPath != null) {
                        handLandmarkerHelper = HandLandmarkerHelper(context)
                        try {
                            handLandmarkerHelper?.initialize(modelPath)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INIT_FAILED", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "modelPath is required", null)
                    }
                }
                "detect" -> {
                    val imageBytes = call.argument<ByteArray>("imageBytes")
                    val width = call.argument<Int>("width")
                    val height = call.argument<Int>("height")
                    val rotation = call.argument<Int>("rotation")
                    val isFrontCamera = call.argument<Boolean>("isFrontCamera") ?: true

                    if (imageBytes != null && width != null && height != null && rotation != null) {
                        if (handLandmarkerHelper == null) {
                            result.error("NOT_INITIALIZED", "HandLandmarkerHelper is not initialized", null)
                            return@setMethodCallHandler
                        }

                        val landmarks = handLandmarkerHelper?.detectFromBytes(imageBytes, width, height, rotation, isFrontCamera)
                        if (landmarks != null) {
                            result.success(landmarks)
                        } else {
                            result.success(null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing arguments for detect", null)
                    }
                }
                "dispose" -> {
                    handLandmarkerHelper?.close()
                    handLandmarkerHelper = null
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
