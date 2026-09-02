import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart';

/// ============================================================
/// BENTARA — SIGN UP SCREEN
/// ============================================================
/// Halaman registrasi user baru dengan photographic background.
///
/// CARA MENGEDIT:
/// - Cari komentar bernomor (// === 1. BACKGROUND === dst.)
/// - Ubah angka pada SizedBox, fontSize, fontWeight, dll.
/// - Logic auth (signUp, validation) ada di _submit().
/// - Jangan hapus Form, key, atau controller.
/// ============================================================
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // === Form State (JANGAN UBAH) ===
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // === Role & Password Visibility State ===
  UserRole _selectedRole = UserRole.dengar; // Default role
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // === SUBMIT LOGIC (JANGAN UBAH) ===
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _emailController.text.trim().split('@').first;
      ref.read(authNotifierProvider.notifier).signUp(
        name,
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole,
      );
    }
  }

  // =========================================================
  // === HELPER: Translucent Input Decoration ===
  // Digunakan oleh email & password field.
  // =========================================================
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.50),
        fontSize: 15.0,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.20),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 22.0,
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 11.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final size = MediaQuery.sizeOf(context);
    final formWidth = size.width * 0.74;
    final leftMargin = math.max(36.0, size.width * 0.13);

    // === Error Handling (JANGAN UBAH) ===
    ref.listen<AppAuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final isLoading = authState is AuthLoading;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // === 1. BACKGROUND IMAGE ===
            Positioned.fill(
              child: Image.asset(
                'assets/images/signin_signup_forgotpassword_bg.webp',
                fit: BoxFit.cover,
                alignment: const Alignment(0.2, 0.0),
              ),
            ),

            // === 2. GRADIENT OVERLAY ===
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.03),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    stops: const [0.0, 0.30, 1.0],
                  ),
                ),
              ),
            ),

            // === 3. FOREGROUND CONTENT ===
            SafeArea(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: leftMargin,
                        right: math.max(16.0, size.width - leftMargin - formWidth),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(flex: 6),

                            // === TITLE ===
                            const Text(
                              'SIGN UP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 2.0),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Menjembatani komunikasi,\nmendekatkan hati',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 1.0),
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30.0),

                            // === EMAIL INPUT ===
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                              decoration: _buildInputDecoration(
                                hintText: 'alamat email',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Email is required';
                                if (!value.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // === PASSWORD INPUT ===
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                              decoration: _buildInputDecoration(
                                hintText: 'password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white70,
                                    size: 20.0,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Password is required';
                                if (value.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24.0),

                            // === ROLE LABEL ===
                            const Text(
                              'Aku Adalah:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 1.0),
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12.0),

                            // === SEGMENTED ROLE SLIDER ===
                            _buildSegmentedRoleSlider(),

                            const SizedBox(height: 32.0),

                            // === BUAT AKUN BUTTON + LOGO ===
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 200.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 58.0,
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 3.0,
                                          shadowColor: AppColors.primary.withValues(alpha: 0.40),
                                          shape: const StadiumBorder(),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'BUAT AKUN',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Image.asset(
                                  'assets/logos/logo_bentara_biru.webp',
                                  height: 40.0,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16.0),
                            const Spacer(flex: 3),

                            // === BOTTOM AUTH LINK ===
                            Center(
                              child: Column(
                                children: [
                                  const Text(
                                    'Sudah punya akun sebelumnya?',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),
                                  GestureDetector(
                                    onTap: () => context.pushNamed(RouteNames.login),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // === 15. SEGMENTED ROLE SLIDER (Widget Builder) ===
  // =================================================================
  // Single container dengan sliding orange highlight.
  //
  // CARA MENGUBAH:
  // - _sliderHeight  : tinggi slider (default 42dp)
  // - _sliderRadius  : border radius (default 6dp)
  // - _animDuration  : durasi animasi slide (default 220ms)
  // - Warna selected : AppColors.primary
  // - Animasi : AnimatedAlign & AnimatedContainer: semi-transparan putih
  // =================================================================
  Widget _buildSegmentedRoleSlider() {
    const double sliderHeight = 42.0;
    const double sliderRadius = 12.0;
    const Duration animDuration = Duration(milliseconds: 220);

    return Container(
      height: sliderHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(sliderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: animDuration,
            curve: Curves.easeInOut,
            alignment: _selectedRole == UserRole.dengar
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(sliderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = UserRole.dengar),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: animDuration,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: _selectedRole == UserRole.dengar ? FontWeight.w700 : FontWeight.w400,
                      ),
                      child: const Text('Teman Dengar'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = UserRole.tuli),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: animDuration,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: _selectedRole == UserRole.tuli ? FontWeight.w700 : FontWeight.w400,
                      ),
                      child: const Text('Teman Tuli'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
