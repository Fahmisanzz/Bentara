class ConversationModel {
  final String id;
  final String userId;
  final String? title;
  final String? context;
  final DateTime startedAt;
  final DateTime? endedAt;

  const ConversationModel({
    required this.id,
    required this.userId,
    this.title,
    this.context,
    required this.startedAt,
    this.endedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      context: json['context'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
    );
  }
}
