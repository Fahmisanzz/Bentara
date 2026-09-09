class MessageModel {
  final String id;
  final String conversationId;
  final String senderType; // 'tuli', 'dengar', 'system'
  final String inputType; // 'text', 'voice', 'sign'
  final String? originalText;
  final String? processedText;
  final String? outputText;
  final DateTime createdAt;
  final bool isEdited;
  final DateTime? updatedAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.inputType,
    this.originalText,
    this.processedText,
    this.outputText,
    required this.createdAt,
    this.isEdited = false,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderType: json['sender_type'],
      inputType: json['input_type'],
      originalText: json['original_text'],
      processedText: json['processed_text'],
      outputText: json['output_text'],
      createdAt: DateTime.parse(json['created_at']),
      isEdited: json['is_edited'] ?? false,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_type': senderType,
      'input_type': inputType,
      'original_text': originalText,
      'processed_text': processedText,
      'output_text': outputText,
      'created_at': createdAt.toIso8601String(),
      'is_edited': isEdited,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
