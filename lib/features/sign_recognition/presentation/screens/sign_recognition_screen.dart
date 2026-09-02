import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/sign_recognition_provider.dart';
import '../../../../features/communication/providers/communication_provider.dart';
import '../widgets/camera_overlay_painter.dart';

class SignRecognitionScreen extends ConsumerStatefulWidget {
  const SignRecognitionScreen({super.key});

  @override
  ConsumerState<SignRecognitionScreen> createState() => _SignRecognitionScreenState();
}

class _SignRecognitionScreenState extends ConsumerState<SignRecognitionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signRecognitionNotifierProvider.notifier).initializeCamera();
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signRecognitionNotifierProvider);
    final notifier = ref.read(signRecognitionNotifierProvider.notifier);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.white,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
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
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.lightBlue),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Membuka Kamera Bentara...',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

            // 2. Camera Overlay with Laser Animation
            if (state.isCameraInitialized)
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: CameraOverlayPainter(
                      scanAnimationValue: state.isDetecting ? _scanAnimation.value : 0.5,
                    ),
                  );
                },
              ),

            // 3. Top Action Bar (Solid Opaque Buttons)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C0C0C).withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),

                  // AI Status Badge (Indonesian)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0C0C).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.isCameraInitialized
                                ? (state.isDetecting ? const Color(0xFF4BA95F) : Colors.amber)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          !state.isCameraInitialized
                              ? 'Memuat Kamera...'
                              : (state.isDetecting ? 'AI AKTIF — Memindai' : 'AI Pause'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flip Camera Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: state.isCameraInitialized ? notifier.flipCamera : null,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Solid White Bottom Result Panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'KALIMAT TERDETEKSI',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (state.composedSentence.isNotEmpty)
                          GestureDetector(
                            onTap: notifier.clearSentence,
                            child: const Text(
                              'Hapus',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Recognized Sentence Container
                    Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8FC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: state.composedSentence.isNotEmpty
                              ? AppColors.primary.withValues(alpha: 0.4)
                              : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        state.composedSentence.isEmpty
                            ? 'Posisikan tangan di dalam area pemindaian...'
                            : state.composedSentence,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: state.composedSentence.isEmpty
                              ? AppColors.textSecondary.withValues(alpha: 0.6)
                              : AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons Row (Solid Opaque Buttons)
                    Row(
                      children: [
                        // Tombol Suara (TTS)
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: state.composedSentence.isEmpty ? null : notifier.speakSentence,
                              icon: const Icon(Icons.volume_up_rounded, size: 20),
                              label: const Text('Suara'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                disabledForegroundColor: Colors.grey.shade400,
                                side: BorderSide(
                                  color: state.composedSentence.isEmpty
                                      ? Colors.grey.shade300
                                      : AppColors.primary,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Tombol Kirim ke Chat
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: state.composedSentence.isEmpty
                                  ? null
                                  : () {
                                      ref.read(communicationNotifierProvider.notifier).sendTextAndSpeak(state.composedSentence);
                                      Navigator.of(context).pop();
                                    },
                              icon: const Icon(Icons.send_rounded, size: 20),
                              label: const Text('Kirim ke Chat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade200,
                                disabledForegroundColor: Colors.grey.shade400,
                                elevation: state.composedSentence.isEmpty ? 0 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
