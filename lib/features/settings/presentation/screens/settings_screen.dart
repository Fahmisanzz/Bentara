import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../../../core/services/local_storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.white,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18.0, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 24.0 + bottomInset),
        children: [
          // AKUN SECTION
          _buildSectionTitle('Akun'),
          _buildSettingsCard(
            children: [
              _buildNavigationTile(
                icon: Icons.person_outline_rounded,
                title: 'Profil Pengguna',
                subtitle: 'Edit informasi profil',
                onTap: () => context.pushNamed('edit_profile'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.connect_without_contact_rounded,
                title: 'Peran Komunikasi',
                subtitle: 'Teman Dengar / Teman Tuli',
                onTap: () => context.pushNamed('edit_profile'),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // PREFERENSI SECTION
          _buildSectionTitle('Preferensi'),
          _buildSettingsCard(
            children: [
              _buildSwitchTile(
                icon: Icons.contrast_rounded,
                title: 'Mode Kontras Tinggi',
                subtitle: 'Gunakan warna pekat untuk memperjelas teks',
                value: settings.enableHighContrast,
                onChanged: (val) => notifier.updateSettings(settings.copyWith(enableHighContrast: val)),
              ),
              _buildDivider(),
              _buildSliderTile(
                icon: Icons.format_size_rounded,
                title: 'Ukuran Teks',
                value: settings.textScaleFactor,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                onChanged: (val) => notifier.updateSettings(settings.copyWith(textScaleFactor: val)),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // KOMUNIKASI SECTION
          _buildSectionTitle('Komunikasi'),
          _buildSettingsCard(
            children: [
              _buildSliderTile(
                icon: Icons.speed_rounded,
                title: 'Kecepatan Suara (TTS)',
                value: settings.ttsSpeed,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: (val) => notifier.updateSettings(settings.copyWith(ttsSpeed: val)),
              ),
              _buildDivider(),
              _buildSliderTile(
                icon: Icons.multitrack_audio_rounded,
                title: 'Nada Suara (Pitch)',
                value: settings.ttsPitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (val) => notifier.updateSettings(settings.copyWith(ttsPitch: val)),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.vibration_rounded,
                title: 'Getaran (Haptic Feedback)',
                subtitle: 'Getaran sistem',
                value: settings.enableHaptics,
                onChanged: (val) => notifier.updateSettings(settings.copyWith(enableHaptics: val)),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // TENTANG SECTION
          _buildSectionTitle('Tentang'),
          _buildSettingsCard(
            children: [
              _buildNavigationTile(
                icon: Icons.info_outline_rounded,
                title: 'Tentang BENTARA',
                subtitle: 'Versi 1.0.0 - KMIPN 2026',
                onTap: () {},
                showChevron: false,
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.delete_outline_rounded,
                title: 'Bersihkan Cache Lokal',
                color: AppColors.error,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      title: const Text('Bersihkan Cache?', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text('Semua pengaturan lokal akan dikembalikan ke bawaan.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false), 
                          child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold))
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            elevation: 0,
                          ),
                          child: const Text('Bersihkan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(localStorageProvider).clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Cache berhasil dibersihkan. Restart aplikasi untuk efek penuh.', style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16.0),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 48.0),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14.0, 
          fontWeight: FontWeight.w800, 
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.0,
            offset: const Offset(0, 4.0),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56.0),
      child: Divider(height: 1.0, color: Colors.grey.shade100),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22.0),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.0, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12.0, color: AppColors.textSecondary)),
      trailing: showChevron ? const Icon(Icons.chevron_right_rounded, color: Colors.grey) : null,
      onTap: onTap,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(icon, color: color, size: 22.0),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.0, color: color)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      secondary: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22.0),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.0, color: AppColors.textPrimary)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12.0, color: AppColors.textSecondary)) : null,
      value: value,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.successGreen,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade300,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22.0),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.0, color: AppColors.textPrimary)),
                    Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
