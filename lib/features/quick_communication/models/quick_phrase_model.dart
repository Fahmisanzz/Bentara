class QuickPhraseModel {
  final String id;
  final String? userId; // null means system default
  final String phrase; // previously fullSentence
  final String category;
  final bool isEmergency;
  final DateTime createdAt;
  final bool isFavorite; // Local state, not in DB necessarily

  QuickPhraseModel({
    required this.id,
    this.userId,
    required this.phrase,
    required this.category,
    required this.isEmergency,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory QuickPhraseModel.fromJson(Map<String, dynamic> json) {
    return QuickPhraseModel(
      id: json['id'],
      userId: json['user_id'],
      phrase: json['phrase'],
      category: json['category'],
      isEmergency: json['is_emergency'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  QuickPhraseModel copyWith({bool? isFavorite}) {
    return QuickPhraseModel(
      id: id,
      userId: userId,
      phrase: phrase,
      category: category,
      isEmergency: isEmergency,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
