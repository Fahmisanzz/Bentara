package com.example.bentara

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import android.util.Log
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import com.google.mediapipe.tasks.core.Delegate
import java.io.ByteArrayOutputStream

class HandLandmarkerHelper(private val context: Context) {
    private var handLandmarker: HandLandmarker? = null
    private val TAG = "BISINDO"

    fun initialize(modelPath: String) {
        val baseOptions = BaseOptions.builder()
            .setModelAssetPath(modelPath)
            .setDelegate(Delegate.CPU)
            .build()

        val options = HandLandmarker.HandLandmarkerOptions.builder()
            .setBaseOptions(baseOptions)
            .setNumHands(2)
            .setMinHandDetectionConfidence(0.5f)
            .setMinTrackingConfidence(0.5f)
            .setMinHandPresenceConfidence(0.5f)
            .build()

        handLandmarker = HandLandmarker.createFromOptions(context, options)
        Log.d(TAG, "HandLandmarker initialized: numHands=2, modelPath=$modelPath")
    }

    fun detectFromBytes(
        imageBytes: ByteArray,
        width: Int,
        height: Int,
        rotation: Int,
        isFrontCamera: Boolean = true
    ): FloatArray? {
        try {
            // Convert YUV (NV21) bytes to Bitmap
            val yuvImage = YuvImage(imageBytes, ImageFormat.NV21, width, height, null)
            val out = ByteArrayOutputStream()
            yuvImage.compressToJpeg(Rect(0, 0, width, height), 90, out)
            val jpegBytes = out.toByteArray()
            var bitmap = BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.size)

            val matrix = Matrix()
            if (rotation != 0) {
                matrix.postRotate(rotation.toFloat())
            }
            if (isFrontCamera) {
                // Front camera sensor on Android produces a horizontally mirrored stream.
                // Flip along X-axis so hand geometry and handedness match natural observer/training perspective.
                matrix.postScale(-1f, 1f, bitmap.width / 2f, bitmap.height / 2f)
            }
            bitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)

            val mpImage = BitmapImageBuilder(bitmap).build()
            val result: HandLandmarkerResult = handLandmarker?.detect(mpImage) ?: return null

            val leftHand = FloatArray(63)
            val rightHand = FloatArray(63)
            var leftFilled = false
            var rightFilled = false

            val detectedLandmarks = result.landmarks()
            val detectedHandednesses = result.handednesses()

            for (idx in detectedLandmarks.indices) {
                val landmarks = detectedLandmarks[idx]
                val coords = FloatArray(63)
                val count = Math.min(landmarks.size, 21)
                for (i in 0 until count) {
                    coords[i * 3] = landmarks[i].x()
                    coords[i * 3 + 1] = landmarks[i].y()
                    coords[i * 3 + 2] = landmarks[i].z()
                }

                // Check handedness to assign to Left (0..62) or Right (63..125) slot
                var handType: String? = null
                if (idx < detectedHandednesses.size && detectedHandednesses[idx].isNotEmpty()) {
                    handType = detectedHandednesses[idx][0].categoryName()
                }

                if (handType == "Left" && !leftFilled) {
                    System.arraycopy(coords, 0, leftHand, 0, 63)
                    leftFilled = true
                } else if (handType == "Right" && !rightFilled) {
                    System.arraycopy(coords, 0, rightHand, 0, 63)
                    rightFilled = true
                } else {
                    // Fallback matching 01_collect_data.py
                    if (!leftFilled) {
                        System.arraycopy(coords, 0, leftHand, 0, 63)
                        leftFilled = true
                    } else if (!rightFilled) {
                        System.arraycopy(coords, 0, rightHand, 0, 63)
                        rightFilled = true
                    }
                }
            }

            // Concatenate both hands: Left Hand (0..62) + Right Hand (63..125) = 126 features
            val totalFeatures = FloatArray(126)
            System.arraycopy(leftHand, 0, totalFeatures, 0, 63)
            System.arraycopy(rightHand, 0, totalFeatures, 63, 63)

            Log.d(TAG, "Detect: hands=${detectedLandmarks.size} left=$leftFilled right=$rightFilled features=126")

            return totalFeatures
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    fun close() {
        handLandmarker?.close()
    }
}
