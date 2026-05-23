sealed class Failure {
  const Failure();
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// FastAPI returned a non-2xx.
class ApiFailure extends Failure {
  final int statusCode;
  final String body;
  const ApiFailure(this.statusCode, this.body);
}

/// User JWT expired or invalid.
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure();
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();
}
