import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth_dev/smooth_dev.dart';

import '../test_tools/gesture.dart';
import '../test_tools/widgets.dart';

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

          await tester.pumpWidget(SmoothScope(
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

        var interestFrame = false;
        Offset? moveOffsetBeforePreemptPoint, moveOffsetAfterPreemptPoint;
        final gesture = TestSmoothGesture();

        debugPrint('action: pumpWidget');
        await tester.pumpWidget(SmoothScope(
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
                AlwaysLayoutBuilder(onPerformLayout: () {
                  if (!interestFrame) return;
                  debugPrint('action: elapse + addEvent before PreemptPoint');
                  binding.elapseBlocking(const Duration(microseconds: 16500));
                  gesture.addEvent(
                      gesture.pointer.move(moveOffsetBeforePreemptPoint!));
                }),
                const LayoutPreemptPointWidget(child: AlwaysLayoutBuilder()),
                AlwaysLayoutBuilder(onPerformLayout: () {
                  if (!interestFrame) return;
                  debugPrint('action: elapse + addEvent after PreemptPoint');
                  binding.elapseBlocking(const Duration(microseconds: 16500));
                  gesture.addEvent(
                      gesture.pointer.move(moveOffsetAfterPreemptPoint!));
                }),
              ],
            ),
          ),
        ));
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
          await tester.createScreenImage((im) => im
            ..fillRect(const Rectangle(0, 0, 50, 60), Colors.primaries[0])
            ..fillRect(const Rectangle(0, 60, 50, 40), Colors.primaries[1])),
        ]);

        debugPrint('action: addEvent down');
        gesture.addEvent(gesture.pointer.down(const Offset(25, 50)));

        debugPrint('action: plainDispatchAll');
        await gesture.plainDispatchAll();

        debugPrint('action: pump');
        interestFrame = true;
        moveOffsetBeforePreemptPoint = const Offset(25, 20);
        moveOffsetAfterPreemptPoint = const Offset(25, 15);
        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));
        interestFrame = false;

        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
          // drag y=50->20
          await tester.createScreenImage((im) => im
            ..fillRect(const Rectangle(0, 0, 50, 30), Colors.primaries[0])
            ..fillRect(const Rectangle(0, 30, 50, 60), Colors.primaries[1])
            ..fillRect(const Rectangle(0, 90, 50, 10), Colors.primaries[2])),
          // NOTE the "drag to y=15" is dispatched *after* preemptRender, but
          // we do know it
          // https://github.com/fzyzcjy/yplusplus/issues/6050#issuecomment-1271182805
          // drag y=50->15
          await tester.createScreenImage((im) => im
            ..fillRect(const Rectangle(0, 0, 50, 25), Colors.primaries[0])
            ..fillRect(const Rectangle(0, 25, 50, 60), Colors.primaries[1])
            ..fillRect(const Rectangle(0, 85, 50, 15), Colors.primaries[2])),
        ]);

        debugPrint('action: addEvent move(y=10)');
        gesture.addEvent(gesture.pointer.move(const Offset(25, 10)));

        debugPrint('action: plainDispatchAll');
        await gesture.plainDispatchAll();

        debugPrint('action: pump');
        interestFrame = true;
        moveOffsetBeforePreemptPoint = const Offset(25, 5);
        moveOffsetAfterPreemptPoint = const Offset(25, 0);
        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 3));
        interestFrame = false;

        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 4, expectImages: [
          // drag y=50->5
          await tester.createScreenImage((im) => im
            ..fillRect(const Rectangle(0, 0, 50, 15), Colors.primaries[0])
            ..fillRect(const Rectangle(0, 15, 50, 60), Colors.primaries[1])
            ..fillRect(const Rectangle(0, 75, 50, 25), Colors.primaries[2])),
          // drag y=50->0
          await tester.createScreenImage((im) => im
            ..fillRect(const Rectangle(0, 0, 50, 10), Colors.primaries[0])
            ..fillRect(const Rectangle(0, 10, 50, 60), Colors.primaries[1])
            ..fillRect(const Rectangle(0, 70, 50, 30), Colors.primaries[2])),
        ]);

        debugPrint('action: addEvent up');
        gesture.addEvent(gesture.pointer.up());

        debugPrint('action: plainDispatchAll');
        await gesture.plainDispatchAll();

        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 5));
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 5, expectImages: [
          // drag y=50->0
          await tester.createScreenImage((im) => im
            ..fillRect(const Rectangle(0, 0, 50, 10), Colors.primaries[0])
            ..fillRect(const Rectangle(0, 10, 50, 60), Colors.primaries[1])
            ..fillRect(const Rectangle(0, 70, 50, 30), Colors.primaries[2])),
        ]);

        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
      });
    });
  });
}
