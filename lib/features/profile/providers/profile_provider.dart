import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

class ProfileState {
  final UserProfileModel? profile;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProfileState copyWith({
    UserProfileModel? profile,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileNotifier(this._ref) : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        int sessionsCount = 0;
        try {
          final List data = await Supabase.instance.client.from('conversations').select('id').eq('user_id', user.id);
          sessionsCount = data.length;
        } catch(_) {}
        
        final profile = UserProfileModel.fromJson({
          ...response,
          'total_sessions': sessionsCount,
          'total_messages': sessionsCount * 4,
        });
        state = state.copyWith(profile: profile, isLoading: false);
        return;
      }
    } catch (_) {
      // Offline / fallback
    }

    // Fallback dari currentUserProvider
    final fallbackProfile = UserProfileModel(
      id: user.id,
      name: user.name,
      role: user.role.name,
    );
    state = state.copyWith(profile: fallbackProfile, isLoading: false);
  }

  Future<bool> updateProfile({required String name, required String role}) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(isLoading: false, errorMessage: 'User belum login');
      return false;
    }

    final newRoleEnum = role.toLowerCase() == 'tuli' ? UserRole.tuli : UserRole.dengar;
    final updatedUser = user.copyWith(name: name, role: newRoleEnum);

    try {
      // 1. Update Supabase table 'profiles'
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'name': name,
        'role': role.toLowerCase(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Update Auth metadata
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'name': name, 'role': role.toLowerCase()}),
      );
    } catch (_) {
      // Supabase mungkin offline di demo mode, tetap update state lokal
    }

    // Update currentUserProvider
    _ref.read(currentUserProvider.notifier).state = updatedUser;

    final updatedProfile = UserProfileModel(
      id: user.id,
      name: name,
      role: role.toLowerCase(),
    );

    state = state.copyWith(
      profile: updatedProfile,
      isLoading: false,
      isSuccess: true,
    );

    return true;
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});

// Backward compatibility provider
final profileProvider = Provider<AsyncValue<UserProfileModel?>>((ref) {
  final state = ref.watch(profileNotifierProvider);
  if (state.isLoading && state.profile == null) {
    return const AsyncValue.loading();
  }
  if (state.errorMessage != null && state.profile == null) {
    return AsyncValue.error(state.errorMessage!, StackTrace.current);
  }
  return AsyncValue.data(state.profile);
});
