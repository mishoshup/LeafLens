import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaflens/app.dart';
import 'package:leaflens/core/init/app_init.dart';

/// LeafLens application entry point.
///
/// Initialises services then hands off to [LeafLensApp].
Future<void> main() async {
  await initApp();
  _runApp();
}

void _runApp() {
  runApp(
    const ProviderScope(
      child: LeafLensApp(),
    ),
  );
}
