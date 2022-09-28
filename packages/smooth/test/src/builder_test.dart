import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/preempt_point.dart';
import 'package:smooth/src/preempt_strategy.dart';
import 'package:smooth/src/scheduler_binding.dart';
import 'package:smooth/src/service_locator.dart';

import 'test_tools/animation.dart';
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

      final mainPreemptPointDebugToken = Object();

      final capturer = WindowRenderCapturer();
      binding.onWindowRender = capturer.onWindowRender;

      ServiceLocator.debugOverrideInstance = ServiceLocator.normal().copyWith(
        preemptStrategy: PreemptStrategyTest(
          shouldAct: ({debugToken}) => debugToken == mainPreemptPointDebugToken,
          currentSmoothFrameTimeStamp: () => TODO,
        ),
      );

      await tester.pumpWidget(Stack(
        children: [
          SmoothBuilder(
            builder: (context, child) => SimpleAnimatedBuilder(
              duration: kOneFrame * 10,
              builder: (_, animationValue) {
                debugPrint(
                    'SimpleAnimatedBuilder.builder animationValue=$animationValue');
                return TODO;
              },
            ),
            child: Container(color: Colors.red),
          ),
          LayoutPreemptPointWidget(
            debugToken: mainPreemptPointDebugToken,
            child: Container(),
          ),
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
