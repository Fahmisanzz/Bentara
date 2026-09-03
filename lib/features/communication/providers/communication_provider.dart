import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/chat_message_model.dart';
import '../models/context_preset.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import '../services/context_translation_service.dart';
import '../data/conversation_repository.dart';
import '../../../core/services/local_storage_service.dart';
import '../../history/providers/history_provider.dart';
import 'communication_state.dart';

final sttServiceProvider = Provider<ISTTService>((ref) => SpeechToTextService());
final ttsServiceProvider = Provider<ITTSService>((ref) => FlutterTtsService());
final contextTranslationServiceProvider = Provider<IContextTranslationService>((ref) => SupabaseContextTranslationService());
final conversationRepositoryProvider = Provider<IConversationRepository>((ref) {
  return SupabaseConversationRepository(
    SupabaseService.client,
    ref.read(localStorageProvider),
  );
});

class CommunicationNotifier extends StateNotifier<CommunicationState> {
  final ISTTService _sttService;
  final ITTSService _ttsService;
  final IContextTranslationService _translationService;
  final IConversationRepository _conversationRepository;
  final Ref _ref;
  final _uuid = const Uuid();
  bool _isConversationSavedInDb = false;

  CommunicationNotifier(this._sttService, this._ttsService, this._translationService, this._conversationRepository, this._ref)
      : super(CommunicationState.initial()) {
    _initServices();
  }

  Future<void> _initServices() async {
    await _sttService.initialize();
    await _ttsService.initialize();
    _startNewConversation();
  }

  void reset() {
    _startNewConversation();
  }

  void startNewSessionIfSaved() {
    if (_isConversationSavedInDb) {
      _startNewConversation();
    }
  }

  Future<void> loadConversation(String conversationId) async {
    state = state.copyWith(activeConversationId: conversationId, messages: [], isListening: false);
    _isConversationSavedInDb = true;
    try {
      final historyRepo = _ref.read(historyRepoProvider);
      final historyMessages = await historyRepo.fetchMessagesForConversation(conversationId);
      
      final chatMessages = historyMessages.map((m) {
        return ChatMessageModel(
          id: m.id,
          text: m.outputText ?? '',
          sender: m.senderType == 'tuli' ? SenderType.userTuli : SenderType.userDengar,
          timestamp: m.createdAt,
          sourceType: m.inputType == 'voice' ? SourceType.stt : (m.inputType == 'sign' ? SourceType.sign : SourceType.textInput),
          contextualText: m.processedText,
          originalText: m.originalText,
        );
      }).toList();
      
      state = state.copyWith(messages: chatMessages);
    } catch (e) {
      debugPrint('Failed to load conversation: $e');
    }
  }

  Future<void> _startNewConversation() async {
    final convoId = _uuid.v4();
    state = state.copyWith(activeConversationId: convoId, messages: []);
    _isConversationSavedInDb = false;
  }

  void setContextPreset(ContextPreset preset) {
    state = state.copyWith(currentPreset: preset);
  }

  void toggleContextTranslation(bool enabled) {
    state = state.copyWith(enableContextTranslation: enabled);
  }

  Future<void> toggleListening() async {
    if (state.isListening) {
      await _sttService.stopListening();
      final rawText = state.currentRecognizedText.trim();
      state = state.copyWith(isListening: false, currentRecognizedText: '');

      if (rawText.isNotEmpty) {
        await _processAndAddMessage(rawText, SenderType.userDengar, SourceType.stt);
      }
    } else {
      final hasPerm = await _sttService.initialize();
      if (!hasPerm) {
        state = state.copyWith(errorMessage: 'Izin mikrofon ditolak.');
        return;
      }
      
      state = state.copyWith(isListening: true, currentRecognizedText: '', errorMessage: null);
      
      await _sttService.startListening(
        onResult: (text) {
          state = state.copyWith(currentRecognizedText: text);
        },
      );
    }
  }

  Future<void> sendTextAndSpeak(String text) async {
    if (text.trim().isEmpty) return;
    
    await _processAndAddMessage(text, SenderType.userTuli, SourceType.tts);

    // Get the final text (it might have been contextually translated)
    final msg = state.messages.last;
    
    state = state.copyWith(isSpeaking: true);
    await _ttsService.speak(msg.text);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) state = state.copyWith(isSpeaking: false);
    });
  }

  Future<void> _processAndAddMessage(String rawText, SenderType sender, SourceType source) async {
    String finalText = rawText;
    String? contextualText;
    bool contextApplied = false;

    if (state.enableContextTranslation) {
      state = state.copyWith(isTranslatingContext: true);
      try {
        finalText = await _translationService.translateContext(rawText: rawText, preset: state.currentPreset);
        if (finalText != rawText) {
          contextualText = finalText;
          contextApplied = true;
        }
      } finally {
        state = state.copyWith(isTranslatingContext: false);
      }
    }

    final newMessage = ChatMessageModel(
      id: _uuid.v4(),
      text: finalText,
      originalText: contextApplied ? rawText : null,
      contextualText: contextualText,
      appliedContext: contextApplied ? state.currentPreset : null,
      isContextApplied: contextApplied,
      sender: sender,
      timestamp: DateTime.now(),
      sourceType: source,
    );

    final convoId = state.activeConversationId ?? _uuid.v4();
    if (state.activeConversationId == null) {
      state = state.copyWith(activeConversationId: convoId);
    }

    state = state.copyWith(messages: [...state.messages, newMessage]);

    // Simpan ke Cache Lokal Hive & Sinkronkan ke Supabase
    final user = _ref.read(currentUserProvider);
    final userId = user?.id ?? 'local_user';

    if (!_isConversationSavedInDb) {
      String title = rawText.trim();
      if (title.length > 28) {
        title = '${title.substring(0, 28)}...';
      }
      if (title.isEmpty) title = 'Percakapan ${state.currentPreset.label}';

      await _conversationRepository.saveConversation(
        title,
        userId,
        contextStr: state.currentPreset.name,
        id: convoId,
      );
      _isConversationSavedInDb = true;
      _ref.read(historyListProvider.notifier).loadHistory();
    }
    await _conversationRepository.saveMessage(convoId, newMessage);
  }

  void clearChat() {
    state = state.copyWith(messages: []);
    _startNewConversation(); // Start a fresh session ID in DB
  }
}

final communicationNotifierProvider = StateNotifierProvider<CommunicationNotifier, CommunicationState>((ref) {
  return CommunicationNotifier(
    ref.read(sttServiceProvider),
    ref.read(ttsServiceProvider),
    ref.read(contextTranslationServiceProvider),
    ref.read(conversationRepositoryProvider),
    ref,
  );
});
