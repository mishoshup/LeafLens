import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leaflens/app.dart';
import 'package:leaflens/core/config/app_config.dart';
import 'package:leaflens/shared/auth/leaf_lens_auth.dart';
import 'package:leaflens/shared/notifications/leaf_lens_notification_overlay.dart';
import 'package:leaflens/shared/notifications/notification_service.dart';
import 'package:leaflens/theme/app_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// LeafLens application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initSentry();
  await _initSupabase();

  NotificationService.init(rootNavigatorKey);

  FlutterError.onError = (details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
      return;
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error');
    return true;
  };

  await Hive.initFlutter();
  await Hive.openBox<Map<String, dynamic>>(AppConfig.telemetryCacheBox);

  runApp(
    const ProviderScope(
      child: LeafLensApp(),
    ),
  );
}

Future<void> _initSentry() async {
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

Future<void> _initSupabase() async {
  const url = AppConfig.supabaseUrl;
  const anonKey = AppConfig.supabaseAnonKey;
  if (url.isEmpty || anonKey.isEmpty) {
    debugPrint('[Supabase] URL or anon key empty — skipping initialisation.');
    return;
  }

  await LeafLensAuth.init(url: url, anonKey: anonKey);
}

/// Root MaterialApp widget for LeafLens.
///
/// Uses the GoRouter for navigation and the [AppTheme.light] theme.
class LeafLensApp extends ConsumerWidget {
  /// Creates a [LeafLensApp] widget.
  const LeafLensApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return LeafLensNotificationOverlay(
      child: MaterialApp.router(
        title: 'LeafLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}
