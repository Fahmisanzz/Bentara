import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/communication_provider.dart';
import '../widgets/context_selector_bar.dart';
import '../widgets/context_message_bubble.dart';

class CommunicationScreen extends ConsumerStatefulWidget {
  final String? conversationId;
  const CommunicationScreen({super.key, this.conversationId});

  @override
  ConsumerState<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends ConsumerState<CommunicationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(communicationNotifierProvider.notifier).loadConversation(widget.conversationId!);
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final commState = ref.watch(communicationNotifierProvider);
    final notifier = ref.read(communicationNotifierProvider.notifier);

    ref.listen(communicationNotifierProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: AppColors.error),
        );
      }
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Komunikasi Live'),
        actions: [
          IconButton(
            icon: Icon(
              commState.enableContextTranslation ? Icons.auto_awesome : Icons.auto_awesome_outlined,
              color: commState.enableContextTranslation ? AppColors.secondary : Colors.grey,
            ),
            tooltip: 'Toggle AI Context',
            onPressed: () => notifier.toggleContextTranslation(!commState.enableContextTranslation),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Percakapan',
            onPressed: () => notifier.clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Context Selection Bar
          if (commState.enableContextTranslation)
            const ContextSelectorBar(),
            
          if (commState.isTranslatingContext)
            const LinearProgressIndicator(color: AppColors.secondary),

          // 1. Chat Messages Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: commState.messages.length,
              itemBuilder: (context, index) {
                return ContextMessageBubble(message: commState.messages[index]);
              },
            ),
          ),
          
          // 2. Live STT Preview Area
          if (commState.isListening || commState.currentRecognizedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mic, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      const Text('Mendengarkan...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    commState.currentRecognizedText.isEmpty ? 'Silakan bicara...' : commState.currentRecognizedText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
          const Divider(height: 1),
          
          // 3. Input Controls (Mic for Dengar, Text for Tuli)
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SafeArea(
              child: Row(
                children: [
                  // Text Input for Teman Tuli
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (val) {
                        notifier.sendTextAndSpeak(val);
                        _textController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Camera / Sign Recognition Button
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueGrey,
                    child: IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.white),
                      tooltip: 'Kamera Isyarat',
                      onPressed: () => context.pushNamed('sign_recognition'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send Text & Speak (TTS)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.secondary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      tooltip: 'Kirim Teks',
                      onPressed: () {
                        if (_textController.text.trim().isNotEmpty) {
                          notifier.sendTextAndSpeak(_textController.text);
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Big Mic Button for Teman Dengar
                  GestureDetector(
                    onTap: () => notifier.toggleListening(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: commState.isListening ? AppColors.error : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: commState.isListening
                            ? [BoxShadow(color: AppColors.error.withOpacity(0.5), blurRadius: 12, spreadRadius: 4)]
                            : [],
                      ),
                      child: Icon(
                        commState.isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
