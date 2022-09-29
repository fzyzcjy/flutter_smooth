import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  group('SmoothSchedulerBindingMixin', () {
    testWidgets('beginFrameDateTime', (tester) async {
      // very naive test, because clock has not even run for a millisecond
      // during this whole test!
      final expectBeginFrameDateTime = clock.now();
      await tester.pumpWidget(SmoothScope(child: Container()));
      expect(binding.beginFrameDateTime, expectBeginFrameDateTime);
    });
  });
}
