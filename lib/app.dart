import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaflens/core/router/app_router.dart';
import 'package:leaflens/core/theme/app_colors.dart';
import 'package:leaflens/core/theme/app_theme.dart';
import 'package:leaflens/shared/notifications/leaf_lens_notification_overlay.dart';

/// Root application widget for LeafLens.
///
/// Provides theming, routing, and notification overlay.
class LeafLensApp extends ConsumerWidget {
  /// Creates a [LeafLensApp] widget.
  const LeafLensApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(AppRouter.provider);

    return LeafLensNotificationOverlay(
      child: MaterialApp.router(
        title: 'LeafLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        color: AppColors.lightGreenBg,
        routerConfig: router,
      ),
    );
  }
}
