import 'package:flutter_test/flutter_test.dart';
import 'package:leaflens/main.dart';

void main() {
  testWidgets('LeafLens app renders login page', (WidgetTester tester) async {
    await tester.pumpWidget(const LeafLensApp());

    // Verify key elements are present
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}
