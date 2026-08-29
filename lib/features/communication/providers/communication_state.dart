import '../models/chat_message_model.dart';
import '../models/context_preset.dart';

class CommunicationState {
  final List<ChatMessageModel> messages;
  final bool isListening;
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
      isSpeaking: false,
      currentRecognizedText: '',
      errorMessage: null,
      currentPreset: ContextPreset.umum,
      enableContextTranslation: true,
      isTranslatingContext: false,
      activeConversationId: null,
    );
  }

  CommunicationState copyWith({
    List<ChatMessageModel>? messages,
    bool? isListening,
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
