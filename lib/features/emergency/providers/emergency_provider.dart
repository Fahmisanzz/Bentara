import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../communication/providers/communication_provider.dart';
import '../services/emergency_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final emergencyServiceProvider = Provider((ref) => EmergencyService(Supabase.instance.client));

class EmergencyNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _loopTimer;
  bool _isFlashing = false;

  EmergencyNotifier(this._ref) : super(false);

  bool get isFlashing => _isFlashing;

  void activateEmergency(String message) {
    state = true;
    _isFlashing = true;
    
    // Log to backend
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      String type = 'general';
      if (message.toLowerCase().contains('ambulans') || message.toLowerCase().contains('medis')) {
        type = 'ambulance';
      } else if (message.toLowerCase().contains('polisi')) {
        type = 'police';
      }
      _ref.read(emergencyServiceProvider).logEmergency(user.id, type, message);
    }

    _speakAndLoop(message);
  }

  void _speakAndLoop(String message) async {
    if (!state) return;
    
    final tts = _ref.read(ttsServiceProvider);
    await tts.speak(message);
    
    _loopTimer = Timer(const Duration(seconds: 5), () {
      if (state) _speakAndLoop(message);
    });
  }
  
  void toggleFlash() {
    if (state) {
      _isFlashing = !_isFlashing;
    }
  }

  void deactivateEmergency() {
    state = false;
    _isFlashing = false;
    _loopTimer?.cancel();
    _ref.read(ttsServiceProvider).stop();
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    super.dispose();
  }
}

final emergencyNotifierProvider = StateNotifierProvider<EmergencyNotifier, bool>((ref) {
  return EmergencyNotifier(ref);
});
