class UserProfileModel {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  final int totalSessions;
  final int totalMessages;
  
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.totalSessions = 0,
    this.totalMessages = 0,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['full_name'] as String? ?? 'User',
      role: json['role'] as String? ?? 'dengar',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      totalSessions: json['total_sessions'] as int? ?? 0,
      totalMessages: json['total_messages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
      'total_sessions': totalSessions,
      'total_messages': totalMessages,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? role,
    String? avatarUrl,
    int? totalSessions,
    int? totalMessages,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMessages: totalMessages ?? this.totalMessages,
    );
  }
}
