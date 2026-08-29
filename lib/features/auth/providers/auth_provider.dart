import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return SupabaseAuthRepository(SupabaseService.client);
});

final currentUserProvider = StateProvider<UserModel?>((ref) => null);

class AuthNotifier extends StateNotifier<AppAuthState> {
  final IAuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref) : super(const AuthInitial()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _ref.read(currentUserProvider.notifier).state = user;
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      state = const Unauthenticated();
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.signInWithEmail(email, password);
      _ref.read(currentUserProvider.notifier).state = user;
      state = Authenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signUp(String name, String email, String password, UserRole role) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.signUpWithEmail(name, email, password, role);
      _ref.read(currentUserProvider.notifier).state = user;
      state = Authenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _authRepository.signOut();
      _ref.read(currentUserProvider.notifier).state = null;
      state = const Unauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider), ref);
});
