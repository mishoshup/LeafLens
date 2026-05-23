import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:leaflens/core/network/api_client.dart';
import 'package:leaflens/features/auth/data/login_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Repository for LeafLens user auth against FastAPI backend.
class AuthRepository {
  /// Creates an [AuthRepository] backed by the given [ApiClient].
  AuthRepository(this._api);
  final ApiClient _api;
  static const _tokenKey = 'user_jwt';

  /// Try restoring a saved session from the secure keychain.
  Future<String?> tryRestore() async {
    try {
      return await FlutterKeychain.get(key: _tokenKey);
    } on Exception catch (_) {
      return null;
    }
  }

  /// Login with email/password. Returns JWT on success.
  Future<String> login(String email, String password) async {
    final response = await _api.postPublic(
      '/api/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    final loginResponse = LoginResponse.fromJson(response);
    await FlutterKeychain.put(key: _tokenKey, value: loginResponse.token);
    _api.token = loginResponse.token;
    return loginResponse.token;
  }

  /// Register a new account. Returns JWT on success.
  Future<String> register(String email, String password) async {
    final response = await _api.postPublic(
      '/api/auth/register',
      body: {
        'email': email,
        'password': password,
      },
    );
    final loginResponse = LoginResponse.fromJson(response);
    await FlutterKeychain.put(key: _tokenKey, value: loginResponse.token);
    _api.token = loginResponse.token;
    return loginResponse.token;
  }

  /// Clear stored session (logout).
  Future<void> logout() async {
    await FlutterKeychain.remove(key: _tokenKey);
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
