import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leaflens/features/dashboard/data/dashboard_providers.dart';
import 'package:leaflens/screens/login/login_page.dart';
import 'package:leaflens/screens/signup/signup_page.dart';
import 'package:leaflens/screens/splash/splash_screen.dart';

/// Placeholder dashboard screen shown after login.
/// Will be replaced with the full dashboard implementation in a future build.
class DashboardScreen extends ConsumerWidget {
  /// Creates a [DashboardScreen] widget.
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dashboard will consume dashboardStreamProvider here.
    return Scaffold(
      appBar: AppBar(title: const Text('LeafLens')),
      body: const Center(child: Text('Dashboard — next build')),
    );
  }
}

/// Provides the [GoRouter] instance for app navigation.
/// Checks authentication state on every route transition and redirects
/// unauthenticated users to /login and authenticated users away from /login.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = auth.value != null;
      final path = state.matchedLocation;

      if (path == '/splash') return null;
      if (!isLoggedIn && path != '/login' && path != '/signup') return '/login';
      if (isLoggedIn && (path == '/login' || path == '/signup')) {
        return '/dashboard';
      }
      return null;
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
