/// Sealed base class for all authentication UI states.
/// Each subclass represents a distinct phase of the auth lifecycle.
sealed class AuthState {
  const AuthState();
}

/// Initial state before any auth check has been performed.
class AuthInitial extends AuthState {
  /// Creates an [AuthInitial] state.
  const AuthInitial();
}

/// Auth check or login/signup request is in progress.
class AuthLoading extends AuthState {
  /// Creates an [AuthLoading] state.
  const AuthLoading();
}

/// User is authenticated with a valid token and email.
class AuthAuthenticated extends AuthState {
  /// Creates an [AuthAuthenticated] state with the given [token] and [email].
  const AuthAuthenticated({required this.token, required this.email});

  /// The user's JWT token for authenticated API requests.
  final String token;

  /// The authenticated user's email address.
  final String email;
}

/// Authentication attempt failed with an error [message].
class AuthFailure extends AuthState {
  /// Creates an [AuthFailure] with the given error [message].
  const AuthFailure(this.message);

  /// Human-readable description of what went wrong.
  final String message;
}
