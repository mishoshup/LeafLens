import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leaflens/core/config/app_config.dart';
import 'package:leaflens/core/init/leaf_lens_auth_init.dart';
import 'package:leaflens/core/init/sentry_init.dart';
import 'package:leaflens/core/router/app_router.dart';
import 'package:leaflens/shared/notifications/notification_service.dart';

/// Orchestrates all app initialisation in the correct order.
///
/// Binding → error handlers → services → storage. Each step is isolated
/// so the startup sequence reads like a table of contents.
Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initErrorHandlers();
  await _initSentry();
  await _initAuth();
  _initNotifications();
  await _initStorage();
}

/// Registers global error handlers before any async work begins.
void _initErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error');
    return true;
  };
}

/// Initialises Sentry error tracking from build-time SENTRY_DSN.
Future<void> _initSentry() => initSentry();

/// Initialises Supabase client with AppConfig credentials.
Future<void> _initAuth() => initLeafLensAuth();

/// Wires NotificationService to the root navigator key.
void _initNotifications() {
  NotificationService.init(AppRouter.rootNavigatorKey);
}

/// Initialises Hive for local caching.
Future<void> _initStorage() async {
  await Hive.initFlutter();
  await Hive.openBox<Map<String, dynamic>>(AppConfig.telemetryCacheBox);
}
