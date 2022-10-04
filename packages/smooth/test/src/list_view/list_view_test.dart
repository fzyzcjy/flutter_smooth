import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  group('SmoothListView', () {
    binding.window.setUpTearDown(
      physicalSizeTestValue: const Size(50, 100),
      devicePixelRatioTestValue: 1,
    );

    for (final smooth in [false, true]) {
      group('simplest construction', () {
        testWidgets(smooth ? 'smooth' : 'plain', (tester) async {
          final capturer = WindowRenderCapturer.autoDispose();

          await tester.pumpWidget(SmoothScope(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SmoothListView.maybeBuilder(
                smooth: smooth,
                itemCount: 100,
                itemBuilder: (_, index) => Container(
                  height: 60,
                  color: Colors.primaries[index],
                ),
              ),
            ),
          ));

          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
            await tester.createScreenImage((im) => im
              ..fillRect(const Rectangle(0, 0, 50, 60), Colors.primaries[0])
              ..fillRect(const Rectangle(0, 60, 50, 40), Colors.primaries[1])),
          ]);
        });
      });
    }
  });
}
