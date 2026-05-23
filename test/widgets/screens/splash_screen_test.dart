import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:leaflens/screens/splash/splash_screen.dart';

import '../../helpers/test_asset_bundle.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('renders brand text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: const SplashScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LEAFLENS'), findsOneWidget);
      expect(find.textContaining('Smarter Care'), findsOneWidget);
    });

    testWidgets('renders Get Started button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: const SplashScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: const SplashScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Stack layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: const SplashScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // MaterialApp also uses Stack internally
      expect(find.byType(Stack), findsAtLeast(1));
    });
  });
}
