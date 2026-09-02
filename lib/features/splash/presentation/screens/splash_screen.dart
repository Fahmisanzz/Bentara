import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isAnimationComplete = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _isAnimationComplete = true;
        });
        _checkAndNavigate();
      }
    });
  }

  void _checkAndNavigate() {
    if (!mounted || !_isAnimationComplete) return;

    final authState = ref.read(authNotifierProvider);

    if (authState is Authenticated) {
      context.goNamed(RouteNames.home);
    } else if (authState is Unauthenticated || authState is AuthError) {
      // Direct unauthenticated users to Onboarding screen as the initial public point
      context.goNamed(RouteNames.onboarding);
    }
    // If AuthInitial or AuthLoading, do nothing. The listener will catch it when it updates.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to AuthState to navigate if auth resolves AFTER animation finishes
    ref.listen<AppAuthState>(authNotifierProvider, (previous, next) {
      if (_isAnimationComplete) {
        if (next is Authenticated) {
          context.goNamed(RouteNames.home);
        } else if (next is Unauthenticated || next is AuthError) {
          context.goNamed(RouteNames.onboarding);
        }
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/logos/logo_bentara_biru.webp',
                width: 140.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
