import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyService {
  final SupabaseClient _supabase;
  EmergencyService(this._supabase);

  Future<void> logEmergency(String userId, String emergencyType, String message, {double? lat, double? lng}) async {
    try {
      await _supabase.from('emergency_logs').insert({
        'user_id': userId,
        'emergency_type': emergencyType,
        'message': message,
        'latitude': lat,
        'longitude': lng,
      });
    } catch (e) {
      print('Failed to log emergency: $e');
    }
  }
}
