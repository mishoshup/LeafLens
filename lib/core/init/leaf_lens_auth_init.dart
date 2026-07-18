import 'package:flutter/foundation.dart';
import 'package:leaflens/core/config/app_config.dart';
import 'package:leaflens/features/auth/data/leaf_lens_auth.dart';

/// Initialises Supabase client with [AppConfig] credentials.
///
/// Skips silently if URL or anon key is empty (local dev).
Future<void> initLeafLensAuth() async {
  const url = AppConfig.supabaseUrl;
  const anonKey = AppConfig.supabaseAnonKey;
  if (url.isEmpty || anonKey.isEmpty) {
    debugPrint('[Supabase] URL or anon key empty — skipping initialisation.');
    return;
  }

  await LeafLensAuth.init(url: url, publishableKey: anonKey);
}
