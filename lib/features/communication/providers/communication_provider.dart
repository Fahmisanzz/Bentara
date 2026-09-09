import 'dart:async';
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

  Timer? _recordingTimer;
  String _accumulatedText = '';
  String _sessionText = '';

  CommunicationNotifier(this._sttService, this._ttsService, this._translationService, this._conversationRepository, this._ref)
      : super(CommunicationState.initial()) {
    _initServices();
  }

  Future<void> _initServices() async {
    await _sttService.initialize();
    await _ttsService.initialize();
    if (state.activeConversationId == null) {
      state = state.copyWith(activeConversationId: _uuid.v4());
    }
  }

  void reset() {
    _cleanupRecording();
    _startNewConversation();
  }

  void startNewSessionIfSaved() {
    if (_isConversationSavedInDb) {
      _cleanupRecording();
      _startNewConversation();
    }
  }

  Future<void> loadConversation(String conversationId) async {
    _cleanupRecording();
    state = state.copyWith(
      activeConversationId: conversationId,
      messages: [],
      isListening: false,
      isRecordingPaused: false,
      recordingDurationSeconds: 0,
      soundLevel: 0.0,
      currentRecognizedText: '',
    );
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
          isEdited: m.isEdited,
          updatedAt: m.updatedAt,
        );
      }).toList();
      
      state = state.copyWith(messages: chatMessages);
    } catch (e) {
      debugPrint('Failed to load conversation: $e');
    }
  }

  Future<void> _startNewConversation() async {
    final convoId = _uuid.v4();
    state = state.copyWith(
      activeConversationId: convoId,
      messages: [],
      isListening: false,
      isRecordingPaused: false,
      recordingDurationSeconds: 0,
      soundLevel: 0.0,
      currentRecognizedText: '',
    );
    _isConversationSavedInDb = false;
  }

  void setContextPreset(ContextPreset preset) {
    state = state.copyWith(currentPreset: preset);
  }

  void toggleContextTranslation(bool enabled) {
    state = state.copyWith(enableContextTranslation: enabled);
  }

  void _cleanupRecording() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _accumulatedText = '';
    _sessionText = '';
  }

  // ==========================================
  // VOICE RECORDING (TEMAN DENGAR - POV)
  // WhatsApp Flow: Record -> Pause/Resume -> Delete/Send
  // ==========================================

  Future<void> startVoiceRecording() async {
    final hasPerm = await _sttService.initialize();
    if (!hasPerm) {
      state = state.copyWith(errorMessage: 'Izin mikrofon ditolak.');
      return;
    }

    _cleanupRecording();
    state = state.copyWith(
      isListening: true,
      isRecordingPaused: false,
      recordingDurationSeconds: 0,
      soundLevel: 0.0,
      currentRecognizedText: '',
      errorMessage: null,
    );

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && state.isListening && !state.isRecordingPaused) {
        state = state.copyWith(recordingDurationSeconds: state.recordingDurationSeconds + 1);
      }
    });

    await _sttService.startListening(
      onResult: (text) {
        if (!mounted || !state.isListening || state.isRecordingPaused) return;
        _sessionText = text;
        final combined = _accumulatedText.isEmpty
            ? _sessionText
            : (_sessionText.isEmpty ? _accumulatedText : '$_accumulatedText $_sessionText');
        state = state.copyWith(currentRecognizedText: combined);
      },
      onSoundLevelChange: (level) {
        if (mounted && state.isListening && !state.isRecordingPaused) {
          state = state.copyWith(soundLevel: level);
        }
      },
      onStatus: (status) {
        debugPrint('STT Status: $status');
      },
      onError: (err) {
        debugPrint('STT Error: $err');
      },
    );
  }

  Future<void> pauseVoiceRecording() async {
    if (!state.isListening || state.isRecordingPaused) return;

    _recordingTimer?.cancel();
    _recordingTimer = null;
    _accumulatedText = state.currentRecognizedText.trim();
    _sessionText = '';
    await _sttService.stopListening();

    state = state.copyWith(
      isRecordingPaused: true,
      soundLevel: 0.0,
    );
  }

  Future<void> resumeVoiceRecording() async {
    if (!state.isListening || !state.isRecordingPaused) return;

    _sessionText = '';
    state = state.copyWith(isRecordingPaused: false);

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && state.isListening && !state.isRecordingPaused) {
        state = state.copyWith(recordingDurationSeconds: state.recordingDurationSeconds + 1);
      }
    });

    await _sttService.startListening(
      onResult: (text) {
        if (!mounted || !state.isListening || state.isRecordingPaused) return;
        _sessionText = text;
        final combined = _accumulatedText.isEmpty
            ? _sessionText
            : (_sessionText.isEmpty ? _accumulatedText : '$_accumulatedText $_sessionText');
        state = state.copyWith(currentRecognizedText: combined);
      },
      onSoundLevelChange: (level) {
        if (mounted && state.isListening && !state.isRecordingPaused) {
          state = state.copyWith(soundLevel: level);
        }
      },
      onError: (err) {
        debugPrint('STT Error on resume: $err');
      },
    );
  }

  Future<void> cancelVoiceRecording() async {
    _cleanupRecording();
    await _sttService.cancelListening();
    state = state.copyWith(
      isListening: false,
      isRecordingPaused: false,
      recordingDurationSeconds: 0,
      soundLevel: 0.0,
      currentRecognizedText: '',
      errorMessage: null,
    );
  }

  Future<void> sendVoiceRecording() async {
    if (!state.isListening) return;

    _recordingTimer?.cancel();
    _recordingTimer = null;
    state = state.copyWith(isSendingVoice: true);
    String? error;

    try {
      await _sttService.stopListening();
      final rawText = state.currentRecognizedText.trim();

      if (rawText.isNotEmpty) {
        await _processAndAddMessage(rawText, SenderType.userDengar, SourceType.stt);
      } else {
        error = 'Tidak ada suara/kata yang terdeteksi.';
      }
    } catch (e) {
      error = 'Gagal mengirim pesan suara: $e';
    } finally {
      _accumulatedText = '';
      _sessionText = '';
      state = state.copyWith(
        isListening: false,
        isRecordingPaused: false,
        recordingDurationSeconds: 0,
        soundLevel: 0.0,
        currentRecognizedText: '',
        isSendingVoice: false,
        errorMessage: error,
      );
    }
  }

  Future<void> toggleListening() async {
    if (state.isListening) {
      await sendVoiceRecording();
    } else {
      await startVoiceRecording();
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

  /// Mengedit teks pesan yang sudah terkirim (Teman Tuli maupun Teman Dengar).
  /// Memvalidasi batas usia pesan <= 3 jam, dan teks tidak boleh kosong.
  Future<bool> editMessage(String messageId, String newText) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(errorMessage: 'Pesan tidak boleh kosong.');
      return false;
    }

    final index = state.messages.indexWhere((m) => m.id == messageId);
    if (index == -1) {
      state = state.copyWith(errorMessage: 'Pesan tidak ditemukan.');
      return false;
    }

    final originalMessage = state.messages[index];

    // Validasi Batas Waktu 3 Jam (180 menit)
    final elapsed = DateTime.now().difference(originalMessage.timestamp);
    if (elapsed > const Duration(hours: 3)) {
      state = state.copyWith(errorMessage: 'Pesan tidak dapat diedit karena batas waktu 3 jam telah berakhir.');
      return false;
    }

    final now = DateTime.now();
    final updatedMessage = originalMessage.copyWith(
      text: trimmed,
      originalText: originalMessage.originalText ?? originalMessage.text,
      isEdited: true,
      updatedAt: now,
    );

    final updatedList = List<ChatMessageModel>.from(state.messages);
    updatedList[index] = updatedMessage;
    state = state.copyWith(messages: updatedList, errorMessage: null);

    // Sinkronkan perubahan ke cache lokal Hive dan backend Supabase
    final convoId = state.activeConversationId;
    if (convoId != null) {
      try {
        await _conversationRepository.updateMessage(convoId, messageId, trimmed, updatedAt: now);
      } catch (e) {
        debugPrint('Gagal menyinkronkan pembaruan pesan: $e');
      }
    }

    return true;
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
      try {
        _ref.read(historyListProvider.notifier).loadHistory();
      } catch (_) {}
    }
    await _conversationRepository.saveMessage(convoId, newMessage);
  }

  void clearChat() {
    state = state.copyWith(messages: []);
    _startNewConversation(); // Start a fresh session ID in DB
  }

  @override
  void dispose() {
    _cleanupRecording();
    _sttService.cancelListening();
    _ttsService.stop();
    super.dispose();
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

