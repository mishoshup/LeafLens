import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaflens/shared/notifications/leaf_lens_notification_overlay.dart';
import 'package:toastification/toastification.dart';

void main() {
  group('LeafLensNotificationOverlay', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LeafLensNotificationOverlay(
            child: Scaffold(
              body: Text('Hello LeafLens'),
            ),
          ),
        ),
      );

      expect(find.text('Hello LeafLens'), findsOneWidget);
    });

    testWidgets('wraps child with ToastificationWrapper', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LeafLensNotificationOverlay(
            child: Scaffold(
              body: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(ToastificationWrapper), findsOneWidget);
    });

    testWidgets('child is inside ToastificationWrapper', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LeafLensNotificationOverlay(
            child: Scaffold(
              body: Text('Nested'),
            ),
          ),
        ),
      );

      final wrapper = tester.widget<ToastificationWrapper>(
        find.byType(ToastificationWrapper),
      );
      expect(wrapper.child, isA<Scaffold>());
    });
  });
}
