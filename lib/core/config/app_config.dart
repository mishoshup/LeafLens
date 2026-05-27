/// Application-wide configuration values.
class AppConfig {
  AppConfig._();

  /// FastAPI backend base URL (no trailing slash).
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// FastAPI WebSocket URL.
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://localhost:8000/ws',
  );

  /// Supabase project URL.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://localhost:54321',
  );

  /// Supabase anon/public key.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Hive box for offline cache.
  static const String telemetryCacheBox = 'telemetry_cache';

  /// Data older than this shows a stale indicator.
  static const Duration staleThreshold = Duration(minutes: 30);
}
