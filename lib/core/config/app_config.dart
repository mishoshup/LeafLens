/// Application-wide configuration values.
///
/// All secrets are injected at build time via `--dart-define-from-file`.
/// Never hardcode API keys or URLs here — use `.env` locally and CI
/// environment variables in production.
///
/// ## Setup
///
/// Copy `.env.example` to `.env` and fill in your values:
/// ```bash
/// cp .env.example .env
/// ```
///
/// Pass to Flutter:
/// ```bash
/// flutter run --dart-define-from-file=.env
/// flutter build apk --dart-define-from-file=.env
/// ```
class AppConfig {
  AppConfig._();

  /// FastAPI backend base URL (no trailing slash).
  static const String apiUrl = String.fromEnvironment('API_URL');

  /// FastAPI WebSocket URL.
  static const String wsUrl = String.fromEnvironment('WS_URL');

  /// Supabase project URL.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anon/public key.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Hive box for offline cache.
  static const String telemetryCacheBox = 'telemetry_cache';

  /// Data older than this shows a stale indicator.
  static const Duration staleThreshold = Duration(minutes: 30);
}
