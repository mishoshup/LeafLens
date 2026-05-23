import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:leaflens/app.dart';
import 'package:leaflens/core/config/app_config.dart';
import 'package:leaflens/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class LeafLensApp extends ConsumerWidget {
  const LeafLensApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'LeafLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
