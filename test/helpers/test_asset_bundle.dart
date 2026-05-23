import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Minimal SVG returner for SVG-dependent widget tests.
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final svg = utf8.encode(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"/>',
    );
    return ByteData.view(Uint8List.fromList(svg).buffer);
  }
}
