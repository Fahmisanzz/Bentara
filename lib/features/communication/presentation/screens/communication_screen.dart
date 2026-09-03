import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.conversationId != null) {
        ref.read(communicationNotifierProvider.notifier).loadConversation(widget.conversationId!);
      } else {
        ref.read(communicationNotifierProvider.notifier).startNewSessionIfSaved();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
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

  Future<void> _showClearChatDialog(BuildContext context, CommunicationNotifier notifier) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Percakapan?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Semua percakapan ini akan dihapus.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tidak', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      notifier.clearChat();
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
      backgroundColor: AppColors.primaryLight, // LAYER 1
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Komunikasi Live',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          // AI Toggle Button
          IconButton(
            icon: Icon(
              commState.enableContextTranslation ? Icons.auto_awesome : Icons.auto_awesome_outlined,
              color: commState.enableContextTranslation ? Colors.white : Colors.white70,
              size: 22,
            ),
            tooltip: 'Toggle AI Context',
            onPressed: () => notifier.toggleContextTranslation(!commState.enableContextTranslation),
          ),
          // Delete Chat Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
            tooltip: 'Hapus Percakapan',
            onPressed: () => _showClearChatDialog(context, notifier),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        // LAYER 2
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
            // ==========================================
            // 1. CONTEXT SELECTOR (CATEGORY TAB)
            // ==========================================
            if (commState.enableContextTranslation) ...[
              const ContextSelectorBar(),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            ],

            if (commState.isTranslatingContext)
              const LinearProgressIndicator(color: AppColors.primary, minHeight: 2),

            // ==========================================
            // 2. CONVERSATION AREA
            // ==========================================
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
                child: commState.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        itemCount: commState.messages.length,
                        itemBuilder: (context, index) {
                          return ContextMessageBubble(message: commState.messages[index]);
                        },
                      ),
              ),
            ),

            // ==========================================
            // 3. LIVE STT PREVIEW AREA
            // ==========================================
            if (commState.isListening || commState.currentRecognizedText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mic, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Mendengarkan...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      commState.currentRecognizedText.isEmpty ? 'Silakan bicara...' : commState.currentRecognizedText,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // ==========================================
            // 4. BOTTOM COMPOSER
            // ==========================================
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                12.0,
                10.0,
                12.0,
                10.0 + (MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : MediaQuery.paddingOf(context).bottom),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // --- Text Input ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: _focusNode.hasFocus ? AppColors.primary : Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        decoration: const InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            notifier.sendTextAndSpeak(val.trim());
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // --- Camera Button ---
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.pushNamed('sign_recognition'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: const Icon(Icons.videocam_rounded, color: Colors.black54, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // --- Send Button ---
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (_textController.text.trim().isNotEmpty) {
                          notifier.sendTextAndSpeak(_textController.text.trim());
                          _textController.clear();
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // --- Microphone Button ---
                  GestureDetector(
                    onTap: () => notifier.toggleListening(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: commState.isListening ? AppColors.error : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: commState.isListening
                            ? [BoxShadow(color: AppColors.error.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)]
                            : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 4, spreadRadius: 1)],
                      ),
                      child: Icon(
                        commState.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  // --- RESPONSIVE NON-OVERFLOWING EMPTY STATE WIDGET ---
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mulai Percakapan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ketik pesan atau gunakan fitur\nkomunikasi yang tersedia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
