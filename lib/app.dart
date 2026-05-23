import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:leaflens/features/dashboard/data/dashboard_providers.dart';
import 'package:leaflens/screens/signup/signup_page.dart';
import 'package:leaflens/screens/splash/splash_screen.dart';
import 'package:leaflens/screens/login/login_page.dart';

class DashboardScreen extends ConsumerWidget {
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

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = auth.value != null;
      final path = state.matchedLocation;

      if (path == '/splash') return null;
      if (!isLoggedIn && path != '/login' && path != '/signup') return '/login';
      if (isLoggedIn && (path == '/login' || path == '/signup')) return '/dashboard';
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
