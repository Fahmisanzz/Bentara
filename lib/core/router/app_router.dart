import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/communication/presentation/screens/communication_screen.dart';
import '../../features/sign_recognition/presentation/screens/sign_recognition_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/quick_communication/presentation/screens/quick_communication_screen.dart';
import '../../features/emergency/presentation/screens/emergency_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';

// Riverpod Provider for GoRouter to enable reactivity to AuthState
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final isAuth = authState is Authenticated;
      final isAuthLoading = authState is AuthLoading;
      final isAuthInitial = authState is AuthInitial;
      
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToSplash = state.matchedLocation == '/';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      // Let initial loading/splash finish resolving
      if (isAuthInitial) return null;

      // Allow users to access public routes
      final isPublicRoute = isGoingToLogin || isGoingToRegister || isGoingToSplash || isGoingToOnboarding;

      if (!isAuth && !isPublicRoute && !isAuthLoading) {
        // Unauthenticated users trying to access protected routes go to login
        return '/login';
      }

      if (isAuth && (isGoingToLogin || isGoingToRegister || isGoingToSplash)) {
        // Authenticated users trying to access auth/splash routes go to home
        return '/home';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/communication',
        name: RouteNames.communication,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CommunicationScreen(conversationId: extra?['conversationId'] as String?);
        },
      ),
      GoRoute(
        path: '/sign-recognition',
        name: RouteNames.signRecognition,
        builder: (context, state) => const SignRecognitionScreen(),
      ),
      GoRoute(
        path: '/history',
        name: RouteNames.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/quick-communication',
        name: RouteNames.quickCommunication,
        builder: (context, state) => const QuickCommunicationScreen(),
      ),
      GoRoute(
        path: '/emergency',
        name: RouteNames.emergency,
        builder: (context, state) => const EmergencyScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
