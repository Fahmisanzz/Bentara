class UserProfileModel {
  final String id;
  final String name;
  final String role;
  
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.role,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      name: json['name'] ?? 'User',
      role: json['role'] ?? 'dengar',
    );
  }
}
