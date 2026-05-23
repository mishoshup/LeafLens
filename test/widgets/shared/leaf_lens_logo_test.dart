import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:leaflens/shared/widgets/leaf_lens_logo.dart';

import '../../helpers/test_asset_bundle.dart';

void main() {
  group('LeafLensLogo', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: const Scaffold(body: LeafLensLogo()),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
