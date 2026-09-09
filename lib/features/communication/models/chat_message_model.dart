import 'context_preset.dart';

enum SenderType { userTuli, userDengar }
enum SourceType { stt, tts, textInput, sign }

class ChatMessageModel {
  final String id;
  final String text; // Will hold the contextual text if applied, otherwise original text or edited text
  final String? originalText; 
  final String? contextualText;
  final ContextPreset? appliedContext;
  final bool isContextApplied;
  
  final SenderType sender;
  final DateTime timestamp;
  final SourceType sourceType;
  final bool isEdited;
  final DateTime? updatedAt;

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
    this.isEdited = false,
    this.updatedAt,
  });

  /// Pengecekan aturan batas waktu edit:
  /// Pesan dapat diedit selama usia pesan tidak lebih dari 3 jam (180 menit).
  bool get canBeEdited {
    final elapsed = DateTime.now().difference(timestamp);
    return elapsed >= Duration.zero && elapsed <= const Duration(hours: 3);
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      text: json['text'] ?? json['output_text'] ?? '',
      originalText: json['original_text'],
      contextualText: json['contextual_text'] ?? json['processed_text'],
      appliedContext: json['applied_context'] != null 
          ? ContextPreset.values.firstWhere((e) => e.name == json['applied_context'], orElse: () => ContextPreset.umum)
          : null,
      isContextApplied: json['is_context_applied'] ?? false,
      sender: SenderType.values.firstWhere(
        (e) => e.name == json['sender'] || (json['sender_type'] == 'tuli' ? e == SenderType.userTuli : e == SenderType.userDengar),
        orElse: () => SenderType.userTuli,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? json['created_at']),
      sourceType: SourceType.values.firstWhere(
        (e) => e.name == json['sourceType'] || (json['input_type'] == 'voice' ? e == SourceType.stt : (json['input_type'] == 'sign' ? e == SourceType.sign : e == SourceType.textInput)),
        orElse: () => SourceType.textInput,
      ),
      isEdited: json['is_edited'] ?? false,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
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
      'is_edited': isEdited,
      'updated_at': updatedAt?.toIso8601String(),
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
    bool? isEdited,
    DateTime? updatedAt,
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
      isEdited: isEdited ?? this.isEdited,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
