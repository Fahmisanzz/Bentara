import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';
import 'auth_state.dart';
import '../../profile/providers/profile_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../communication/providers/communication_provider.dart';

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
        _ref.read(profileNotifierProvider.notifier).loadProfile();
        _ref.read(historyListProvider.notifier).loadHistory();
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
      _ref.read(profileNotifierProvider.notifier).loadProfile();
      _ref.read(historyListProvider.notifier).loadHistory();
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
      _ref.read(profileNotifierProvider.notifier).loadProfile();
      _ref.read(historyListProvider.notifier).loadHistory();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AuthLoading();
    try {
      await _authRepository.resetPassword(email);
      state = const Unauthenticated();
    } catch (e) {
      state = const AuthError('Gagal mengirim link reset. Silakan coba lagi.');
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _authRepository.signOut();
      _ref.read(currentUserProvider.notifier).state = null;
      _ref.read(profileNotifierProvider.notifier).reset();
      _ref.read(historyListProvider.notifier).reset();
      _ref.read(communicationNotifierProvider.notifier).reset();
      state = const Unauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider), ref);
});
