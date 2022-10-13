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
        // work as control group, so we can more easily understand how a
        // normal ListView will behave
        testWidgets('using plain old ListView', (tester) async {
          // https://github.com/fzyzcjy/yplusplus/issues/6170#issuecomment-1276994971
          double getCurrentOffset() {
            final state =
                tester.state<ScrollableState>(find.byType(Scrollable));
            return state.position.pixels;
          }

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

          await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));
          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
            t.createExpectImage(50 - 50),
          ]);
          debugPrint('offset=${getCurrentOffset()}');

          gesture.addEventMove(const Offset(100, 300));
          await gesture.plainDispatchAll();

          await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 2));
          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 4, expectImages: [
            t.createExpectImage(50 - 30),
          ]);
          debugPrint('offset=${getCurrentOffset()}');

          gesture.addEventUp();
          await gesture.plainDispatchAll();

          for (var i = 0; i < 6; ++i) {
            await tester
                .pump(timeInfo.calcPumpDuration(smoothFrameIndex: i + 3));
            debugPrint('offset=${getCurrentOffset()}');

            await capturer.expectAndReset(tester,
                expectTestFrameNumber: i + 4,
                expectImages: [
                  // TODO
                ]);
          }

          debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
        });

        testWidgets('using SmoothListView', (tester) async {
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

          await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));
          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
            t.createExpectImage(50 - 50),
          ]);

          gesture.addEventMove(const Offset(100, 300));
          await gesture.plainDispatchAll();

          await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 2));
          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 4, expectImages: [
            t.createExpectImage(50 - 30),
          ]);

          gesture.addEventUp();
          await gesture.plainDispatchAll();

          debugPrint('action: pump');
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
          await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 3));

          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 5, expectImages: [
            // TODO
          ]);

          debugPrint('action: pump');
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
          await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 6));

          await capturer
              .expectAndReset(tester, expectTestFrameNumber: 6, expectImages: [
            // TODO
          ]);

          debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
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

  _SmoothListViewTester(this.tester);

  final onBeforePreemptPoint = OnceCallable();
  final onAfterPreemptPoint = OnceCallable();
  final onPaint = OnceCallable();

  ui.Image createExpectImage(int offset) {
    return buildImageFromPainter(SchedulerBinding.instance.window.size,
        (canvas) {
      canvas.translate(0, -offset.toDouble());

      canvas.drawRect(const Rect.fromLTWH(0, 0, 200, 600),
          Paint()..color = Colors.primaries[0]);
      canvas.drawRect(const Rect.fromLTWH(0, 600, 200, 600),
          Paint()..color = Colors.primaries[1]);
      canvas.drawRect(const Rect.fromLTWH(0, 1200, 200, 600),
          Paint()..color = Colors.primaries[2]);

      canvas.translate(0, offset.toDouble());
    });
  }

  Widget build() {
    return SmoothParent(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            SmoothListView.builder(
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
