import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/local_storage_service.dart';
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

  void reset() {
    state = const ProfileState();
  }

  Future<void> loadProfile() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = const ProfileState();
      return;
    }

    // Jika ID profil di state berbeda dari user yang login, bersihkan state lama
    if (state.profile != null && state.profile!.id != user.id) {
      state = const ProfileState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    // 1. Ambil dari cache lokal Hive khusus ID pengguna ini agar instan
    try {
      final cachedJsonStr = _ref.read(localStorageProvider).getString('profile_${user.id}');
      if (cachedJsonStr != null) {
        final cachedProfile = UserProfileModel.fromJson(jsonDecode(cachedJsonStr));
        state = state.copyWith(profile: cachedProfile, isLoading: false);
      }
    } catch (_) {}

    // 2. Ambil data terbaru dari Supabase table 'profiles'
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

        // Simpan ke cache lokal Hive
        try {
          await _ref.read(localStorageProvider).saveString('profile_${user.id}', jsonEncode(profile.toJson()));
        } catch (_) {}

        // Sinkronkan ke currentUserProvider agar data selalu konsisten di seluruh app
        final syncedUser = user.copyWith(
          name: profile.name,
          role: profile.role.toLowerCase() == 'tuli' ? UserRole.tuli : UserRole.dengar,
          avatarUrl: profile.avatarUrl,
        );
        _ref.read(currentUserProvider.notifier).state = syncedUser;

        state = state.copyWith(profile: profile, isLoading: false);
        return;
      }
    } catch (e) {
      debugPrint('Error loading profile from Supabase table: $e');
    }

    // 3. Fallback: Cek dari userMetadata di Supabase Auth jika tabel profiles belum memiliki baris
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    final metaName = (meta?['name'] as String?) ?? (meta?['full_name'] as String?);
    final metaRole = meta?['role'] as String?;
    final metaAvatar = meta?['avatar_url'] as String?;

    final resolvedName = (metaName != null && metaName.isNotEmpty && metaName != 'User') 
        ? metaName 
        : (user.name.isNotEmpty && user.name != 'User' ? user.name : (state.profile?.name ?? 'User'));

    final resolvedAvatar = metaAvatar ?? user.avatarUrl ?? state.profile?.avatarUrl;
    final resolvedRole = metaRole ?? user.role.name;

    final fallbackProfile = UserProfileModel(
      id: user.id,
      name: resolvedName,
      role: resolvedRole,
      avatarUrl: resolvedAvatar,
    );

    // Sinkronkan ke currentUserProvider
    if (resolvedName != user.name || resolvedAvatar != user.avatarUrl) {
      final syncedUser = user.copyWith(
        name: resolvedName,
        role: resolvedRole.toLowerCase() == 'tuli' ? UserRole.tuli : UserRole.dengar,
        avatarUrl: resolvedAvatar,
      );
      _ref.read(currentUserProvider.notifier).state = syncedUser;
    }

    state = state.copyWith(profile: fallbackProfile, isLoading: false);
  }

  Future<bool> updateProfile({
    required String name,
    required String role,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(isLoading: false, errorMessage: 'User belum login');
      return false;
    }

    // 1. Proses Avatar: Jika berupa file lokal, kompres dan ubah ke Base64 Data URI agar tersimpan permanen di cloud Supabase
    String? processedAvatar = avatarUrl ?? state.profile?.avatarUrl ?? user.avatarUrl;
    if (processedAvatar != null && 
        !processedAvatar.startsWith('http') && 
        !processedAvatar.startsWith('data:')) {
      try {
        final file = File(processedAvatar);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final decoded = img.decodeImage(bytes);
          if (decoded != null) {
            // Resize ke max 256x256 untuk efisiensi
            final resized = (decoded.width > 256 || decoded.height > 256)
                ? img.copyResize(decoded, width: 256, height: 256)
                : decoded;
            final jpgBytes = img.encodeJpg(resized, quality: 75);
            processedAvatar = 'data:image/jpeg;base64,${base64Encode(jpgBytes)}';
          }
        }
      } catch (e) {
        debugPrint('Error processing avatar image: $e');
      }
    }

    final newRoleEnum = role.toLowerCase() == 'tuli' ? UserRole.tuli : UserRole.dengar;
    final updatedUser = user.copyWith(
      name: name,
      role: newRoleEnum,
      avatarUrl: processedAvatar,
    );

    // 2. Simpan ke Supabase Auth metadata (prioritas utama, selalu berhasil untuk user yang login)
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'name': name,
          'role': role.toLowerCase(),
          if (processedAvatar != null) 'avatar_url': processedAvatar,
        }),
      );
    } catch (e) {
      debugPrint('Error updating Supabase auth metadata: $e');
    }

    // 3. Simpan ke tabel Supabase 'profiles'
    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'name': name,
        'full_name': name,
        'role': role.toLowerCase(),
        if (processedAvatar != null) 'avatar_url': processedAvatar,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating Supabase profiles table with name: $e. Retrying with full_name...');
      try {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'full_name': name,
          if (processedAvatar != null) 'avatar_url': processedAvatar,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e2) {
        debugPrint('Fallback upsert error: $e2');
      }
    }

    // Update currentUserProvider
    _ref.read(currentUserProvider.notifier).state = updatedUser;

    final updatedProfile = UserProfileModel(
      id: user.id,
      name: name,
      role: role.toLowerCase(),
      avatarUrl: processedAvatar,
      totalSessions: state.profile?.totalSessions ?? 0,
      totalMessages: state.profile?.totalMessages ?? 0,
    );

    // Simpan ke cache lokal Hive khusus ID pengguna ini
    try {
      await _ref.read(localStorageProvider).saveString('profile_${user.id}', jsonEncode(updatedProfile.toJson()));
    } catch (_) {}

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
