import 'dart:ui' as ui;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/binding.dart';
import 'package:smooth/src/preempt_point.dart';
import 'package:smooth/src/preempt_strategy.dart';
import 'package:smooth/src/service_locator.dart';

import 'test_tools/animation.dart';
import 'test_tools/binding.dart';
import 'test_tools/image.dart';
import 'test_tools/time_info.dart';
import 'test_tools/widgets.dart';
import 'test_tools/window.dart';
import 'test_tools/window_render_capturer.dart';

void main() {
  SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  group('SmoothBuilder', () {
    group('use never PreemptStrategy.never', () {
      testWidgets('when pump widgets unrelated to smooth, should build',
          (tester) async {
        await tester.pumpWidget(SmoothScope(
          serviceLocator: ServiceLocator.normal()
              .copyWith(preemptStrategy: const PreemptStrategy.never()),
          child: Container(),
        ));

        // should have no error
      });

      testWidgets('when use SmoothBuilder, should build', (tester) async {
        await tester.pumpWidget(SmoothScope(
          serviceLocator: ServiceLocator.normal()
              .copyWith(preemptStrategy: const PreemptStrategy.never()),
          child: SmoothBuilder(
            builder: (context, child) => child,
            child: Container(),
          ),
        ));

        // should have no error
      });
    });

    group('render output test', () {
      final binding = SmoothAutomatedTestWidgetsFlutterBinding.instance;
      binding.window.setUpTearDown(
        physicalSizeTestValue: const Size(100, 50),
        devicePixelRatioTestValue: 1,
      );

      testWidgets('when one extra smooth frame', (tester) async {
        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
        final timeInfo = TimeInfo();
        final capturer = WindowRenderCapturer.autoRegister();

        var slowWorkDuration = Duration.zero;

        debugPrint('pumpWidget');
        await tester.pumpWidget(SmoothScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                const _SmoothBuilderTester(),
                AlwaysBuildBuilder(onBuild: () {
                  debugPrint(
                      'first slow builder elapseBlocking for $slowWorkDuration '
                      '(p.s. currentFrameTimeStamp=${SchedulerBinding.instance.currentFrameTimeStamp})');
                  binding.elapseBlocking(slowWorkDuration);
                }),
                LayoutPreemptPointWidget(
                  // debugToken: mainPreemptPointDebugToken,
                  child: AlwaysLayoutBuilder(
                    child: Container(),
                  ),
                ),
                // https://github.com/fzyzcjy/flutter_smooth/issues/23#issuecomment-1261674207
                AlwaysLayoutBuilder(onPerformLayout: () {
                  debugPrint(
                      'second slow layout elapseBlocking for $slowWorkDuration '
                      '(p.s. currentFrameTimeStamp=${SchedulerBinding.instance.currentFrameTimeStamp})');
                  binding.elapseBlocking(slowWorkDuration);
                }),
              ],
            ),
          ),
        ));

        await capturer.expectAndReset(tester, [
          await _SmoothBuilderTester.createExpectImage(tester, 0),
        ]);

        // 15.5ms - sufficiently near but less than 1/60s
        slowWorkDuration = const Duration(microseconds: 15500);

        // Need one plain-old frame (the pumpWidget frame), before being able to
        // create smooth extra frames. Otherwise, the layer tree is event not
        // built yet (because paint is not called yet).
        debugPrint('action: pump now=${clock.now()}');
        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));

        await capturer.expectAndReset(tester, [
          await _SmoothBuilderTester.createExpectImage(tester, 0.1),
          await _SmoothBuilderTester.createExpectImage(tester, 0.2),
        ]);

        // #60
        debugPrint('action: pump again now=${clock.now()}');
        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 3));

        await capturer.expectAndReset(tester, [
          await _SmoothBuilderTester.createExpectImage(tester, 0.3),
          await _SmoothBuilderTester.createExpectImage(tester, 0.4),
        ]);

        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
      });
    });
  });
}

class _SmoothBuilderTester extends StatelessWidget {
  const _SmoothBuilderTester();

  static Future<ui.Image> createExpectImage(
          WidgetTester tester, double animationValue) =>
      tester.createScreenImage(
          (im) => im.fillLeftRight(_red, _green(animationValue)));

  static const _red = Color.fromARGB(255, 255, 0, 0);

  static Color _green(double value) =>
      Color.fromARGB(255, 0, (255 * value).round(), 0);

  @override
  Widget build(BuildContext context) {
    return SmoothBuilder(
      builder: (context, child) => SimpleAnimatedBuilder(
        duration: kOneFrame * 10,
        builder: (_, animationValue) {
          debugPrint(
              'SimpleAnimatedBuilder.builder animationValue=$animationValue');
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
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
            ),
          );
        },
      ),
      child: Container(color: _red),
    );
  }
}
