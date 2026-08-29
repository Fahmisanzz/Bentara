import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/app_exceptions.dart' as app_err;
import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String name, String email, String password, UserRole role);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<AuthState> get authStateChanges;
}

class SupabaseAuthRepository implements IAuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw app_err.AuthException('Login failed. User not found.');
      }
      return _fetchUserMetadata(response.user!.id, email);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw app_err.AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String name, String email, String password, UserRole role) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role.name,
        },
      );
      if (response.user == null) {
        throw app_err.AuthException('Registration failed.');
      }
      
      // Upsert into a public users table if you plan to use RLS, otherwise metadata is enough for now.
      // Here we simulate returning the newly created user using metadata.
      return UserModel(
        id: response.user!.id,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw app_err.AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw app_err.AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      return await _fetchUserMetadata(user.id, user.email ?? '');
    } catch (e) {
      return null; // Fail gracefully
    }
  }

  Future<UserModel> _fetchUserMetadata(String id, String email) async {
    try {
      // 1. PHASE 2 ARCHITECTURE: Query the profiles table first
      final response = await _supabase.from('profiles').select().eq('id', id).maybeSingle();
      
      if (response != null) {
        return UserModel(
          id: id,
          email: email,
          name: response['name'] ?? 'User',
          role: response['role'] == 'tuli' ? UserRole.tuli : UserRole.dengar,
          createdAt: response['created_at'] != null 
              ? DateTime.parse(response['created_at']) 
              : DateTime.now(),
        );
      }
    } catch (e) {
      // If table doesn't exist yet, ignore and fallback to user_metadata gracefully
    }

    // 2. FALLBACK: Parse from user_metadata (useful while SQL Trigger is being setup)
    final user = _supabase.auth.currentUser;
    if (user != null && user.userMetadata != null) {
      final meta = user.userMetadata!;
      return UserModel(
        id: id,
        email: email,
        name: meta['name'] ?? 'User',
        role: meta['role'] == 'tuli' ? UserRole.tuli : UserRole.dengar,
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    }
    
    return UserModel(
      id: id,
      email: email,
      name: 'User',
      role: UserRole.dengar,
      createdAt: DateTime.now(),
    );
  }
}
