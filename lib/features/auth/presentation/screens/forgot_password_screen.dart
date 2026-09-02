import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// ============================================================
/// BENTARA — FORGOT PASSWORD SCREEN
/// ============================================================
/// Halaman pemulihan kata sandi dengan photographic background.
/// Menggunakan template & design system yang SAMA DENGAN Sign In/Up.
/// 100% Bahasa Indonesia.
/// ============================================================
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await ref
            .read(authRepositoryProvider)
            .resetPassword(_emailController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link reset kata sandi telah dikirim ke emailmu.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengirim link reset. Silakan coba lagi.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
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
    final size = MediaQuery.sizeOf(context);
    final formWidth = size.width * 0.74;
    final leftMargin = math.max(36.0, size.width * 0.13);

    return Scaffold(
      resizeToAvoidBottomInset: false, // PREVENT UI JUMP/SCROLL ON KEYBOARD
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // =============================================================
            // === 1. BACKGROUND IMAGE (SAMA DENGAN SIGN IN / SIGN UP) ===
            // =============================================================
            Positioned.fill(
              child: Image.asset(
                'assets/images/signin_signup_forgotpassword_bg.webp',
                fit: BoxFit.cover,
                alignment: const Alignment(0.2, 0.0),
              ),
            ),

            // =============================================================
            // === 2. GRADIENT OVERLAY ===
            // =============================================================
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

            // =============================================================
            // === 3. FOREGROUND CONTENT ===
            // =============================================================
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
                            // =============================================
                            // === 4. TOP SPACING ===
                            // =============================================
                            const Spacer(flex: 7),

                            // =============================================
                            // === 5. PAGE TITLE — "LUPA PASSWORD" ===
                            // =============================================
                            Text(
                              'LUPA\nPASSWORD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    offset: const Offset(0, 2.0),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                            ),

                            // =============================================
                            // === 6. SPACING: TITLE → TAGLINE ===
                            // =============================================
                            const SizedBox(height: 8.0),

                            // =============================================
                            // === 7. TAGLINE ===
                            // =============================================
                            Text(
                              'Masukan alamat emailmu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.40),
                                    offset: const Offset(0, 1.0),
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                            ),

                            // =============================================
                            // === 8. SPACING: TAGLINE → INFO RESET ===
                            // =============================================
                            const SizedBox(height: 30.0),

                            // =============================================
                            // === 9. INFORMASI RESET ===
                            // =============================================
                            Text(
                              'Cek email untuk reset kata sandi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    offset: const Offset(0, 1.0),
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                            ),

                            // =============================================
                            // === 10. SPACING: INFO → EMAIL FIELD ===
                            // =============================================
                            const SizedBox(height: 12.0),

                            // =============================================
                            // === 11. EMAIL INPUT ===
                            // =============================================
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
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan alamat email terlebih dahulu.';
                                }
                                if (!value.contains('@')) {
                                  return 'Format email tidak valid.';
                                }
                                return null;
                              },
                            ),

                            // =============================================
                            // === 12. SPACING: EMAIL FIELD → CTA ===
                            // =============================================
                            const SizedBox(height: 32.0),

                            // =============================================
                            // === 13. CTA GROUP: KIRIM LINK RESET + LOGO ===
                            // =============================================
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // --- Button KIRIM LINK RESET ---
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 200.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 58.0,
                                      child: ElevatedButton(
                                        onPressed: _isSubmitting ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              AppColors.primary.withValues(alpha: 0.6),
                                          elevation: 3.0,
                                          shadowColor:
                                              AppColors.primary.withValues(alpha: 0.40),
                                          shape: const StadiumBorder(),
                                        ),
                                        child: _isSubmitting
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'KIRIM LINK RESET',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                // --- Logo BENTARA ---
                                Image.asset(
                                  'assets/logos/logo_bentara_biru.webp',
                                  height: 40.0,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),

                            // =============================================
                            // === 14. FLEXIBLE SPACE & BOTTOM ===
                            // =============================================
                            const SizedBox(height: 16.0),
                            const Spacer(flex: 4),

                            // =============================================
                            // === 15. BOTTOM RETURN LINK ===
                            // =============================================
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.pushNamed(RouteNames.login);
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Kembali ke Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                      decorationThickness: 1.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.35),
                                          offset: const Offset(0, 1.0),
                                          blurRadius: 3.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // =============================================
                            // === 16. BOTTOM SPACING ===
                            // =============================================
                            const SizedBox(height: 36.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =============================================================
            // === BACK BUTTON OVERLAY (POJOK KIRI ATAS) ===
            // =============================================================
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.0,
              left: 12.0,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 24.0,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.pushNamed('login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
