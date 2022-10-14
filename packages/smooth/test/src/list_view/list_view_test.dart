import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth_dev/smooth_dev.dart';

import '../test_tools/gesture.dart';

void main() {
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
        const expectPlainListViewOffsets = [
          45.0,
          49.6218337416752,
          53.5288786404719,
          56.78345020704792,
          59.447863952061084,
          61.584435386169176,
          63.25548002003002,
          64.52331336430143,
          65.45025092964121,
          66.09860822670717,
          66.53070076615711,
          66.80884405864884,
          66.99535361484021,
          67.15254494538898,
          67.28437910032227,
          67.28437910032227,
          67.28437910032227,
          67.28437910032227,
        ];

        const expectSmoothListViewOffsets = [
          45.0,
          49.621833741675445,
          53.5288786404724,
          56.78345020704865,
          59.44786395206202,
          61.58443538617031,
          63.255480020031335,
          64.52331336430291,
          65.45025092964282,
          66.09860822670889,
          66.53070076615893,
          66.80884405865073,
          66.99535361484213,
          67.15254494539093,
          67.28437910032429,
          67.28437910032429,
          67.28437910032429,
          67.28437910032429,
        ];

        setUpAll(() {
          expect(expectPlainListViewOffsets.lastTwoItemsEqual, true,
              reason: 'should come to a stop');
          expect(expectSmoothListViewOffsets.lastTwoItemsEqual, true,
              reason: 'should come to a stop');

          for (var i = 0; i < expectPlainListViewOffsets.length; ++i) {
            expect(expectPlainListViewOffsets[i],
                moreOrLessEquals(expectSmoothListViewOffsets[i]));
          }
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
            gesture.addEventMove(Offset(100, 500 - i * 5));
            await gesture.plainDispatchAll();

            await tester
                .pump(timeInfo.calcPumpDuration(smoothFrameIndex: 2 + i));
            await capturer.expectAndReset(tester,
                expectTestFrameNumber: 4 + i,
                expectImages: [
                  t.createExpectImage(i * 5),
                ]);
            debugPrint('offset=${getScrollableOffset(tester)}');
          }

          gesture.addEventUp();
          await gesture.plainDispatchAll();

          debugPrint('action: pumps after pointer up');
          await pumpFramesAfterPointUp(t, timeInfo);

          final expectOffsets = enableSmoothListView
              ? expectSmoothListViewOffsets
              : expectPlainListViewOffsets;
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

                for (var i = 0; i < 18; ++i) {
                  await tester.pump(
                      timeInfo.calcPumpDuration(smoothFrameIndex: 12 + i));
                  actualOffsets.add(getScrollableOffset(tester));
                  debugPrint('i=$i offset=${getScrollableOffset(tester)}');
                }

                final expectOffsets = enableSmoothListView
                    ? expectSmoothListViewOffsets
                    : expectPlainListViewOffsets;
                expect(actualOffsets, expectOffsets);
              },
            );
          });
        }

        testWidgets('SmoothListView with preempt renders', (tester) async {
          await _body(
            tester,
            numWindowRenderPerPlainFrame: 3,
            pumpFramesAfterPointUp: (t, timeInfo) async {
              for (var i = 0; i < 6; ++i) {
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

  ui.Image createExpectImage(double offset) {
    return buildImageFromPainter(SchedulerBinding.instance.window.size,
        (canvas) {
      canvas.translate(0, -offset);

      canvas.drawRect(const Rect.fromLTWH(0, 0, 200, 600),
          Paint()..color = Colors.primaries[0]);
      canvas.drawRect(const Rect.fromLTWH(0, 600, 200, 600),
          Paint()..color = Colors.primaries[1]);
      canvas.drawRect(const Rect.fromLTWH(0, 1200, 200, 600),
          Paint()..color = Colors.primaries[2]);

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
                height: 600,
                color: Colors.primaries[index],
              ),
            ),
            AlwaysPaintBuilder(onPaint: onPaint),
            AlwaysLayoutBuilder(onPerformLayout: onBeforePreemptPoint),
            const LayoutPreemptPointWidget(child: AlwaysLayoutBuilder()),
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
