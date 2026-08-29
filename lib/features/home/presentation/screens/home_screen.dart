import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BENTARA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.pushNamed('settings')),
          IconButton(icon: const Icon(Icons.person), onPressed: () => context.pushNamed('profile')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Button (Massive & Red)
              GestureDetector(
                onTap: () => context.pushNamed('emergency'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 48, color: Colors.white),
                      SizedBox(height: 8),
                      Text('TOMBOL DARURAT (SOS)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('Menu Utama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              
              // Grid Menu
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _MenuCard(
                    title: 'Komunikasi\nLangsung',
                    icon: Icons.record_voice_over,
                    color: AppColors.primary,
                    onTap: () => context.pushNamed('communication'),
                  ),
                  _MenuCard(
                    title: 'Penerjemah\nIsyarat',
                    icon: Icons.sign_language,
                    color: AppColors.secondary,
                    onTap: () => context.pushNamed('sign_recognition'),
                  ),
                  _MenuCard(
                    title: 'Komunikasi\nCepat',
                    icon: Icons.flash_on,
                    color: Colors.orange.shade600,
                    onTap: () => context.pushNamed('quick_communication'),
                  ),
                  _MenuCard(
                    title: 'Riwayat\nPercakapan',
                    icon: Icons.history,
                    color: Colors.blueGrey.shade600,
                    onTap: () => context.pushNamed('history'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
