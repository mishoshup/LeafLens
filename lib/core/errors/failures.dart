/// Base class for all application failures.
sealed class Failure implements Exception {
  const Failure();
}

/// Represents a networking failure (no internet, DNS, timeout).
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure();
}

/// FastAPI returned a non-2xx.
class ApiFailure extends Failure {
  /// Creates an [ApiFailure] with the given HTTP [statusCode]
  /// and response [body].
  const ApiFailure(this.statusCode, this.body);

  /// The HTTP status code from the failed response.
  final int statusCode;

  /// The raw response body from the failed request.
  final String body;
}

/// User JWT expired or invalid.
class SessionExpiredFailure extends Failure {
  /// Creates a [SessionExpiredFailure].
  const SessionExpiredFailure();
}

/// Wrong email or password provided during login.
class InvalidCredentialsFailure extends Failure {
  /// Creates an [InvalidCredentialsFailure].
  const InvalidCredentialsFailure();
}

/// A non-Failure exception was caught and wrapped.
class UnknownFailure extends Failure {
  /// Creates an [UnknownFailure] wrapping the original [message].
  const UnknownFailure(this.message);

  /// The original exception message.
  final String message;
}
