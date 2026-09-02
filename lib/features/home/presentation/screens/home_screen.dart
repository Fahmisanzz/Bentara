
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final profileState = ref.watch(profileNotifierProvider);

    final userName = profileState.profile?.name ?? currentUser?.name ?? 'Ghusty';
    final userEmail = currentUser?.email ?? 'ghustyganteng@gmail.com';

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.white,
    ));

    return Scaffold(
      backgroundColor: AppColors.primaryLight, // Solid Layer 1 Blue
      body: Stack(
        children: [
          // LAYER 1: SOLID BLUE BACKGROUND (Inherited from Scaffold backgroundColor)

          // CONTENT COLUMN
          SafeArea(
            bottom: true,
            child: Column(
              children: [
                // LAYER 1: USER HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    children: [
                      // Profile Avatar
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.pushNamed(RouteNames.profile),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              Container(
                                width: 44.0,
                                height: 44.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                  color: Colors.white, // Solid white background, no transparency
                                ),
                                child: const ClipOval(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primary,
                                    size: 26.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              // User Name & Email
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      userEmail,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Notification Bell
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white, // Solid white, no transparency
                          border: Border.all(color: Colors.white, width: 1.0),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primaryDark,
                            size: 20.0,
                          ),
                          onPressed: () {
                            context.pushNamed(RouteNames.history);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),

                // LAYER 2: SOLID WHITE BOTTOM SHEET (FIXED / NON-SCROLLABLE)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface, // Solid White
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10.0,
                          offset: const Offset(0, -4.0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20.0,
                        20.0,
                        20.0,
                        16.0 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BENTARA BRANDING
                          Row(
                            children: [
                              Image.asset(
                                'assets/logos/logo_bentara_biru.webp', // Keep logo asset as requested
                                height: 20.0,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.shield, color: AppColors.primary, size: 20);
                                },
                              ),
                              const SizedBox(width: 8.0),
                              const Text(
                                'BENTARA',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),

                          // EMERGENCY BUTTON — Flutter Native Solid Gradient
                          _EmergencyButton(
                            onTap: () => context.pushNamed(RouteNames.emergency),
                          ),
                          const SizedBox(height: 16.0),

                          // MENU UTAMA HEADER
                          const Text(
                            'Menu Utama',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // 2x2 CLEAN SOLID GRADIENT FEATURE CARDS GRID (FIXED FLEX)
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _FeatureCard(
                                          title: 'Komunikasi\nLangsung',
                                          iconData: Icons.chat_bubble_outline_rounded,
                                          gradient: AppGradients.lightBlue,
                                          iconColor: AppColors.lightBlue,
                                          onTap: () => context.pushNamed(RouteNames.communication),
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: _FeatureCard(
                                          title: 'Penerjemah\nIsyarat',
                                          iconData: Icons.sign_language,
                                          gradient: AppGradients.green,
                                          iconColor: AppColors.successGreen,
                                          onTap: () => context.pushNamed(RouteNames.signRecognition),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12.0),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _FeatureCard(
                                          title: 'Komunikasi\nCepat',
                                          iconData: Icons.flash_on_rounded,
                                          gradient: AppGradients.purple,
                                          iconColor: AppColors.accentPurple,
                                          onTap: () => context.pushNamed(RouteNames.quickCommunication),
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: _FeatureCard(
                                          title: 'Riwayat\nPercakapan',
                                          iconData: Icons.history_rounded,
                                          gradient: AppGradients.pink,
                                          iconColor: AppColors.accentPink,
                                          onTap: () => context.pushNamed(RouteNames.history),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}

/// PREMIUM NATIVE EMERGENCY BUTTON
class _EmergencyButton extends StatefulWidget {
  final VoidCallback onTap;

  const _EmergencyButton({required this.onTap});

  @override
  State<_EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<_EmergencyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.965).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) {
    _controller.forward();
    widget.onTap();
  }
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFC0392B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withValues(alpha: 0.35),
                blurRadius: 16.0,
                offset: const Offset(0, 7.0),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4.0,
                offset: const Offset(0, 2.0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // WARNING ICON inside solid circle
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 28.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                // LABEL
                const Text(
                  'MODE DARURAT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Tekan untuk menghubungi bantuan darurat',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
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

/// CLEAN GRADIENT FEATURE CARD
class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final LinearGradient gradient;
  final Color iconColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.iconData,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.30),
            blurRadius: 14.0,
            offset: const Offset(0, 6.0),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2.0),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          splashColor: Colors.white.withValues(alpha: 0.25),
          highlightColor: Colors.white.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ICON CONTAINER
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: 26.0,
                      ),
                    ),

                    const SizedBox(height: 10.0),

                    // TITLE
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
