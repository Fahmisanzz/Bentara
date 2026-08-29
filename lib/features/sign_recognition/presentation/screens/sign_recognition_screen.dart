import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/sign_recognition_provider.dart';
import '../../../../features/communication/providers/communication_provider.dart';
import '../widgets/camera_overlay_painter.dart';
import '../widgets/recognized_text_banner.dart';

class SignRecognitionScreen extends ConsumerStatefulWidget {
  const SignRecognitionScreen({super.key});

  @override
  ConsumerState<SignRecognitionScreen> createState() => _SignRecognitionScreenState();
}

class _SignRecognitionScreenState extends ConsumerState<SignRecognitionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signRecognitionNotifierProvider.notifier).initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signRecognitionNotifierProvider);
    final notifier = ref.read(signRecognitionNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Camera Preview
            if (state.isCameraInitialized && notifier.cameraController != null)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: notifier.cameraController!.value.previewSize?.height ?? 1,
                    height: notifier.cameraController!.value.previewSize?.width ?? 1,
                    child: CameraPreview(notifier.cameraController!),
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              ),

            // 2. Camera Overlay (Guides user where to place hands)
            if (state.isCameraInitialized)
              CustomPaint(
                size: Size.infinite,
                painter: CameraOverlayPainter(),
              ),

            // 3. Top Action Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.isDetecting ? Colors.red : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.isDetecting ? 'AI Aktif' : 'Memproses...',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                      onPressed: state.isCameraInitialized ? notifier.flipCamera : null,
                    ),
                  ),
                ],
              ),
            ),

            // 4. Live Banner for newest gesture
            if (state.currentGesture != null)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: RecognizedTextBanner(gesture: state.currentGesture!),
                ),
              ),

            // 5. Bottom Panel (Composed Sentence & TTS)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Kalimat Dikenali:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(minHeight: 60),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        state.composedSentence.isEmpty ? 'Mulai lakukan gerakan...' : state.composedSentence,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: state.composedSentence.isEmpty ? Colors.grey : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: state.composedSentence.isEmpty || !state.isDetecting ? null : notifier.speakSentence,
                            icon: const Icon(Icons.volume_up, size: 18),
                            label: const Text('Suara'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(color: AppColors.secondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: state.composedSentence.isEmpty || !state.isDetecting ? null : () {
                              // Integrasi End-to-End: Kirim ke riwayat chat
                              ref.read(communicationNotifierProvider.notifier).sendTextAndSpeak(state.composedSentence);
                              Navigator.of(context).pop(); // Tutup layar kamera
                            },
                            icon: const Icon(Icons.send),
                            label: const Text('Kirim ke Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
