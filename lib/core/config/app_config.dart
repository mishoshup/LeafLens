class AppConfig {
  AppConfig._();

  /// FastAPI backend base URL (no trailing slash).
  /// Override via --dart-define=API_URL=... at build time.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// FastAPI WebSocket URL.
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://localhost:8000/ws',
  );

  /// Hive box for offline cache.
  static const String telemetryCacheBox = 'telemetry_cache';

  /// Data older than this shows a stale indicator.
  static const Duration staleThreshold = Duration(minutes: 30);
}
