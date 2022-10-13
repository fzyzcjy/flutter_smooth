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
      physicalSizeTestValue: const Size(50, 100),
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
      }
    });

    group('when user drags ListView, should be smooth', () {
      testWidgets('simple integration test', (tester) async {
        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
        final timeInfo = TimeInfo();
        final capturer = WindowRenderCapturer.autoDispose();
        final t = _SmoothListViewTester(tester);
        final gesture = TestSmoothGesture();

        debugPrint('action: pumpWidget');
        await tester.pumpWidget(t.build());
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
          await t.createExpectImage(0),
        ]);

        debugPrint('action: addEvent down');
        gesture.addEventDown(const Offset(25, 50), timeInfo.testBeginTime);

        debugPrint('action: plainDispatchAll');
        await gesture.plainDispatchAll();

        debugPrint('action: pump');
        t
          ..onBeforePreemptPoint.once = () {
            debugPrint('action: elapse + addEvent before PreemptPoint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(25, 20));
          }
          ..onAfterPreemptPoint.once = () {
            debugPrint('action: elapse + addEvent after PreemptPoint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(25, 15));
          };
        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));

        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
          await t.createExpectImage(50 - 20),
          // NOTE the "drag to y=15" is dispatched *after* preemptRender, but
          // we do know it
          // https://github.com/fzyzcjy/yplusplus/issues/6050#issuecomment-1271182805
          await t.createExpectImage(50 - 15),
        ]);

        debugPrint('action: addEvent move(y=10)');
        gesture.addEventMove(const Offset(25, 10));

        debugPrint('action: plainDispatchAll');
        await gesture.plainDispatchAll();

        debugPrint('action: pump');
        t
          ..onBeforePreemptPoint.once = () {
            debugPrint('action: elapse + addEvent before PreemptPoint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(25, 5));
          }
          ..onAfterPreemptPoint.once = () {
            debugPrint('action: elapse + addEvent after PreemptPoint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(25, 0));
          };
        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 3));

        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 4, expectImages: [
          await t.createExpectImage(50 - 5),
          await t.createExpectImage(50 - 0),
        ]);

        debugPrint('action: addEvent up');
        gesture.addEventUp();

        debugPrint('action: plainDispatchAll');
        await gesture.plainDispatchAll();

        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 5));
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 5, expectImages: [
          await t.createExpectImage(50 - 0),
        ]);

        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
      });

      // #6061
      testWidgets('when submit extra smooth frame after finalize phase',
          (tester) async {
        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
        final timeInfo = TimeInfo();
        final capturer = WindowRenderCapturer.autoDispose();
        final t = _SmoothListViewTester(tester);
        final gesture = TestSmoothGesture();

        await tester.pumpWidget(t.build());
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
          await t.createExpectImage(0),
        ]);
        gesture.addEventDown(const Offset(25, 50));
        await gesture.plainDispatchAll();

        gesture.addEventMove(const Offset(25, 40));
        await gesture.plainDispatchAll();
        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
          await t.createExpectImage(50 - 40),
        ]);

        gesture.addEventMove(const Offset(25, 30));
        await gesture.plainDispatchAll();

        debugPrint('action: pump');
        t
          ..onBeforePreemptPoint.once = () {
            debugPrint('action: elapse + addEvent before PreemptPoint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(25, 20));
          }
          ..onAfterPreemptPoint.once = () {
            debugPrint('action: elapse + addEvent after PreemptPoint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(25, 15));
          }
          ..onPaint.once = () {
            debugPrint('action: elapse on paint');
            binding.elapseBlocking(const Duration(microseconds: 16500));
            gesture.addEventMove(const Offset(25, 10));
          };
        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 2));

        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 4, expectImages: [
          await t.createExpectImage(50 - 20),
          await t.createExpectImage(50 - 15),
          // extra smooth frame after finalize phase
          await t.createExpectImage(50 - 10),
        ]);

        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
      });
    });
  });
}

class _SmoothListViewTester {
  final WidgetTester tester;

  _SmoothListViewTester(this.tester);

  final onBeforePreemptPoint = OnceCallable();
  final onAfterPreemptPoint = OnceCallable();
  final onPaint = OnceCallable();

  Future<ui.Image> createExpectImage(int offset) =>
      tester.createScreenImage((im) => im
        ..fillRect(Rectangle(0, 0 - offset, 50, 60), Colors.primaries[0])
        ..fillRect(Rectangle(0, 60 - offset, 50, 60), Colors.primaries[1])
        ..fillRect(Rectangle(0, 120 - offset, 50, 60), Colors.primaries[2]));

  Widget build() {
    return SmoothParent(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            SmoothListView.builder(
              itemCount: 100,
              itemBuilder: (_, index) => Container(
                height: 60,
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
