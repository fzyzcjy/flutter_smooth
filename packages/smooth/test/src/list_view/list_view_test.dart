import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth_dev/smooth_dev.dart';

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
      testWidgets('simple', (tester) async {
        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
        final timeInfo = TimeInfo();
        final capturer = WindowRenderCapturer.autoDispose();

        await tester.pumpWidget(SmoothScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SmoothListView.builder(
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

        final gesture = await tester
            .startGesture(tester.getCenter(find.byType(SmoothListView)));

        TODO_simulate_extra_pointer_move_event;

        TODO_simulate_preempt_render;

        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: TODO));
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
          TODO,
        ]);

        TODO_the_extra_events_will_be_normal_events;

        await gesture.up();

        await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: TODO));
        await capturer
            .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
          TODO,
        ]);

        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
      });
    });
  });
}
