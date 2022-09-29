import 'dart:ui' as ui;

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

      group('single preempt point', () {
        Future<void> _body(
          WidgetTester tester, {
          required Duration slowWorkBeforePreemptPoint,
          required Duration slowWorkAfterPreemptPoint,
          required Future<void> Function(WindowRenderCapturer, TimeInfo) core,
        }) async {
          debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
          final timeInfo = TimeInfo();
          final capturer = WindowRenderCapturer.autoRegister();

          var enableSlowWork = false;

          // Need one plain-old frame (the pumpWidget frame), before being able to
          // create smooth extra frames. Otherwise, the layer tree is event not
          // built yet (because paint is not called yet).
          debugPrint('pumpWidget');
          await tester.pumpWidget(SmoothScope(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Stack(
                children: [
                  const _SmoothBuilderTester(),
                  AlwaysLayoutBuilder(
                    onPerformLayout: () => enableSlowWork
                        ? binding.elapseBlocking(slowWorkBeforePreemptPoint,
                            reason: 'slowWorkBeforePreemptPoint')
                        : null,
                  ),
                  const LayoutPreemptPointWidget(child: AlwaysLayoutBuilder()),
                  // https://github.com/fzyzcjy/flutter_smooth/issues/23#issuecomment-1261674207
                  AlwaysLayoutBuilder(
                    onPerformLayout: () => enableSlowWork
                        ? binding.elapseBlocking(slowWorkAfterPreemptPoint,
                            reason: 'slowWorkAfterPreemptPoint')
                        : null,
                  ),
                ],
              ),
            ),
          ));

          await capturer.expectAndReset(tester, [
            await _SmoothBuilderTester.createExpectImage(tester, 0),
          ]);

          enableSlowWork = true;

          await core(capturer, timeInfo);

          debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
        }

        testWidgets('when zero extra frame per plain-old frame',
            (tester) async {
          await _body(
            tester,
            slowWorkBeforePreemptPoint: const Duration(microseconds: 7900),
            slowWorkAfterPreemptPoint: const Duration(microseconds: 7900),
            core: (capturer, timeInfo) async {
              for (var i = 1; i <= 5; ++i) {
                await tester
                    .pump(timeInfo.calcPumpDuration(smoothFrameIndex: i));
                await capturer.expectAndReset(tester, [
                  await _SmoothBuilderTester.createExpectImage(tester, 0.2 * i),
                ]);
              }

              await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 6));
              await capturer.expectAndReset(tester, [
                await _SmoothBuilderTester.createExpectImage(tester, 1.0),
              ]);
            },
          );
        });

        testWidgets('when one extra frame per plain-old frame', (tester) async {
          await _body(
            tester,
            // sufficiently near but less than 1/60s
            slowWorkBeforePreemptPoint: const Duration(microseconds: 15500),
            slowWorkAfterPreemptPoint: const Duration(microseconds: 15500),
            core: (capturer, timeInfo) async {
              await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));

              await capturer.expectAndReset(tester, [
                await _SmoothBuilderTester.createExpectImage(tester, 0.2),
                await _SmoothBuilderTester.createExpectImage(tester, 0.4),
              ]);

              await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 3));

              await capturer.expectAndReset(tester, [
                await _SmoothBuilderTester.createExpectImage(tester, 0.6),
                await _SmoothBuilderTester.createExpectImage(tester, 0.8),
              ]);

              await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 5));

              await capturer.expectAndReset(tester, [
                await _SmoothBuilderTester.createExpectImage(tester, 1.0),
                // TODO maybe we can remove this redundant output?
                await _SmoothBuilderTester.createExpectImage(tester, 1.0),
              ]);
            },
          );
        });
      });

      testWidgets('preempt multiple times in one frame', (tester) async {
        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
        final timeInfo = TimeInfo();
        final capturer = WindowRenderCapturer.autoRegister();

        var enableSlowWork = false;

        debugPrint('pumpWidget');
        await tester.pumpWidget(SmoothScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                const _SmoothBuilderTester(),
                for (var i = 0; i < 10; ++i) ...[
                  AlwaysLayoutBuilder(
                    onPerformLayout: () => enableSlowWork
                        // less than but near 16.666ms
                        ? binding
                            .elapseBlocking(const Duration(microseconds: 16500))
                        : null,
                  ),
                  const LayoutPreemptPointWidget(child: AlwaysLayoutBuilder()),
                ],
              ],
            ),
          ),
        ));

        await capturer.expectAndReset(tester, [
          await _SmoothBuilderTester.createExpectImage(tester, 0),
        ]);

        enableSlowWork = true;

        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));

        await capturer.expectAndReset(tester, [
          await _SmoothBuilderTester.createExpectImage(tester, 0.2),
          await _SmoothBuilderTester.createExpectImage(tester, 0.4),
          await _SmoothBuilderTester.createExpectImage(tester, 0.6),
          await _SmoothBuilderTester.createExpectImage(tester, 0.8),
          for (var i = 0; i < 7; ++i)
            await _SmoothBuilderTester.createExpectImage(tester, 1),
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
        duration: kOneFrame * 5,
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
