import 'context_preset.dart';

enum SenderType { userTuli, userDengar }
enum SourceType { stt, tts, textInput, sign }

class ChatMessageModel {
  final String id;
  final String text; // Will hold the contextual text if applied, otherwise original text
  final String? originalText; 
  final String? contextualText;
  final ContextPreset? appliedContext;
  final bool isContextApplied;
  
  final SenderType sender;
  final DateTime timestamp;
  final SourceType sourceType;

  ChatMessageModel({
    required this.id,
    required this.text,
    this.originalText,
    this.contextualText,
    this.appliedContext,
    this.isContextApplied = false,
    required this.sender,
    required this.timestamp,
    required this.sourceType,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      text: json['text'],
      originalText: json['original_text'],
      contextualText: json['contextual_text'],
      appliedContext: json['applied_context'] != null 
          ? ContextPreset.values.firstWhere((e) => e.name == json['applied_context'], orElse: () => ContextPreset.umum)
          : null,
      isContextApplied: json['is_context_applied'] ?? false,
      sender: SenderType.values.firstWhere((e) => e.name == json['sender']),
      timestamp: DateTime.parse(json['timestamp']),
      sourceType: SourceType.values.firstWhere((e) => e.name == json['sourceType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'original_text': originalText,
      'contextual_text': contextualText,
      'applied_context': appliedContext?.name,
      'is_context_applied': isContextApplied,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'sourceType': sourceType.name,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? text,
    String? originalText,
    String? contextualText,
    ContextPreset? appliedContext,
    bool? isContextApplied,
    SenderType? sender,
    DateTime? timestamp,
    SourceType? sourceType,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      originalText: originalText ?? this.originalText,
      contextualText: contextualText ?? this.contextualText,
      appliedContext: appliedContext ?? this.appliedContext,
      isContextApplied: isContextApplied ?? this.isContextApplied,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      sourceType: sourceType ?? this.sourceType,
    );
  }
}
