import '../models/chat_message_model.dart';
import '../models/context_preset.dart';

class CommunicationState {
  final List<ChatMessageModel> messages;
  final bool isListening;
  final bool isRecordingPaused;
  final int recordingDurationSeconds;
  final double soundLevel;
  final bool isSendingVoice;
  final bool isSpeaking;
  final String currentRecognizedText;
  final String? errorMessage;
  
  final ContextPreset currentPreset;
  final bool enableContextTranslation;
  final bool isTranslatingContext;
  final String? activeConversationId;

  CommunicationState({
    required this.messages,
    required this.isListening,
    this.isRecordingPaused = false,
    this.recordingDurationSeconds = 0,
    this.soundLevel = 0.0,
    this.isSendingVoice = false,
    required this.isSpeaking,
    required this.currentRecognizedText,
    this.errorMessage,
    required this.currentPreset,
    required this.enableContextTranslation,
    required this.isTranslatingContext,
    this.activeConversationId,
  });

  factory CommunicationState.initial() {
    return CommunicationState(
      messages: [],
      isListening: false,
      isRecordingPaused: false,
      recordingDurationSeconds: 0,
      soundLevel: 0.0,
      isSendingVoice: false,
      isSpeaking: false,
      currentRecognizedText: '',
      errorMessage: null,
      currentPreset: ContextPreset.umum,
      enableContextTranslation: true,
      isTranslatingContext: false,
      activeConversationId: null,
    );
  }

  String get formattedDuration {
    final minutes = (recordingDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (recordingDurationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get isRecordingActive => isListening;

  CommunicationState copyWith({
    List<ChatMessageModel>? messages,
    bool? isListening,
    bool? isRecordingPaused,
    int? recordingDurationSeconds,
    double? soundLevel,
    bool? isSendingVoice,
    bool? isSpeaking,
    String? currentRecognizedText,
    String? errorMessage,
    ContextPreset? currentPreset,
    bool? enableContextTranslation,
    bool? isTranslatingContext,
    String? activeConversationId,
  }) {
    return CommunicationState(
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      isRecordingPaused: isRecordingPaused ?? this.isRecordingPaused,
      recordingDurationSeconds: recordingDurationSeconds ?? this.recordingDurationSeconds,
      soundLevel: soundLevel ?? this.soundLevel,
      isSendingVoice: isSendingVoice ?? this.isSendingVoice,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentRecognizedText: currentRecognizedText ?? this.currentRecognizedText,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPreset: currentPreset ?? this.currentPreset,
      enableContextTranslation: enableContextTranslation ?? this.enableContextTranslation,
      isTranslatingContext: isTranslatingContext ?? this.isTranslatingContext,
      activeConversationId: activeConversationId ?? this.activeConversationId,
    );
  }
}

