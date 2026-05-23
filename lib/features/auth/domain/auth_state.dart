sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String token;
  final String email;
  const AuthAuthenticated({required this.token, required this.email});
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}
