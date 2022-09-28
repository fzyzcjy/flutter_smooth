import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/preempt_strategy.dart';
import 'package:smooth/src/service_locator.dart';

import 'test_tools/binding.dart';
import 'test_tools/image.dart';
import 'test_tools/preemtp_strategy.dart';
import 'test_tools/window.dart';

void main() {
  group('SmoothBuilder', () {
    testWidgets('when pump widgets unrelated to smooth, should build',
        (tester) async {
      ServiceLocator.debugOverrideInstance = ServiceLocator.normal()
          .copyWith(preemptStrategy: const PreemptStrategy.never());

      await tester.pumpWidget(Container());

      // should have no error
    });

    testWidgets('when use SmoothBuilder with simplest case, should build',
        (tester) async {
      ServiceLocator.debugOverrideInstance = ServiceLocator.normal()
          .copyWith(preemptStrategy: const PreemptStrategy.never());

      await tester.pumpWidget(SmoothBuilder(
        builder: (context, child) => child,
        child: Container(),
      ));

      // should have no error
    });

    testWidgets('when one extra smooth frame', (tester) async {
      final binding = SmoothAutomatedTestWidgetsFlutterBinding.instance;
      binding.window.setUpTearDown(
        physicalSizeTestValue: const Size(100, 50),
        devicePixelRatioTestValue: 1,
      );

      final capturer = WindowRenderCapturer();
      binding.onWindowRender = capturer.onWindowRender;

      ServiceLocator.debugOverrideInstance = ServiceLocator.normal().copyWith(
        preemptStrategy: PreemptStrategyTest(
          shouldAct: shouldAct,
          currentSmoothFrameTimeStamp: currentSmoothFrameTimeStamp,
        ),
      );

      await tester.pumpWidget(Stack(
        children: [
          SmoothBuilder(
            builder: (context, child) {
              TODO; // TODO be different colors for different times? frames?
              return child;
            },
            child: Container(color: Colors.red),
          ),
          SmoothPreemptPoint(child: Container()),
        ],
      ));

      expect(
        capturer.images,
        [
          matchesReferenceImage(await createScreenImage(
              tester, (im) => im.fillAll(Colors.green))),
          matchesReferenceImage(
              await createScreenImage(tester, (im) => im.fillAll(Colors.red))),
        ],
      );
    });
  });
}
