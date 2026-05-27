import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leaflens/core/router/auth_guard.dart';
import 'package:leaflens/features/auth/data/leaf_lens_auth.dart';
import 'package:leaflens/features/auth/presentation/login_page.dart';
import 'package:leaflens/features/auth/presentation/signup_page.dart';
import 'package:leaflens/features/dashboard/data/dashboard_providers.dart';
import 'package:leaflens/features/dashboard/presentation/dashboard_screen.dart';
import 'package:leaflens/features/splash/presentation/splash_screen.dart';

/// Centralised GoRouter configuration for LeafLens.
///
/// Wraps all routing logic in one place. Screens never import GoRouter
/// directly — they use GoRouterHelper extensions from context instead.
class AppRouter {
  const AppRouter._();

  /// Root navigator key shared with NotificationService.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  /// GoRouter provider wired to auth state.
  static final provider = Provider<GoRouter>((ref) {
    final auth = ref.watch(authStateProvider);

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/splash',
      redirect: (context, state) {
        final isLoggedIn = auth.value != null;
        // LeafLensAuth.accessToken is available synchronously
        // on cold start (Supabase restores session from secure
        // storage before the stream emits).
        return AuthGuard.call(
          state: state,
          isLoggedIn: isLoggedIn,
          currentToken: LeafLensAuth.accessToken,
        );
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, _) => const SignUpPage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => const DashboardScreen(),
        ),
      ],
    );
  });
}
