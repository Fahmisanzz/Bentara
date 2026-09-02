import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _selectedRole = 'tuli';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _initFieldsIfNeeded(ProfileState profileState, WidgetRef ref) {
    if (!_initialized) {
      final profile = profileState.profile;
      final currentUser = ref.read(currentUserProvider);
      
      _nameController.text = profile?.name ?? currentUser?.name ?? '';
      _selectedRole = profile?.role.toLowerCase() ?? (currentUser?.role.name ?? 'tuli');
      _initialized = true;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(profileNotifierProvider.notifier);
    final success = await notifier.updateProfile(
      name: _nameController.text.trim(),
      role: _selectedRole,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil diperbarui!', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.successGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal memperbarui profil.', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    _initFieldsIfNeeded(profileState, ref);
    final currentUser = ref.watch(currentUserProvider);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18.0, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0 + bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar Preview with camera badge
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.lightBlue,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8.0,
                              offset: const Offset(0, 3.0),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 40.0,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person_rounded, size: 44.0, color: AppColors.primary),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2.0),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 16.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Email Field (Read Only)
                const Text(
                  'Email Akun',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 13.5),
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  initialValue: currentUser?.email ?? 'user@bentara.id',
                  enabled: false,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14.0),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_rounded, color: AppColors.textSecondary, size: 20.0),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide.none,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),

                // Name Field
                const Text(
                  'Nama Lengkap',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 13.5),
                ),
                const SizedBox(height: 6.0),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14.0),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama lengkap',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20.0),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Role Selection Header
                const Text(
                  'Peran Utama',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 13.5),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'Pilih peran untuk menyesuaikan fitur utama komunikasi Anda di dalam aplikasi.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 10.0),

                // Role Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        title: 'Teman Tuli',
                        subtitle: 'Bahasa Isyarat',
                        icon: Icons.sign_language_rounded,
                        isSelected: _selectedRole == 'tuli',
                        gradient: AppGradients.green,
                        onTap: () => setState(() => _selectedRole = 'tuli'),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _RoleCard(
                        title: 'Teman Dengar',
                        subtitle: 'Bahasa Lisan',
                        icon: Icons.hearing_rounded,
                        isSelected: _selectedRole == 'dengar',
                        gradient: AppGradients.lightBlue,
                        onTap: () => setState(() => _selectedRole = 'dengar'),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),

                // Save Button (Solid Opaque Gradient Button)
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: profileState.isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2.0,
                      shadowColor: AppColors.primary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                    child: profileState.isLoading
                        ? const SizedBox(
                            height: 22.0,
                            width: 22.0,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.white,
          gradient: isSelected ? gradient : null,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected 
            ? [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4.0),
                )
              ]
            : [],
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              size: 28.0, 
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.0, 
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white.withValues(alpha: 0.9) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
