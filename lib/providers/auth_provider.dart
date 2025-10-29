import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_club_app/models/user_profile.dart';
import 'package:book_club_app/services/auth_service.dart';

/// Provides access to AuthService
final authServiceProvider = Provider((ref) => AuthService());

/// Watches Supabase authentication state (login, logout, refresh)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Tracks the currently signed-in user (from Supabase)
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// Fetches user profile data from your database using AuthService
final userProfileProvider = FutureProvider.family<UserProfile?, String>((ref, userId) async {
  if (userId.isEmpty) return null;
  return await ref.watch(authServiceProvider).getUserProfile(userId);
});

/// AuthNotifier handles login, signup, and logout logic
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null)) {
    _init();
  }

  void _init() {
    final user = _authService.currentUser;
    state = AsyncValue.data(user);
  }

  /// Signup user
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );
      state = AsyncValue.data(response.user);
      return null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return e.toString();
    }
  }

  /// Login user
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
      return null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return e.toString();
    }
  }

  /// Logout user
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }
}

/// Global provider for AuthNotifier (used for sign-in/out/signup actions)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});