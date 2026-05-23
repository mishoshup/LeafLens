sealed class AuthFailure {
  const AuthFailure();
}

class WrongCredentials extends AuthFailure {
  const WrongCredentials();
}

class AuthNetworkError extends AuthFailure {
  const AuthNetworkError();
}
