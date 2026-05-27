import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder dashboard screen shown after login.
/// Will be replaced with the full dashboard implementation in a future build.
class DashboardScreen extends ConsumerWidget {
  /// Creates a [DashboardScreen] widget.
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('LeafLens')),
      body: const Center(child: Text('Dashboard — next build')),
    );
  }
}
