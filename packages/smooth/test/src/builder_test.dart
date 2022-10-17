import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth_dev/smooth_dev.dart';

import 'test_tools/animation.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  group('SmoothBuilder', () {
    // TODO
    // group('use never PreemptStrategy.never', () {
    //   testWidgets('when pump widgets unrelated to smooth, should build',
    //       (tester) async {
    //     await tester.pumpWidget(SmoothScope(
    //       serviceLocator: ServiceLocator.normal()
    //           .copyWith(preemptStrategy: const PreemptStrategy.never()),
    //       child: Container(),
    //     ));
    //
    //     // should have no error
    //   });
    //
    //   testWidgets('when use SmoothBuilder, should build', (tester) async {
    //     await tester.pumpWidget(SmoothScope(
    //       serviceLocator: ServiceLocator.normal()
    //           .copyWith(preemptStrategy: const PreemptStrategy.never()),
    //       child: SmoothBuilder(
    //         builder: (context, child) => child,
    //         child: Container(),
    //       ),
    //     ));
    //
    //     // should have no error
    //   });
    // });

    group('render output test', () {
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
          final capturer = WindowRenderCapturer.autoDispose();

          var enableSlowWork = false;

          // Need one plain-old frame (the pumpWidget frame), before being able to
          // create smooth extra frames. Otherwise, the layer tree is event not
          // built yet (because paint is not called yet).
          debugPrint('pumpWidget');
          await tester.pumpWidget(SmoothParent(
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
                  const SmoothLayoutPreemptPointWidget(
                      child: AlwaysLayoutBuilder()),
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

          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
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
                await capturer.expectAndReset(tester,
                    expectTestFrameNumber: i + 2,
                    expectImages: [
                      await _SmoothBuilderTester.createExpectImage(
                          tester, 0.2 * i),
                    ]);
              }

              await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 6));
              await capturer.expectAndReset(tester,
                  expectTestFrameNumber: 8,
                  expectImages: [
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

              await capturer.expectAndReset(tester,
                  expectTestFrameNumber: 3,
                  expectImages: [
                    await _SmoothBuilderTester.createExpectImage(tester, 0.2),
                    await _SmoothBuilderTester.createExpectImage(tester, 0.4),
                  ]);

              await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 3));

              await capturer.expectAndReset(tester,
                  expectTestFrameNumber: 4,
                  expectImages: [
                    await _SmoothBuilderTester.createExpectImage(tester, 0.6),
                    await _SmoothBuilderTester.createExpectImage(tester, 0.8),
                  ]);

              await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 5));

              await capturer.expectAndReset(tester,
                  expectTestFrameNumber: 5,
                  expectImages: [
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
        final capturer = WindowRenderCapturer.autoDispose();

        var enableSlowWork = false;

        debugPrint('pumpWidget');
        await tester.pumpWidget(SmoothParent(
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
                  const SmoothLayoutPreemptPointWidget(
                      child: AlwaysLayoutBuilder()),
                ],
              ],
            ),
          ),
        ));

        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
          await _SmoothBuilderTester.createExpectImage(tester, 0),
        ]);

        enableSlowWork = true;

        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));

        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
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

    group('randomized test', () {
      binding.window.setUpTearDown(
        physicalSizeTestValue: const Size(50, 200),
        devicePixelRatioTestValue: 1,
      );

      Future<void> _body(
        WidgetTester tester, {
        required int seed,
        required _AnimatingPart animatingPart,
      }) async {
        debugPrint(
            '${'=' * 30} Test seed=$seed animatingPart=$animatingPart ${'=' * 30}');
        final r = Random(seed);

        final mustWidgets = <Widget>[
          SmoothBuilder(
            builder: (context, child) => animatingPart == _AnimatingPart.auxTree
                ? SimpleAnimatedBuilder(
                    duration: const Duration(seconds: 1),
                    builder: (_, value) => ColoredBox(
                      color: Color.fromARGB(255, 0, (255 * value).round(), 0),
                      child: child,
                    ),
                  )
                : child,
            child: animatingPart == _AnimatingPart.mainTreeChild
                ? SimpleAnimatedBuilder(
                    duration: const Duration(seconds: 1),
                    builder: (_, value) => ColoredBox(
                      color: Color.fromARGB(255, 0, 0, (255 * value).round()),
                    ),
                  )
                : Container(color: Colors.blue),
          ),
        ];

        Duration randomBlockingDuration() {
          switch (r.nextInt(4)) {
            case 0:
              return Duration.zero;
            case 1:
              // short
              return Duration(microseconds: r.nextInt(2000));
            case 2:
              // medium
              return Duration(milliseconds: r.nextInt(16));
            case 3:
              // large
              return Duration(milliseconds: r.nextInt(30));
            default:
              throw UnimplementedError;
          }
        }

        final optionalWidgets = <Widget>[
          const AlwaysLayoutBuilder(),
          const AlwaysBuildBuilder(),
          AlwaysLayoutBuilder(onPerformLayout: () {
            binding.elapseBlocking(randomBlockingDuration());
          }),
          AlwaysBuildBuilder(onBuild: () {
            binding.elapseBlocking(randomBlockingDuration());
          }),
        ];

        final wrappers = <Widget Function(Widget)>[
          (child) => SmoothBuildPreemptPointWidget(child: child),
          (child) => SmoothLayoutPreemptPointWidget(child: child),
          // cause special behavior about painting
          (child) => RepaintBoundary(child: child),
          // cause special behavior about build/layout
          (child) => LayoutBuilder(builder: (_, __) => child),
          // quite normal widget
          (child) => Container(child: child),
        ];

        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
        final timeInfo = TimeInfo();
        final capturer = WindowRenderCapturer();

        final childWidget = ValueNotifier<Widget>(Container());

        debugPrint('action: pumpWidget');
        await tester.pumpWidget(SmoothParent(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ValueListenableBuilder<Widget>(
              valueListenable: childWidget,
              builder: (_, value, __) => value,
            ),
          ),
        ));

        for (var i = 0; i < 10; ++i) {
          final numChildren = 1 + r.nextInt(4);
          var children = <Widget>[
            ...mustWidgets,
            for (var i = 0; i < numChildren; ++i)
              optionalWidgets[r.nextInt(optionalWidgets.length)],
          ];
          children.shuffle(r);

          children = children.map((child) {
            final numWrappers = r.nextInt(3);
            var result = child;
            for (var i = 0; i < numWrappers; ++i) {
              result = wrappers[r.nextInt(wrappers.length)](result);
            }
            return result;
          }).toList();

          children = children
              .map((child) => SizedBox(height: 20, child: child))
              .toList();

          childWidget.value = Column(children: children);

          debugPrint('action: pump');
          await tester.pump(timeInfo.calcPumpDurationAuto());
        }

        debugPrint('action: verify');
        try {
          final lastScenePerFrameArr = (await tester.runAsync(() async {
            return await Future.wait(
                capturer.pack.imagesOfFrame.entries.map((entry) async {
              final image = entry.value.last;
              return await image.toBytes();
            }).toList());
          }))!;

          for (var i = 0; i < lastScenePerFrameArr.length - 1; ++i) {
            expect(
                lastScenePerFrameArr[i] != lastScenePerFrameArr[i + 1], true);
          }
        } on TestFailure catch (_) {
          await capturer.pack.dumpAll(tester, prefix: 'failure');
          rethrow;
        }

        final Object? exception = tester.takeException();
        expect(exception, isNull);
        if (exception != null) throw exception;

        capturer.dispose();
        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
      }

      for (final animatingPart in _AnimatingPart.values) {
        group('animatingPart=${animatingPart.name}', () {
          for (var iter = 0; iter < 10; ++iter) {
            // have to use a brand new `testWidgets` for one experiment
            // because otherwise things like timing will be wrong
            testWidgets('experiment $iter', (tester) async {
              await _body(
                tester,
                seed: Random().nextInt(100000000),
                animatingPart: animatingPart,
              );
            });
          }
        });
      }

      // when see bugs, can add extra tests here with fixed seed
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

enum _AnimatingPart {
  auxTree,
  mainTreeChild,
}
