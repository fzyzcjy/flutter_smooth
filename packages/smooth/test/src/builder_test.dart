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

      final testBeginTime = binding.clock.now();

      final capturer = WindowRenderCapturer();
      binding.onWindowRender = capturer.onWindowRender;

      // TODO remove?
      // final mainPreemptPointDebugToken = Object();
      // ServiceLocator.debugOverrideInstance = ServiceLocator.normal().copyWith(
      //   preemptStrategy: PreemptStrategyTest(
      //     shouldAct: ({debugToken}) => debugToken == mainPreemptPointDebugToken,
      //     currentSmoothFrameTimeStamp: () => TODO,
      //   ),
      // );

      const red = Color.fromARGB(255, 255, 0, 0);

      await tester.pumpWidget(Stack(
        children: [
          SmoothBuilder(
            builder: (context, child) => SimpleAnimatedBuilder(
              duration: kOneFrame * 10,
              builder: (_, animationValue) {
                debugPrint(
                    'SimpleAnimatedBuilder.builder animationValue=$animationValue');
                return Stack(
                  children: [
                    child,
                    Positioned(
                      left: 50,
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: ColoredBox(
                        color: _green(animationValue),
                      ),
                    ),
                  ],
                );
              },
            ),
            child: Container(color: red),
          ),
          Builder(builder: (_) {
            // 16ms - sufficiently near but less than 1/60s
            binding.elapseBlocking(const Duration(milliseconds: 16));
            return Container();
          }),
          LayoutPreemptPointWidget(
            // debugToken: mainPreemptPointDebugToken,
            child: Container(),
          ),
        ],
      ));

      await expectLater(
        capturer.images,
        [
          matchesReferenceImage(await createScreenImage(
              tester, (im) => im.fillLeftRight(red, _green(0)))),
        ],
      );

      capturer.images.clear();

      final pumpDuration =
          testBeginTime.add(kOneFrame).difference(binding.clock.now());
      expect(pumpDuration, kOneFrame - const Duration(milliseconds: 16));

      // Need one plain-old frame (the pumpWidget frame), before being able to
      // create smooth extra frames. Otherwise, the layer tree is event not
      // built yet (because paint is not called yet).
      await tester.pump(pumpDuration);

      await expectLater(
        capturer.images,
        [
          matchesReferenceImage(await createScreenImage(
              tester, (im) => im.fillLeftRight(red, _green(0.1)))),
          matchesReferenceImage(await createScreenImage(
              tester, (im) => im.fillLeftRight(red, _green(0.2)))),
        ],
      );
    });
  });
}

Color _green(double value) => Color.fromARGB(255, 0, (255 * value).round(), 0);
