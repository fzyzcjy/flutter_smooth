import 'dart:math';
import 'dart:ui' as ui;

import 'package:convenient_test_dev/convenient_test_dev.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth_dev/smooth_dev.dart';

import '../test_tools/gesture.dart';

void main() {
  goldenFileComparator =
      EnhancedLocalFileComparator.configFromCurrent(captureFailure: false);

  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  group('SmoothListView', () {
    binding.window.setUpTearDown(
      physicalSizeTestValue: const Size(200, 1000),
      devicePixelRatioTestValue: 1,
    );

    group('simplest construction', () {
      for (final smooth in [false, true]) {
        testWidgets(smooth ? 'smooth' : 'plain', (tester) async {
          final capturer = WindowRenderCapturer.autoDispose();

          await tester.pumpWidget(SmoothParent(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SmoothListView.maybeBuilder(
                smooth: smooth,
                itemCount: 100,
                itemBuilder: (_, index) => Container(
                  height: 600,
                  color: Colors.primaries[index],
                ),
              ),
            ),
          ));

          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
            await tester.createScreenImage((im) => im
              ..fillRect(const Rectangle(0, 0, 200, 600), Colors.primaries[0])
              ..fillRect(
                  const Rectangle(0, 600, 200, 400), Colors.primaries[1])),
          ]);
        });
      }
    });

    group('when dragging, should smoothly follow touching point', () {
      // also reproduce #6061
      testWidgets('integrated', (tester) async {
        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
        final timeInfo = TimeInfo();
        final capturer = WindowRenderCapturer.autoDispose();
        final t = _SmoothListViewTester(tester);
        final gesture = TestSmoothGesture();

        await tester.pumpWidget(t.build());
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
          t.createExpectImage(0),
        ]);

        gesture.addEventDown(const Offset(100, 500));
        await gesture.plainDispatchAll();
        gesture.addEventMove(const Offset(100, 400));
        await gesture.plainDispatchAll();

        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
          t.createExpectImage(500 - 400),
        ]);

        gesture.addEventMove(const Offset(100, 300));
        await gesture.plainDispatchAll();

        debugPrint('action: pump');
        t
          ..onBeforePreemptPoint.once = () {
            debugPrint('action: elapse + addEvent before PreemptPoint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(100, 200));
          }
          ..onAfterPreemptPoint.once = () {
            debugPrint('action: elapse + addEvent after PreemptPoint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(100, 150));
          }
          ..onPaint.once = () {
            debugPrint('action: elapse on paint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(100, 100));
          };
        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 2));

        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 4, expectImages: [
          // note there is "lag" - because we do not use the PointerEvent
          // immediately, but only use the ones that are old enough to be "real"
          // the BuildOrLayoutPhasePreemptRender
          t.createExpectImage(500 - 300),
          // the plain old render
          t.createExpectImage(500 - 200),
          // extra smooth frame after finalize phase
          // i.e. PostDrawFramePhasePreemptRender
          t.createExpectImage(500 - 150),
        ]);

        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
      });
    });

    group('when animation after drag, should be smooth', () {
      group('integrated', () {
        // copied from the ListView control group output
        const expectOffsets = [
          180.0,
          199.44533769717455,
          217.80292874716304,
          235.10514008766364,
          251.38433865637467,
          266.67289139099427,
          281.00316522922066,
          294.40752710875205,
          306.91834396728666,
          318.56798274252264,
          329.38881037215833,
          339.4131937938918,
          348.67349994542144,
          357.2020957644453,
          365.03134818866164,
          372.19362415576865,
          378.7212906034646,
          384.64671446944766,
          390.00226269141604,
          394.82030220706804,
          399.13319995410166,
          402.9733228702154,
          406.37303789310727,
          409.3647119604755,
          411.98071201001835,
          414.253404979434,
          416.2151578064207,
          417.89833742867654,
          419.3353107839,
          420.5584448097892,
          421.600106444042,
          422.492662624357,
          423.26848028843233,
          423.959926373966,
          424.59936781865656,
          425.2191715602021,
          425.8517045363008,
          426.5293336846507,
          427.2844259429503,
          427.3647422676471,
          427.3647422676471,
          427.3647422676471,
          427.3647422676471,
          427.3647422676471,
          427.3647422676471
        ];

        setUpAll(() {
          expect(expectOffsets.lastTwoItemsEqual, true,
              reason: 'should come to a stop');
        });

        // https://github.com/fzyzcjy/yplusplus/issues/6170#issuecomment-1276994971
        double getScrollableOffset(WidgetTester tester) {
          final state = tester.state<ScrollableState>(find.byType(Scrollable));
          return state.position.pixels;
        }

        Future<void> _body(
          WidgetTester tester, {
          required Future<void> Function(_SmoothListViewTester, TimeInfo)
              pumpFramesAfterPointUp,
          required int numWindowRenderPerPlainFrame,
          bool enableSmoothListView = true,
        }) async {
          debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
          final timeInfo = TimeInfo();
          final capturer = WindowRenderCapturer.autoDispose();
          final t = _SmoothListViewTester(tester,
              enableSmoothListView: enableSmoothListView);
          final gesture = TestSmoothGesture();

          await tester.pumpWidget(t.build());
          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
            t.createExpectImage(0),
          ]);

          gesture.addEventDown(const Offset(100, 500));
          await gesture.plainDispatchAll();

          await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));
          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
            t.createExpectImage(0),
          ]);
          debugPrint('offset=${getScrollableOffset(tester)}');

          for (var i = 0; i < 10; ++i) {
            gesture.addEventMove(Offset(100, 500 - i * 20));
            await gesture.plainDispatchAll();

            await tester
                .pump(timeInfo.calcPumpDuration(smoothFrameIndex: 2 + i));
            await capturer.expectAndReset(tester,
                expectTestFrameNumber: 4 + i,
                expectImages: [
                  t.createExpectImage(i * 20),
                ]);
            debugPrint('offset=${getScrollableOffset(tester)}');
          }

          gesture.addEventUp();
          await gesture.plainDispatchAll();

          debugPrint('action: pumps after pointer up');
          await pumpFramesAfterPointUp(t, timeInfo);

          await capturer.pack.expect(
              tester,
              WindowRenderPack.of({
                for (var i = 0;
                    i < expectOffsets.length ~/ numWindowRenderPerPlainFrame;
                    ++i)
                  14 + i: [
                    for (var j = 0; j < numWindowRenderPerPlainFrame; ++j)
                      t.createExpectImage(
                        expectOffsets[i * numWindowRenderPerPlainFrame + j],
                      ),
                  ],
              }));
          capturer.pack.reset();

          debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
        }

        for (final enableSmoothListView in [false, true]) {
          // work as control group, so we can more easily understand how a
          // normal ListView will behave
          testWidgets(
              enableSmoothListView
                  ? 'SmoothListView without preempt renders'
                  : 'using plain old ListView', (tester) async {
            await _body(
              tester,
              numWindowRenderPerPlainFrame: 1,
              enableSmoothListView: enableSmoothListView,
              pumpFramesAfterPointUp: (t, timeInfo) async {
                final actualOffsets = <double>[];

                for (var i = 0; i < 45; ++i) {
                  await tester.pump(
                      timeInfo.calcPumpDuration(smoothFrameIndex: 12 + i));
                  actualOffsets.add(getScrollableOffset(tester));
                  debugPrint('i=$i offset=${getScrollableOffset(tester)}');
                }

                _expectListMoreOrLessEquals(actualOffsets, expectOffsets);
              },
            );
          });
        }

        testWidgets('SmoothListView with preempt renders', (tester) async {
          await _body(
            tester,
            numWindowRenderPerPlainFrame: 3,
            pumpFramesAfterPointUp: (t, timeInfo) async {
              for (var i = 0; i < 15; ++i) {
                debugPrint('action: pump (i=$i)');
                t
                  ..onBeforePreemptPoint.once = () {
                    debugPrint('action: elapse before PreemptPoint');
                    binding.elapseBlocking(const Duration(microseconds: 16500));
                  }
                  ..onAfterPreemptPoint.once = () {
                    debugPrint('action: elapse after PreemptPoint');
                    binding.elapseBlocking(const Duration(microseconds: 16500));
                  }
                  ..onPaint.once = () {
                    debugPrint('action: elapse on paint');
                    binding.elapseBlocking(const Duration(microseconds: 16500));
                  };
                await tester.pump(
                    timeInfo.calcPumpDuration(smoothFrameIndex: 12 + i * 3));
              }
            },
          );
        });
      });
    });

    // testWidgets('simple integration test', (tester) async {
    //   debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
    //   final timeInfo = TimeInfo();
    //   final capturer = WindowRenderCapturer.autoDispose();
    //   final t = _SmoothListViewTester(tester);
    //   final gesture = TestSmoothGesture();
    //
    //   debugPrint('action: pumpWidget');
    //   await tester.pumpWidget(t.build());
    //   await capturer
    //       .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
    //     t.createExpectImage(0),
    //   ]);
    //
    //   debugPrint('action: addEvent down');
    //   gesture.addEventDown(const Offset(100, 50), timeInfo.testBeginTime);
    //
    //   debugPrint('action: plainDispatchAll');
    //   await gesture.plainDispatchAll();
    //
    //   debugPrint('action: pump');
    //   t
    //     ..onBeforePreemptPoint.once = () {
    //       debugPrint('action: elapse + addEvent before PreemptPoint');
    //       binding.elapseBlocking(const Duration(microseconds: 16500));
    //       gesture.addEventMove(const Offset(100, 20));
    //     }
    //     ..onAfterPreemptPoint.once = () {
    //       debugPrint('action: elapse + addEvent after PreemptPoint');
    //       binding.elapseBlocking(const Duration(microseconds: 16500));
    //       gesture.addEventMove(const Offset(100, 15));
    //     };
    //   await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));
    //
    //   await capturer
    //       .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
    //     t.createExpectImage(50 - 20),
    //     // NOTE the "drag to y=15" is dispatched *after* preemptRender, but
    //     // we do know it
    //     // https://github.com/fzyzcjy/yplusplus/issues/6050#issuecomment-1271182805
    //     t.createExpectImage(50 - 15),
    //   ]);
    //
    //   debugPrint('action: addEvent move(y=10)');
    //   gesture.addEventMove(const Offset(100, 10));
    //
    //   debugPrint('action: plainDispatchAll');
    //   await gesture.plainDispatchAll();
    //
    //   debugPrint('action: pump');
    //   t
    //     ..onBeforePreemptPoint.once = () {
    //       debugPrint('action: elapse + addEvent before PreemptPoint');
    //       binding.elapseBlocking(const Duration(microseconds: 16500));
    //       gesture.addEventMove(const Offset(100, 5));
    //     }
    //     ..onAfterPreemptPoint.once = () {
    //       debugPrint('action: elapse + addEvent after PreemptPoint');
    //       binding.elapseBlocking(const Duration(microseconds: 16500));
    //       gesture.addEventMove(const Offset(100, 0));
    //     };
    //   await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 3));
    //
    //   await capturer
    //       .expectAndReset(tester, expectTestFrameNumber: 4, expectImages: [
    //     t.createExpectImage(50 - 5),
    //     t.createExpectImage(50 - 0),
    //   ]);
    //
    //   debugPrint('action: addEvent up');
    //   gesture.addEventUp();
    //
    //   debugPrint('action: plainDispatchAll');
    //   await gesture.plainDispatchAll();
    //
    //   await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 5));
    //   await capturer
    //       .expectAndReset(tester, expectTestFrameNumber: 5, expectImages: [
    //     t.createExpectImage(50 - 0),
    //   ]);
    //
    //   debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
    // });
  });
}

class _SmoothListViewTester {
  final WidgetTester tester;
  final bool enableSmoothListView;

  _SmoothListViewTester(
    this.tester, {
    this.enableSmoothListView = true,
  });

  final onBeforePreemptPoint = OnceCallable();
  final onAfterPreemptPoint = OnceCallable();
  final onPaint = OnceCallable();

  static const itemHeight = 100.0;

  ui.Image createExpectImage(double offset) {
    return buildImageFromPainter(SchedulerBinding.instance.window.size,
        (canvas) {
      canvas.translate(0, -offset);

      for (var i = 0; i < 50; ++i) {
        canvas.drawRect(Rect.fromLTWH(0, itemHeight * i, 200, itemHeight),
            Paint()..color = Colors.primaries[i % Colors.primaries.length]);
      }

      canvas.translate(0, offset);
    });
  }

  Widget build() {
    return SmoothParent(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            SmoothListView.maybeBuilder(
              smooth: enableSmoothListView,
              itemCount: 100,
              itemBuilder: (_, index) => Container(
                height: itemHeight,
                color: Colors.primaries[index % Colors.primaries.length],
              ),
            ),
            AlwaysPaintBuilder(onPaint: onPaint),
            AlwaysLayoutBuilder(onPerformLayout: onBeforePreemptPoint),
            const SmoothLayoutPreemptPointWidget(child: AlwaysLayoutBuilder()),
            AlwaysLayoutBuilder(onPerformLayout: onAfterPreemptPoint),
          ],
        ),
      ),
    );
  }
}

extension on ui.SingletonFlutterWindow {
  Size get size => physicalSize / devicePixelRatio;
}

extension on List<double> {
  bool get lastTwoItemsEqual => last == this[length - 2];
}

void _expectListMoreOrLessEquals(List<double> actual, List<double> matcher) {
  try {
    expect(actual.length, matcher.length);
    for (var i = 0; i < actual.length; ++i) {
      expect(actual[i], moreOrLessEquals(matcher[i]));
    }
  } on TestFailure catch (_) {
    String _fmt(double value) => value.toStringAsFixed(2);
    final formatted = [
      'actual\tmatcher\tdiff',
      for (var i = 0; i < min(actual.length, matcher.length); ++i)
        '${_fmt(actual[i])}\t${_fmt(matcher[i])}\t${_fmt(actual[i] - matcher[i])}'
    ].join('\n');
    // ignore: avoid_print
    print(
        'expectListMoreOrLessEquals a=$actual b=$matcher formatted=\n$formatted');
    rethrow;
  }
}
