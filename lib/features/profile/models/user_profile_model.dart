class UserProfileModel {
  final String id;
  final String name;
  final String role;
  final int totalSessions;
  final int totalMessages;
  
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.role,
    this.totalSessions = 0,
    this.totalMessages = 0,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      name: json['name'] ?? 'User',
      role: json['role'] ?? 'dengar',
    );
  }
}
