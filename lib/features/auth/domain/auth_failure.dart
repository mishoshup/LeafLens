/// Base class for authentication-specific failures.
/// Sealed so all auth error types are known at compile time.
sealed class AuthFailure {
  const AuthFailure();
}

/// User entered an incorrect email or password combination.
class WrongCredentials extends AuthFailure {
  /// Creates a [WrongCredentials] failure.
  const WrongCredentials();
}

/// Network error occurred during the authentication request.
class AuthNetworkError extends AuthFailure {
  /// Creates an [AuthNetworkError] failure.
  const AuthNetworkError();
}
