import 'package:leaflens/core/errors/failures.dart';
import 'package:leaflens/core/network/api_client.dart';
import 'package:leaflens/features/auth/data/leaf_lens_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Repository for LeafLens user auth through LeafLensAuth.
///
/// The rest of the app calls this, not LeafLensAuth directly.
class AuthRepository {
  /// Creates an [AuthRepository] backed by the given [ApiClient].
  AuthRepository(this._api);
  final ApiClient _api;

  /// Login with email/password.
  /// Throws [AuthFailure] with a user-friendly message on failure.
  Future<void> login(String email, String password) async {
    try {
      final token = await LeafLensAuth.signInWithPassword(
        email: email,
        password: password,
      );
      _api.token = token;
    } on Exception catch (e) {
      throw AuthFailure(_mapSupabaseError(e));
    }
  }

  /// Register a new account.
  /// Throws [AuthFailure] with a user-friendly message on failure.
  Future<void> register(String email, String password) async {
    try {
      final token = await LeafLensAuth.signUp(
        email: email,
        password: password,
      );
      _api.token = token;
    } on Exception catch (e) {
      throw AuthFailure(_mapSupabaseError(e));
    }
  }

  /// Logout — clears the Supabase session and API token.
  Future<void> logout() async {
    await LeafLensAuth.signOut();
    _api.token = null;
  }

  /// Maps Supabase's raw error messages to user-friendly text.
  ///
  /// Supabase errors are developer-facing (e.g. "Invalid login credentials").
  /// This maps the most common ones to something a user can act on.
  /// Unrecognised errors fall through to a generic message.
  static String _mapSupabaseError(Exception e) {
    final raw = e.toString().toLowerCase();

    for (final entry in _supabaseErrorMap.entries) {
      if (raw.contains(entry.key)) return entry.value;
    }

    // Fallback — don't leak raw Supabase text.
    return 'Something went wrong. Please try again.';
  }

  /// Supabase error substring → user-friendly message.
  static const _supabaseErrorMap = {
    'invalid login credentials': 'Email or password is incorrect.',
    'email not confirmed': 'Please confirm your email before logging in.',
    'email rate limit': 'Too many attempts. Please wait and try again.',
    'rate limit': 'Too many attempts. Please wait and try again.',
    'password should be at least': 'Password must be at least 6 characters.',
    'invalid format': 'Please enter a valid email address.',
    'invalid email': 'Please enter a valid email address.',
    'user already registered': 'This email is already registered.',
    'already registered': 'This email is already registered.',
    'signup is disabled': 'Account creation is currently disabled.',
  };
}

// ── Providers ────────────────────────────────────────────

/// Provides a singleton [ApiClient] instance.
@riverpod
ApiClient apiClient(Ref ref) => ApiClient();

/// Provides the [AuthRepository] used for login/signup/logout operations.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.read(apiClientProvider));
}
