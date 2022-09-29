import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  testWidgets('createScreenImage', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.setUpTearDown(
        physicalSizeTestValue: const Size(100, 50),
        devicePixelRatioTestValue: 1);

    final im = await tester.createScreenImage(
      (im) => im
        ..fillRect(const Rectangle(0, 0, 50, 50), Colors.red)
        ..fillRect(const Rectangle(50, 0, 50, 50), Colors.green),
    );

    expect(im, matchesGoldenFile('../goldens/image/simple.png'));
  });
}
