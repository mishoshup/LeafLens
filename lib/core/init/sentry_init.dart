import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Initialises Sentry error tracking from build-time SENTRY_DSN.
///
/// Skips silently if no DSN is configured (local dev).
Future<void> initSentry() async {
  const dsn = String.fromEnvironment('SENTRY_DSN');
  if (dsn.isEmpty) {
    debugPrint('[Sentry] No DSN configured — skipping initialisation.');
    return;
  }

  await SentryFlutter.init(
    (options) => options
      ..dsn = dsn
      ..tracesSampleRate = 0.2,
    appRunner: () {},
  );
}
