import '../../../../core/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // TAMPILAN
          _buildSectionTitle('Tampilan & Aksesibilitas'),
          SwitchListTile(
            title: const Text('Mode Kontras Tinggi'),
            subtitle: const Text('Gunakan warna pekat untuk memperjelas teks'),
            value: settings.enableHighContrast,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(enableHighContrast: val)),
          ),
          ListTile(
            title: const Text('Ukuran Teks'),
            subtitle: Slider(
              value: settings.textScaleFactor,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: settings.textScaleFactor.toStringAsFixed(1),
              onChanged: (val) => notifier.updateSettings(settings.copyWith(textScaleFactor: val)),
            ),
          ),
          
          const Divider(height: 32),

          // TTS SOUND
          _buildSectionTitle('Suara Pembaca (TTS)'),
          ListTile(
            title: const Text('Kecepatan Suara'),
            subtitle: Slider(
              value: settings.ttsSpeed,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: settings.ttsSpeed.toStringAsFixed(1),
              onChanged: (val) => notifier.updateSettings(settings.copyWith(ttsSpeed: val)),
            ),
          ),
          ListTile(
            title: const Text('Nada Suara (Pitch)'),
            subtitle: Slider(
              value: settings.ttsPitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: settings.ttsPitch.toStringAsFixed(1),
              onChanged: (val) => notifier.updateSettings(settings.copyWith(ttsPitch: val)),
            ),
          ),
          
          const Divider(height: 32),

          // SYSTEM
          _buildSectionTitle('Sistem & Cache'),
          SwitchListTile(
            title: const Text('Getaran (Haptic Feedback)'),
            value: settings.enableHaptics,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => notifier.updateSettings(settings.copyWith(enableHaptics: val)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Bersihkan Cache Lokal', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Bersihkan Cache?'),
                  content: const Text('Semua pengaturan lokal akan dikembalikan ke bawaan.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Bersihkan', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(localStorageProvider).clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache berhasil dibersihkan. Restart aplikasi untuk efek penuh.')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang BENTARA'),
            subtitle: const Text('Versi 1.0.0 - KMIPN 2026'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary),
      ),
    );
  }
}
