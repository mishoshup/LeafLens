import 'package:leaflens/core/errors/failures.dart';
import 'package:leaflens/core/network/api_client.dart';
import 'package:leaflens/shared/auth/leaf_lens_auth.dart';
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
  /// Throws [InvalidCredentialsFailure] on wrong credentials.
  Future<void> login(String email, String password) async {
    try {
      final token = await LeafLensAuth.signInWithPassword(
        email: email,
        password: password,
      );
      _api.token = token;
    } on Exception {
      throw const InvalidCredentialsFailure();
    }
  }

  /// Register a new account.
  Future<void> register(String email, String password) async {
    try {
      final token = await LeafLensAuth.signUp(
        email: email,
        password: password,
      );
      _api.token = token;
    } on Exception {
      throw const InvalidCredentialsFailure();
    }
  }

  /// Logout — clears the Supabase session and API token.
  Future<void> logout() async {
    await LeafLensAuth.signOut();
    _api.token = null;
  }
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
