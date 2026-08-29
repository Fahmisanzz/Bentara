class EmergencyIncidentModel {
  final String id;
  final String userId;
  final String emergencyType;
  final String message;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  EmergencyIncidentModel({
    required this.id,
    required this.userId,
    required this.emergencyType,
    required this.message,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });
}
