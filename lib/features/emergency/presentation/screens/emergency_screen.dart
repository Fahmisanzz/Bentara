import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/emergency_provider.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});
  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  Timer? _flashTimer;
  bool _flashColorState = false;

  @override
  void initState() {
    super.initState();
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (ref.read(emergencyNotifierProvider)) {
        setState(() {
          _flashColorState = !_flashColorState;
        });
      }
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmergencyActive = ref.watch(emergencyNotifierProvider);
    final notifier = ref.read(emergencyNotifierProvider.notifier);

    final bgColor = isEmergencyActive 
        ? (_flashColorState ? Colors.red.shade900 : Colors.yellow.shade900)
        : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Mode Darurat', style: TextStyle(color: isEmergencyActive ? Colors.white : Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isEmergencyActive ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isEmergencyActive) ...[
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'PILIH PESAN DARURAT',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 40),
              _EmergencyButton(
                title: 'SAYA BUTUH AMBULANS SEKARANG!',
                onTap: () => notifier.activateEmergency('Tolong, saya butuh ambulans sekarang! Ini darurat medis!'),
              ),
              const SizedBox(height: 16),
              _EmergencyButton(
                title: 'TOLONG HUBUNGI POLISI!',
                onTap: () => notifier.activateEmergency('Tolong panggil polisi! Saya dalam bahaya!'),
              ),
              const SizedBox(height: 16),
              _EmergencyButton(
                title: 'BAWA KE RUMAH SAKIT!',
                onTap: () => notifier.activateEmergency('Tolong bawa saya ke rumah sakit terdekat!'),
              ),
              const SizedBox(height: 16),
              _EmergencyButton(
                title: 'SAYA TERLUKA!',
                onTap: () => notifier.activateEmergency('Saya terluka parah, tolong bantu saya!'),
              ),
              const SizedBox(height: 16),
              _EmergencyButton(
                title: 'SAYA BUTUH BANTUAN!',
                onTap: () => notifier.activateEmergency('Tolong, saya butuh bantuan segera!'),
              ),
            ] else ...[
              const Icon(Icons.campaign, size: 120, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'PESAN DARURAT SEDANG DISIARKAN...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => notifier.deactivateEmergency(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('HENTIKAN SIARAN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _EmergencyButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}
