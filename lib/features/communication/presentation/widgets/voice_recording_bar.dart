import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/communication_provider.dart';

class VoiceRecordingBar extends ConsumerStatefulWidget {
  const VoiceRecordingBar({super.key});

  @override
  ConsumerState<VoiceRecordingBar> createState() => _VoiceRecordingBarState();
}

class _VoiceRecordingBarState extends ConsumerState<VoiceRecordingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commState = ref.watch(communicationNotifierProvider);
    final notifier = ref.read(communicationNotifierProvider.notifier);
    final isPaused = commState.isRecordingPaused;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==========================================
        // 1. LIVE TRANSCRIPTION BUBBLE (IF AVAILABLE)
        // ==========================================
        if (commState.currentRecognizedText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mic, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      commState.currentRecognizedText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ==========================================
        // 2. PERFECTLY BALANCED SYMMETRICAL BAR
        // ==========================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 1. DELETE / CANCEL BUTTON (LEFT - 44x44) ---
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => notifier.cancelVoiceRecording(),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // --- 2. RECORDING CAPSULE (EXPANDED - 48DP HEIGHT) ---
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Timer & Pulsing Dot
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPaused
                                    ? Colors.orange
                                    : AppColors.error.withValues(
                                        alpha: 0.4 + (_animController.value * 0.6),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 5),
                        MediaQuery.withNoTextScaling(
                          child: Text(
                            commState.formattedDuration,
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                              color: isPaused ? Colors.orange.shade800 : Colors.black87,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),

                    // Dynamic Waveform spanning 100% of available middle width
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return _WaveformVisualizer(
                            progress: _animController.value,
                            isPaused: isPaused,
                            soundLevel: commState.soundLevel,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Pause / Resume Pill Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (isPaused) {
                            notifier.resumeVoiceRecording();
                          } else {
                            notifier.pauseVoiceRecording();
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: isPaused
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isPaused ? AppColors.primary : const Color(0xFFCBD5E1),
                              width: 0.8,
                            ),
                            boxShadow: isPaused
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                size: 14,
                                color: isPaused ? AppColors.primary : Colors.black87,
                              ),
                              const SizedBox(width: 3),
                              MediaQuery.withNoTextScaling(
                                child: Text(
                                  isPaused ? 'Lanjut' : 'Jeda',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isPaused ? AppColors.primary : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // --- 3. SEND BUTTON (RIGHT - 44x44) ---
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: commState.isSendingVoice
                    ? null
                    : () => notifier.sendVoiceRecording(),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: commState.isSendingVoice
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WaveformVisualizer extends StatelessWidget {
  final double progress;
  final bool isPaused;
  final double soundLevel;

  const _WaveformVisualizer({
    required this.progress,
    required this.isPaused,
    required this.soundLevel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        if (availableWidth <= 10) return const SizedBox.shrink();

        // Dynamically compute bar count to fill exactly 100% of the space
        const double barWidth = 2.5;
        const double barGap = 2.8;
        final int barCount = (availableWidth / (barWidth + barGap)).floor().clamp(6, 60);

        return SizedBox(
          width: availableWidth,
          height: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(barCount, (index) {
              double height;
              if (isPaused) {
                height = 4.0 + 8.0 * math.sin((index / (barCount - 1)) * math.pi);
              } else {
                final wave = math.sin((progress * 2 * math.pi) + (index * 0.35));
                final base = (wave + 1.0) / 2.0; // 0.0 to 1.0
                final levelBonus = soundLevel > 0 ? (soundLevel / 10.0).clamp(0.0, 1.0) * 8.0 : 0.0;
                height = 4.0 + (base * 14.0) + levelBonus;
              }

              return Container(
                width: barWidth,
                height: height.clamp(3.5, 24.0),
                decoration: BoxDecoration(
                  color: isPaused
                      ? const Color(0xFF94A3B8)
                      : AppColors.primary.withValues(
                          alpha: 0.5 + (0.5 * ((index % 4) / 3.0)),
                        ),
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
