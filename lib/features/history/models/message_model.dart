class MessageModel {
  final String id;
  final String conversationId;
  final String senderType; // 'tuli', 'dengar', 'system'
  final String inputType; // 'text', 'voice', 'sign'
  final String? originalText;
  final String? processedText;
  final String? outputText;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.inputType,
    this.originalText,
    this.processedText,
    this.outputText,
    required this.createdAt,
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
    );
  }
}
